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

/// 要求するスコープ。
///
/// エンドポイントごとの必要権限は API 仕様（/api.json の各 description に
/// ある **Permission**）から拾ったもの。足りないと該当操作だけが 403 で
/// 落ちるうえ、トークンは発行時のスコープで固定されるため、増やしたときは
/// 再ログインが要る。
const _scopes =
    'read:account '
    'read:notifications '
    'write:notes '
    'write:reactions '
    'write:following '
    'write:drive '
    'write:mutes '
    'write:blocks '
    'write:channels';

class OAuthService {
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

  /// OAuth callback via the external system browser + OS deep link.
  ///
  /// Per RFC 8252 ("OAuth 2.0 for Native Apps") we open the authorize URL in
  /// the external browser and listen for the `mischie://oauth/callback` deep
  /// link. This deliberately avoids `flutter_web_auth_2`'s in-app tab: its 5.x
  /// AuthTab default silently fails to deliver the callback on some Chrome
  /// builds (login hangs with no error), and 4.x no longer compiles against the
  /// current Android (AGP namespace) toolchain. The `mischie://` scheme is
  /// routed to MainActivity (see AndroidManifest) and surfaced through
  /// `app_links`.
  Future<String> _authenticateWithSystemBrowser({
    required Uri authEndpoint,
    required String state,
  }) async {
    final appLinks = AppLinks();
    final completer = Completer<String>();
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
