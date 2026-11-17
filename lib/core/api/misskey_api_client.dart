import 'package:dio/dio.dart';
import 'package:mischie/core/api/auth_interceptor.dart';

class MisskeyApiClient {
  MisskeyApiClient({
    required this.host,
    required Future<String?> Function() getToken,
    void Function(String path)? onRequest,
  }) : _dio = Dio(
         BaseOptions(
           baseUrl: 'https://$host/api/',
           contentType: 'application/json',
         ),
       ) {
    _dio.interceptors.add(AuthInterceptor(getToken));
    if (onRequest != null) {
      _dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            onRequest(options.path);
            handler.next(options);
          },
        ),
      );
    }
  }

  final String host;

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

  /// 成功時に本文を返さないエンドポイント用。`post` は本文が無いと落ちる。
  Future<void> postVoid(String path, {Map<String, dynamic>? body}) async {
    await _dio.post<dynamic>(path, data: body ?? {});
  }

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
