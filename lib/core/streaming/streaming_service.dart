import 'dart:async';
import 'dart:convert';

import 'package:uuid/uuid.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'package:mischie/features/timeline/domain/note.dart';

class StreamingService {
  StreamingService({
    required String host,
    required String accessToken,
    required String channel,
    Map<String, dynamic> params = const {},
  }) : _host = host,
       _accessToken = accessToken,
       _channelName = channel,
       _params = params;

  final String _host;
  final String _accessToken;
  final String _channelName;

  /// チャンネル固有のパラメータ（リストなら listId など）。
  final Map<String, dynamic> _params;

  WebSocketChannel? _channel;
  StreamSubscription<dynamic>? _subscription;
  final _controller = StreamController<Note>.broadcast();
  final _events = StreamController<StreamingEvent>.broadcast();
  String? _channelId;

  bool _disposed = false;
  Timer? _reconnectTimer;

  /// 個別に購読しているノート。再接続時に張り直す。
  final Set<String> _capturedNotes = {};

  static const _reconnectDelay = Duration(seconds: 3);

  Stream<Note> get noteStream => _controller.stream;

  /// チャンネルから届いた生のイベント。ノート以外（通知など）に使う。
  Stream<StreamingEvent> get events => _events.stream;

  void connect() {
    if (_disposed) return;
    _reconnectTimer?.cancel();
    _reconnectTimer = null;

    final uri = Uri(
      scheme: 'wss',
      host: _host,
      path: '/streaming',
      queryParameters: {'i': _accessToken},
    );

    _channel = WebSocketChannel.connect(uri);
    _channelId = const Uuid().v4();

    _channel!.sink.add(
      jsonEncode({
        'type': 'connect',
        'body': {'channel': _channelName, 'id': _channelId, ..._params},
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
    _channel?.sink.close();
    _channel = null;
    _subscription?.cancel();
    _subscription = null;
    _channelId = null;
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(_reconnectDelay, connect);
  }

  void disconnect() {
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
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
  }
}

/// ストリーミングのチャンネルイベント。`type` は 'note' や 'notification' など。
class StreamingEvent {
  const StreamingEvent({required this.type, required this.body});

  final String type;
  final Map<String, dynamic> body;
}
