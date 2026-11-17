import 'package:dio/dio.dart';

String resolveErrorMessage(Object error) {
  if (error is DioException) {
    final statusCode = error.response?.statusCode;
    if (statusCode == 401) return '認証エラー: 再ログインしてください';
    if (statusCode == 403) {
      // PERMISSION_DENIED は再ログインで直るため、その手順まで示す。
      final code = misskeyErrorCode(error);
      if (code == 'PERMISSION_DENIED') {
        return '権限が足りません。設定の「アカウントを追加」から同じサーバーにログインし直してください';
      }
      return 'アクセス権がありません';
    }
    if (statusCode == 429) return 'リクエストが多すぎます。しばらくお待ちください';
    if (statusCode != null && statusCode >= 500) {
      return 'サーバーエラーが発生しました ($statusCode)';
    }
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout) {
      return '接続がタイムアウトしました';
    }
    if (error.type == DioExceptionType.connectionError) {
      return 'ネットワークに接続できません';
    }
  }
  return 'エラーが発生しました';
}

String? misskeyErrorCode(DioException error) {
  final data = error.response?.data;
  if (data is! Map) return null;
  final body = data['error'];
  return body is Map ? body['code'] as String? : null;
}
