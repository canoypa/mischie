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

  /// ファイルアップロード用。Misskey のドライブは multipart/form-data を取る。
  Future<Map<String, dynamic>> postMultipart(
    String path, {
    required String filePath,
    String? fileName,
  }) async {
    final form = FormData.fromMap({
      'file': await MultipartFile.fromFile(
        filePath,
        filename: fileName ?? filePath.split('/').last,
      ),
    });
    final response = await _dio.post<Map<String, dynamic>>(path, data: form);
    return response.data!;
  }

  Future<List<Map<String, dynamic>>> postList(
    String path, {
    Map<String, dynamic>? body,
  }) async {
    final response = await _dio.post<List<dynamic>>(path, data: body ?? {});
    return response.data!.cast<Map<String, dynamic>>();
  }
}
