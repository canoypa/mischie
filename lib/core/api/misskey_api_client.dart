import 'package:dio/dio.dart';
import 'package:mischie/core/api/auth_interceptor.dart';

class MisskeyApiClient {
  MisskeyApiClient({
    required String host,
    required Future<String?> Function() getToken,
  }) : _dio = Dio(
         BaseOptions(
           baseUrl: 'https://$host/api/',
           contentType: 'application/json',
         ),
       ) {
    _dio.interceptors.add(AuthInterceptor(getToken));
  }

  final Dio _dio;

  Future<Map<String, dynamic>> post(
    String path, {
    Map<String, dynamic>? body,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      path,
      data: body ?? {},
    );
    return response.data!;
  }

  /// レスポンス本文を使わないエンドポイント用。
  /// Misskey は成功時に 204 No Content を返すものが多く、`post` では
  /// `response.data!` が null で落ちるため分けている。
  Future<void> postVoid(String path, {Map<String, dynamic>? body}) async {
    await _dio.post<dynamic>(path, data: body ?? {});
  }

  Future<List<Map<String, dynamic>>> postList(
    String path, {
    Map<String, dynamic>? body,
  }) async {
    final response = await _dio.post<List<dynamic>>(path, data: body ?? {});
    return response.data!.cast<Map<String, dynamic>>();
  }
}
