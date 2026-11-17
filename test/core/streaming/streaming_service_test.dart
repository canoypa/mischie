import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mischie/core/streaming/streaming_service.dart';
import 'package:stream_channel/stream_channel.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class _FakeWebSocketChannel extends StreamChannelMixin
    implements WebSocketChannel {
  final _incoming = StreamController<dynamic>.broadcast();
  final List<String> sentMessages = [];
  bool closed = false;

  @override
  String? get protocol => null;
  @override
  int? get closeCode => null;
  @override
  String? get closeReason => null;
  @override
  Future<void> get ready => Future.value();
  @override
  Stream get stream => _incoming.stream;
  @override
  WebSocketSink get sink => _FakeWebSocketSink(this);

  void emit(Object message) => _incoming.add(message);
  void emitError(Object error) => _incoming.addError(error);
  void emitDone() => _incoming.close();
}

class _FakeWebSocketSink implements WebSocketSink {
  _FakeWebSocketSink(this._channel);
  final _FakeWebSocketChannel _channel;

  @override
  void add(dynamic event) => _channel.sentMessages.add(event as String);
  @override
  void addError(Object error, [StackTrace? stackTrace]) {}
  @override
  Future addStream(Stream stream) async {}
  @override
  Future close([int? closeCode, String? closeReason]) async {
    _channel.closed = true;
  }

  @override
  Future get done => Future.value();
}

/// タイマーは発火させず、テストが fireLast で時間を進める。
class _RecordingTimerFactory {
  final List<Duration> delays = [];
  final List<void Function()> _callbacks = [];

  Timer call(Duration delay, void Function() callback) {
    delays.add(delay);
    _callbacks.add(callback);
    return Timer(const Duration(days: 1), () {});
  }

  void fireLast() => _callbacks.removeLast()();
}

Future<void> _flush() => Future<void>.delayed(Duration.zero);

void main() {
  group('StreamingService の connect メッセージ', () {
    test('channel 固有のパラメータは params に入れて送る', () {
      _FakeWebSocketChannel? channel;
      final service = StreamingService(
        host: 'example.com',
        accessToken: 'token',
        channel: 'userList',
        params: const {'listId': 'abc'},
        connector: (uri) => channel = _FakeWebSocketChannel(),
        timerFactory: (delay, cb) => Timer(const Duration(days: 1), () {}),
      );
      addTearDown(service.dispose);

      service.connect();

      final sent =
          jsonDecode(channel!.sentMessages.single) as Map<String, dynamic>;
      expect(sent['type'], 'connect');
      final body = sent['body'] as Map<String, dynamic>;
      expect(body['channel'], 'userList');
      expect(body['params'], {'listId': 'abc'});
      expect(body.containsKey('listId'), isFalse);
    });
  });

  group('StreamingService の再接続バックオフ', () {
    test('切断のたびに 2 秒から倍々に増え、60 秒で止まる', () async {
      final timerFactory = _RecordingTimerFactory();
      final channels = <_FakeWebSocketChannel>[];
      final service = StreamingService(
        host: 'example.com',
        accessToken: 'token',
        channel: 'main',
        connector: (uri) {
          final channel = _FakeWebSocketChannel();
          channels.add(channel);
          return channel;
        },
        timerFactory: timerFactory.call,
      );
      addTearDown(service.dispose);

      service.connect();

      // メッセージを一度も受け取らないまま切断を繰り返す
      const expected = [2, 4, 8, 16, 32, 60, 60];
      for (final seconds in expected) {
        channels.last.emitDone();
        await _flush();
        expect(timerFactory.delays.last, Duration(seconds: seconds));
        timerFactory.fireLast();
      }
    });

    test('onError と onDone が同時に来ても、1 回の切断につき 1 段しか進まない', () async {
      final timerFactory = _RecordingTimerFactory();
      final channels = <_FakeWebSocketChannel>[];
      final service = StreamingService(
        host: 'example.com',
        accessToken: 'token',
        channel: 'main',
        connector: (uri) {
          final channel = _FakeWebSocketChannel();
          channels.add(channel);
          return channel;
        },
        timerFactory: timerFactory.call,
      );
      addTearDown(service.dispose);

      service.connect();

      channels.last.emitError(Exception('boom'));
      channels.last.emitDone();
      await _flush();

      expect(timerFactory.delays, [const Duration(seconds: 2)]);
    });

    test('メッセージを受け取ってから切断すると、次のバックオフは初期値に戻る', () async {
      final timerFactory = _RecordingTimerFactory();
      final channels = <_FakeWebSocketChannel>[];
      final service = StreamingService(
        host: 'example.com',
        accessToken: 'token',
        channel: 'main',
        connector: (uri) {
          final channel = _FakeWebSocketChannel();
          channels.add(channel);
          return channel;
        },
        timerFactory: timerFactory.call,
      );
      addTearDown(service.dispose);

      service.connect();
      channels.last.emitDone();
      await _flush();
      expect(timerFactory.delays.last, const Duration(seconds: 2));
      timerFactory.fireLast();

      channels.last.emitDone();
      await _flush();
      expect(timerFactory.delays.last, const Duration(seconds: 4));
      timerFactory.fireLast();

      channels.last.emit(jsonEncode({'type': 'noteUpdated', 'body': {}}));
      await _flush();
      channels.last.emitDone();
      await _flush();

      expect(timerFactory.delays.last, const Duration(seconds: 2));
    });
  });

  group('StreamingService.reconnected', () {
    test('最初の connect では発火せず、切断後の再接続で発火する', () async {
      final timerFactory = _RecordingTimerFactory();
      final channels = <_FakeWebSocketChannel>[];
      final service = StreamingService(
        host: 'example.com',
        accessToken: 'token',
        channel: 'main',
        connector: (uri) {
          final channel = _FakeWebSocketChannel();
          channels.add(channel);
          return channel;
        },
        timerFactory: timerFactory.call,
      );
      addTearDown(service.dispose);

      var reconnectedCount = 0;
      service.reconnected.listen((_) => reconnectedCount++);

      service.connect();
      await _flush();
      expect(reconnectedCount, 0);

      channels.last.emitDone();
      await _flush();
      timerFactory.fireLast();
      await _flush();
      expect(reconnectedCount, 1);

      service.reconnect();
      await _flush();
      expect(reconnectedCount, 2);
    });
  });
}
