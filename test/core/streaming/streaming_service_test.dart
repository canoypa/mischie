import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mischie/core/streaming/streaming_service.dart';
import 'package:stream_channel/stream_channel.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

/// 実ソケットの代わりに注入するフェイク。sink.add した内容を記録し、
/// テストから任意のタイミングでメッセージ／エラー／切断を発生させられる。
/// pipe/transform 等は StreamChannelMixin の既定実装に任せる。
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

/// 再接続タイマーを実際には待たず、渡された Duration とコールバックだけを
/// 記録する。コールバックはテストから明示的に呼んで「時間経過」を模する。
class _RecordingTimerFactory {
  final List<Duration> delays = [];
  final List<void Function()> _callbacks = [];

  Timer call(Duration delay, void Function() callback) {
    delays.add(delay);
    _callbacks.add(callback);
    // 実際には発火させない。テストが fireLast で明示的に進める。
    return Timer(const Duration(days: 1), () {});
  }

  void fireLast() => _callbacks.removeLast()();
}

/// StreamController.add/addError/close はリスナーに非同期で届く
/// （broadcast でも同期呼び出しにはならない）。組み込みイベントを発生
/// させた直後は、その配送を待つためにこれを挟む。
Future<void> _flush() => Future<void>.delayed(Duration.zero);

void main() {
  group('StreamingService の connect メッセージ', () {
    test('channel 固有のパラメータは params にネストされる（トップレベルに漏れない）', () {
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

      // メッセージを一度も受け取れないまま切断を繰り返す
      // （2, 4, 8, 16, 32, 60, 60, ...）
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

      // 実ソケットは onError の後に onDone が続くことがある
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
      channels.last.emitDone(); // 2 秒
      await _flush();
      expect(timerFactory.delays.last, const Duration(seconds: 2));
      timerFactory.fireLast();

      channels.last.emitDone(); // 4 秒（まだ何も受け取っていない）
      await _flush();
      expect(timerFactory.delays.last, const Duration(seconds: 4));
      timerFactory.fireLast();

      // ここで初めて生きた通信を確認する
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
      timerFactory.fireLast(); // タイマー経由の自動再接続
      await _flush();
      expect(reconnectedCount, 1);

      service.reconnect(); // アプリ復帰などによる強制再接続
      await _flush();
      expect(reconnectedCount, 2);
    });
  });
}
