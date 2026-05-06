import 'package:dio/dio.dart';

String resolveErrorMessage(Object error) {
  if (error is DioException) {
    final statusCode = error.response?.statusCode;
    if (statusCode == 401) return '認証エラー: 再ログインしてください';
    if (statusCode == 403) return 'アクセス権がありません';
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
