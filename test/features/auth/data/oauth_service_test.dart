import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mischie/features/auth/data/oauth_service.dart';

void main() {
  final service = OAuthService();

  group('generateCodeVerifier', () {
    test('Base64URL 文字のみで構成される', () {
      final verifier = service.generateCodeVerifier();
      expect(verifier, matches(RegExp(r'^[A-Za-z0-9\-_]+$')));
    });

    test('パディング文字(=)を含まない', () {
      final verifier = service.generateCodeVerifier();
      expect(verifier, isNot(contains('=')));
    });

    test('呼び出すたびに異なる値を返す', () {
      final v1 = service.generateCodeVerifier();
      final v2 = service.generateCodeVerifier();
      expect(v1, isNot(v2));
    });
  });

  group('generateCodeChallenge', () {
    test('S256: SHA-256 の Base64URL エンコード', () {
      const verifier = 'test_verifier_string';
      final challenge = service.generateCodeChallenge(verifier);

      // 期待値を手動計算
      final hash = sha256.convert(utf8.encode(verifier));
      final expected = base64UrlEncode(hash.bytes).replaceAll('=', '');

      expect(challenge, expected);
    });

    test('パディング文字(=)を含まない', () {
      final verifier = service.generateCodeVerifier();
      final challenge = service.generateCodeChallenge(verifier);
      expect(challenge, isNot(contains('=')));
    });

    test('同じ verifier から常に同じ challenge が生成される', () {
      const verifier = 'fixed_verifier';
      expect(
        service.generateCodeChallenge(verifier),
        service.generateCodeChallenge(verifier),
      );
    });
  });
}
