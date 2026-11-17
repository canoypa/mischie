import 'dart:async';
import 'dart:convert';

import 'package:uuid/uuid.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'package:mischie/features/timeline/domain/note.dart';

/// テストでフェイクの接続を差し込むためのフック。
typedef WebSocketConnector = WebSocketChannel Function(Uri uri);

/// テストで再接続の遅延を待たずに検証するためのフック。
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

  bool _everConnected = false;

  /// onError と onDone が続けて届いても、1 回の切断でバックオフを 2 回進めないためのフラグ。
  bool _reconnectScheduled = false;

  Stream<Note> get noteStream => _controller.stream;

  /// noteStream に載らない通知やノートの更新も含めた全イベント。
  Stream<StreamingEvent> get events => _events.stream;

  /// 再接続の通知。取りこぼした分を REST で取り直すきっかけに使う。
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

        // noteUpdated はチャンネル宛てではないので、チャンネルの絞り込みより前に処理する
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

  /// 接続が生きて見えても張り直したいとき（アプリ復帰時）に呼ぶ。
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

class StreamingEvent {
  const StreamingEvent({required this.type, required this.body});

  final String type;
  final Map<String, dynamic> body;
}
