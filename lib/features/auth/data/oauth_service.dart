import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:app_links/app_links.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';

const _clientId = 'https://mischie.tepbyte.dev/';
const _redirectUri = 'mischie://oauth/callback';

/// 足りないと該当操作が 403 になる。トークンは発行時のスコープで固定されるため、
/// 増やしたら再ログインが要る。
const _scopes =
    'read:account '
    'write:account '
    'read:notifications '
    'write:notifications '
    'write:notes '
    'read:reactions '
    'write:reactions '
    'read:following '
    'write:following '
    'read:drive '
    'write:drive '
    'read:mutes '
    'write:mutes '
    'read:blocks '
    'write:blocks '
    'read:favorites '
    'write:favorites '
    'read:clip-favorite '
    'write:clip-favorite '
    'read:channels '
    'write:channels '
    'write:votes '
    'write:report-abuse '
    'read:federation';

/// ログインの途中でユーザーがやめた。エラーとしては知らせない。
class OAuthCancelledException implements Exception {
  const OAuthCancelledException();
}

class OAuthService {
  /// ブラウザからの戻りを待っているログイン。キャンセルと、二重に始めた
  /// ときの前のログインの打ち切りに使う。
  Completer<String>? _pending;

  void cancel() {
    final pending = _pending;
    if (pending != null && !pending.isCompleted) {
      pending.completeError(const OAuthCancelledException());
    }
  }

  Future<({String host, String accessToken})> login(String host) async {
    final codeVerifier = generateCodeVerifier();
    final codeChallenge = generateCodeChallenge(codeVerifier);
    final state = const Uuid().v4();

    final authEndpoint = Uri.https(host, '/oauth/authorize', {
      'response_type': 'code',
      'client_id': _clientId,
      'redirect_uri': _redirectUri,
      'scope': _scopes,
      'state': state,
      'code_challenge': codeChallenge,
      'code_challenge_method': 'S256',
    });

    final result = await _authenticateWithSystemBrowser(
      authEndpoint: authEndpoint,
      state: state,
    );

    final uri = Uri.parse(result);
    final returnedState = uri.queryParameters['state'];
    if (returnedState != state) {
      throw Exception('OAuth state mismatch');
    }

    final code = uri.queryParameters['code'];
    if (code == null) {
      throw Exception('No authorization code in callback');
    }

    final tokenResponse = await http.post(
      Uri.https(host, '/oauth/token'),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {
        'grant_type': 'authorization_code',
        'client_id': _clientId,
        'redirect_uri': _redirectUri,
        'code': code,
        'code_verifier': codeVerifier,
      },
    );

    if (tokenResponse.statusCode != 200) {
      throw Exception('Token exchange failed: ${tokenResponse.body}');
    }

    final tokenJson = jsonDecode(tokenResponse.body) as Map<String, dynamic>;
    final accessToken = tokenJson['access_token'] as String?;
    if (accessToken == null) {
      throw Exception('No access_token in response');
    }

    return (host: host, accessToken: accessToken);
  }

  /// OAuth は外部ブラウザで行い、`mischie://oauth/callback` のディープリンクで戻る。
  /// スキームは AndroidManifest で受ける。
  Future<String> _authenticateWithSystemBrowser({
    required Uri authEndpoint,
    required String state,
  }) async {
    cancel();
    final appLinks = AppLinks();
    final completer = _pending = Completer<String>();
    final subscription = appLinks.uriLinkStream.listen((uri) {
      if (uri.scheme == 'mischie' && uri.queryParameters['state'] == state) {
        if (!completer.isCompleted) {
          completer.complete(uri.toString());
        }
      }
    });

    try {
      final launched = await launchUrl(
        authEndpoint,
        mode: LaunchMode.externalApplication,
      );
      if (!launched) {
        throw Exception('Failed to open browser for OAuth');
      }

      return await completer.future.timeout(
        const Duration(minutes: 5),
        onTimeout: () => throw Exception('OAuth timed out'),
      );
    } finally {
      if (identical(_pending, completer)) _pending = null;
      await subscription.cancel();
    }
  }

  @visibleForTesting
  String generateCodeVerifier() {
    final random = Random.secure();
    final bytes = List<int>.generate(32, (_) => random.nextInt(256));
    return base64UrlEncode(bytes).replaceAll('=', '');
  }

  @visibleForTesting
  String generateCodeChallenge(String verifier) {
    final bytes = utf8.encode(verifier);
    final digest = sha256.convert(bytes);
    return base64UrlEncode(digest.bytes).replaceAll('=', '');
  }
}
