import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mischie/core/api/auth_interceptor.dart';

/// 送られたリクエストを覚えて、空の JSON を返すだけのアダプタ。
class _RecordingAdapter implements HttpClientAdapter {
  RequestOptions? last;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    last = options;
    return ResponseBody.fromString(
      '{}',
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

Future<RequestOptions> _send(String? token) async {
  final adapter = _RecordingAdapter();
  final dio = Dio(BaseOptions(baseUrl: 'https://misskey.example/api/'))
    ..httpClientAdapter = adapter
    ..interceptors.add(AuthInterceptor(() async => token));
  await dio.post<Map<String, dynamic>>('i', data: {});
  return adapter.last!;
}

void main() {
  group('AuthInterceptor', () {
    test('トークンを Bearer で付ける', () async {
      final request = await _send('secret');
      expect(request.headers['Authorization'], 'Bearer secret');
    });

    test('トークンが無ければヘッダーを付けない', () async {
      // 未ログインで叩ける API（meta など）に空の Bearer を送らない
      final request = await _send(null);
      expect(request.headers.containsKey('Authorization'), isFalse);
    });
  });
}
