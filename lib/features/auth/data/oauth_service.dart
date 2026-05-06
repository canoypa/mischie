import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

const _clientId = 'https://mischie.tepbyte.dev/';
const _redirectUri = 'mischie://oauth/callback';
const _scopes = 'read:account write:notes read:notifications';

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

    final result = await FlutterWebAuth2.authenticate(
      url: authEndpoint.toString(),
      callbackUrlScheme: 'mischie',
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
