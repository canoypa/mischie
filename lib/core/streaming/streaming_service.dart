import 'dart:async';
import 'dart:convert';

import 'package:uuid/uuid.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'package:mischie/features/timeline/domain/note.dart';

class StreamingService {
  StreamingService({required String host, required String accessToken})
    : _host = host,
      _accessToken = accessToken;

  final String _host;
  final String _accessToken;

  WebSocketChannel? _channel;
  StreamSubscription<dynamic>? _subscription;
  final _controller = StreamController<Note>.broadcast();
  String? _channelId;

  bool _disposed = false;
  Timer? _reconnectTimer;

  static const _reconnectDelay = Duration(seconds: 3);

  Stream<Note> get noteStream => _controller.stream;

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
        'body': {'channel': 'homeTimeline', 'id': _channelId},
      }),
    );

    _subscription = _channel!.stream.listen(
      (message) {
        final data = jsonDecode(message as String) as Map<String, dynamic>;
        if (data['type'] == 'channel' &&
            data['body']?['id'] == _channelId &&
            data['body']?['type'] == 'note') {
          final noteJson = data['body']['body'] as Map<String, dynamic>;
          final note = Note.fromJson(noteJson);
          _controller.add(note);
        }
      },
      onError: (_) => _scheduleReconnect(),
      onDone: _scheduleReconnect,
      cancelOnError: false,
    );
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
  }
}
