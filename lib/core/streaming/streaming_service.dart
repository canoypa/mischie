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
  final _controller = StreamController<Note>.broadcast();
  String? _channelId;

  Stream<Note> get noteStream => _controller.stream;

  void connect() {
    final uri = Uri(
      scheme: 'wss',
      host: _host,
      path: '/streaming',
      queryParameters: {'i': _accessToken},
    );

    _channel = WebSocketChannel.connect(uri);
    _channelId = const Uuid().v4();

    _channel!.sink.add(jsonEncode({
      'type': 'connect',
      'body': {
        'channel': 'homeTimeline',
        'id': _channelId,
      },
    }));

    _channel!.stream.listen(
      (message) {
        final data = jsonDecode(message as String) as Map<String, dynamic>;
        if (data['type'] == 'channel' &&
            data['body']?['id'] == _channelId &&
            data['body']?['type'] == 'note') {
          final noteJson =
              data['body']['body'] as Map<String, dynamic>;
          final note = Note.fromJson(noteJson);
          _controller.add(note);
        }
      },
      onError: (_) {},
      cancelOnError: false,
    );
  }

  void disconnect() {
    if (_channelId != null && _channel != null) {
      _channel!.sink.add(jsonEncode({
        'type': 'disconnect',
        'body': {'id': _channelId},
      }));
    }
    _channel?.sink.close();
    _channel = null;
    _channelId = null;
  }

  void dispose() {
    disconnect();
    _controller.close();
  }
}
