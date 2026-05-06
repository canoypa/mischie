import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mischie/core/error/error_handler.dart';

void main() {
  group('resolveErrorMessage', () {
    DioException makeDio({int? statusCode, DioExceptionType? type}) {
      return DioException(
        requestOptions: RequestOptions(),
        response: statusCode != null
            ? Response(
                requestOptions: RequestOptions(),
                statusCode: statusCode,
              )
            : null,
        type: type ?? DioExceptionType.unknown,
      );
    }

    test('401 → 認証エラー', () {
      expect(
        resolveErrorMessage(makeDio(statusCode: 401)),
        '認証エラー: 再ログインしてください',
      );
    });

    test('403 → アクセス権なし', () {
      expect(
        resolveErrorMessage(makeDio(statusCode: 403)),
        'アクセス権がありません',
      );
    });

    test('429 → リクエスト過多', () {
      expect(
        resolveErrorMessage(makeDio(statusCode: 429)),
        'リクエストが多すぎます。しばらくお待ちください',
      );
    });

    test('500 → サーバーエラー', () {
      expect(
        resolveErrorMessage(makeDio(statusCode: 500)),
        'サーバーエラーが発生しました (500)',
      );
    });

    test('503 → サーバーエラー', () {
      expect(
        resolveErrorMessage(makeDio(statusCode: 503)),
        'サーバーエラーが発生しました (503)',
      );
    });

    test('connectionTimeout → タイムアウト', () {
      expect(
        resolveErrorMessage(makeDio(type: DioExceptionType.connectionTimeout)),
        '接続がタイムアウトしました',
      );
    });

    test('receiveTimeout → タイムアウト', () {
      expect(
        resolveErrorMessage(makeDio(type: DioExceptionType.receiveTimeout)),
        '接続がタイムアウトしました',
      );
    });

    test('connectionError → ネットワーク接続不可', () {
      expect(
        resolveErrorMessage(makeDio(type: DioExceptionType.connectionError)),
        'ネットワークに接続できません',
      );
    });

    test('その他の DioException → 汎用エラー', () {
      expect(
        resolveErrorMessage(makeDio()),
        'エラーが発生しました',
      );
    });

    test('非 DioException → 汎用エラー', () {
      expect(resolveErrorMessage(Exception('unknown')), 'エラーが発生しました');
    });
  });
}
