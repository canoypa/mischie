import 'dart:async';
import 'dart:convert';

import 'package:uuid/uuid.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'package:mischie/features/timeline/domain/note.dart';

/// ソケットの張り方を差し替えるためのフック。テストでは実ソケットの代わりに
/// フェイクの channel を注入する。
typedef WebSocketConnector = WebSocketChannel Function(Uri uri);

/// 再接続タイマーの生成を差し替えるためのフック。テストでは遅延を実際に
/// 待たず、渡された Duration だけを検証する。
typedef TimerFactory = Timer Function(Duration delay, void Function() callback);

class StreamingService {
  StreamingService({
    required String host,
    required String accessToken,
    required String channel,
    Map<String, dynamic> params = const {},
    WebSocketConnector? connector,
    TimerFactory? timerFactory,
  }) : _host = host,
       _accessToken = accessToken,
       _channelName = channel,
       _params = params,
       _connector = connector ?? _defaultConnector,
       _timerFactory = timerFactory ?? Timer.new;

  final String _host;
  final String _accessToken;
  final String _channelName;

  /// チャンネル固有のパラメータ（リストなら listId など）。
  final Map<String, dynamic> _params;

  final WebSocketConnector _connector;
  final TimerFactory _timerFactory;

  WebSocketChannel? _channel;
  StreamSubscription<dynamic>? _subscription;
  final _controller = StreamController<Note>.broadcast();
  final _events = StreamController<StreamingEvent>.broadcast();
  final _reconnectedController = StreamController<void>.broadcast();
  String? _channelId;

  bool _disposed = false;
  Timer? _reconnectTimer;

  /// 個別に購読しているノート。再接続時に張り直す。
  final Set<String> _capturedNotes = {};

  static const _initialBackoff = Duration(seconds: 2);
  static const _maxBackoff = Duration(seconds: 60);
  static const _pingInterval = Duration(seconds: 30);

  Duration _backoff = _initialBackoff;

  /// この接続で最初のメッセージをまだ受け取っていないか。生きた通信を
  /// 一度も確認できていない再接続の連鎖でバックオフを早まって戻さないため。
  bool _awaitingFirstMessage = true;

  /// これまでに一度でも connect() したか。build() 直後の最初の接続は
  /// 「再接続」ではないので reconnected を発火しない。
  bool _everConnected = false;

  /// 直前の切断に対してすでに再接続をスケジュール済みか。onError と onDone
  /// はセットで飛んでくることがあり、両方が予約すると 1 回の切断でバック
  /// オフが二段飛びしてしまう。
  bool _reconnectScheduled = false;

  Stream<Note> get noteStream => _controller.stream;

  /// チャンネルから届いた生のイベント。ノート以外（通知など）に使う。
  Stream<StreamingEvent> get events => _events.stream;

  /// 再接続が起きた（起きようとした）タイミングの通知。ソケットの生死とは
  /// 独立に、取りこぼしがあり得るタイミングとして REST での catch-up の
  /// トリガーに使う。
  Stream<void> get reconnected => _reconnectedController.stream;

  static WebSocketChannel _defaultConnector(Uri uri) =>
      IOWebSocketChannel.connect(uri, pingInterval: _pingInterval);

  void connect() {
    if (_disposed) return;
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    _reconnectScheduled = false;
    _awaitingFirstMessage = true;

    final isReconnect = _everConnected;
    _everConnected = true;

    final uri = Uri(
      scheme: 'wss',
      host: _host,
      path: '/streaming',
      queryParameters: {'i': _accessToken},
    );

    _channel = _connector(uri);
    _channelId = const Uuid().v4();

    if (isReconnect) _reconnectedController.add(null);

    _channel!.sink.add(
      jsonEncode({
        'type': 'connect',
        'body': {'channel': _channelName, 'id': _channelId, 'params': _params},
      }),
    );

    for (final noteId in _capturedNotes) {
      _send({
        'type': 'subNote',
        'body': {'id': noteId},
      });
    }

    _subscription = _channel!.stream.listen(
      (message) {
        if (_awaitingFirstMessage) {
          _awaitingFirstMessage = false;
          _backoff = _initialBackoff;
        }

        final data = jsonDecode(message as String) as Map<String, dynamic>;

        // ノート個別の更新（リアクションの増減・削除）はチャンネルではなく
        // 接続そのものに届く
        if (data['type'] == 'noteUpdated') {
          final body = data['body'];
          if (body is Map<String, dynamic>) {
            _events.add(StreamingEvent(type: 'noteUpdated', body: body));
          }
          return;
        }

        if (data['type'] != 'channel' || data['body']?['id'] != _channelId) {
          return;
        }
        final body = data['body'] as Map<String, dynamic>;
        final type = body['type'] as String?;
        if (type == null) return;
        final payload = body['body'] as Map<String, dynamic>? ?? const {};

        _events.add(StreamingEvent(type: type, body: payload));
        if (type == 'note') {
          _controller.add(Note.fromJson(payload));
        }
      },
      onError: (_) => _scheduleReconnect(),
      onDone: _scheduleReconnect,
      cancelOnError: false,
    );
  }

  void _send(Map<String, dynamic> message) {
    try {
      _channel?.sink.add(jsonEncode(message));
    } catch (_) {
      // 切断中なら次の接続で張り直す
    }
  }

  /// ノートの更新を受け取るようにする。表示中のノートだけ購読すれば足りる。
  void captureNote(String noteId) {
    if (!_capturedNotes.add(noteId)) return;
    _send({
      'type': 'subNote',
      'body': {'id': noteId},
    });
  }

  void uncaptureNote(String noteId) {
    if (!_capturedNotes.remove(noteId)) return;
    _send({
      'type': 'unsubNote',
      'body': {'id': noteId},
    });
  }

  void _scheduleReconnect() {
    if (_disposed) return;
    // onError と onDone はセットで届くことがある。1 回目の呼び出しで
    // タイマーを立てたら、2 回目はバックオフを進めずに無視する。
    if (_reconnectScheduled) return;
    _reconnectScheduled = true;

    _channel?.sink.close();
    _channel = null;
    _subscription?.cancel();
    _subscription = null;
    _channelId = null;
    _reconnectTimer?.cancel();

    final delay = _backoff;
    final next = _backoff * 2;
    _backoff = next > _maxBackoff ? _maxBackoff : next;
    _reconnectTimer = _timerFactory(delay, connect);
  }

  /// アプリ復帰時など、ソケットが生きているように見えても張り直したいとき
  /// に呼ぶ。バックオフもリセットして即座に再接続する。
  void reconnect() {
    if (_disposed) return;
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    _reconnectScheduled = false;
    _backoff = _initialBackoff;
    _subscription?.cancel();
    _subscription = null;
    _channel?.sink.close();
    _channel = null;
    _channelId = null;
    connect();
  }

  void disconnect() {
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    _reconnectScheduled = false;
    _subscription?.cancel();
    _subscription = null;
    if (_channelId != null && _channel != null) {
      try {
        _channel!.sink.add(
          jsonEncode({
            'type': 'disconnect',
            'body': {'id': _channelId},
          }),
        );
      } catch (_) {}
    }
    _channel?.sink.close();
    _channel = null;
    _channelId = null;
  }

  void dispose() {
    _disposed = true;
    disconnect();
    _controller.close();
    _events.close();
    _reconnectedController.close();
  }
}

/// ストリーミングのチャンネルイベント。`type` は 'note' や 'notification' など。
class StreamingEvent {
  const StreamingEvent({required this.type, required this.body});

  final String type;
  final Map<String, dynamic> body;
}
