import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mischie/core/providers/core_providers.dart';
import 'package:mischie/features/auth/data/oauth_service.dart';
import 'package:mischie/features/auth/domain/auth_state.dart';

final oauthServiceProvider = Provider<OAuthService>(
  (ref) => OAuthService(),
);

final authNotifierProvider =
    AsyncNotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);

class AuthNotifier extends AsyncNotifier<AuthState> {
  @override
  Future<AuthState> build() async {
    final storage = ref.watch(tokenStorageProvider);
    final token = await storage.readAccessToken();
    final host = await storage.readServerHost();

    if (token != null && host != null) {
      return AuthState.authenticated(host: host, accessToken: token);
    }
    return const AuthState.unauthenticated();
  }

  Future<void> login(String host) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final oauth = ref.read(oauthServiceProvider);
      final result = await oauth.login(host);

      final storage = ref.read(tokenStorageProvider);
      await storage.writeServerHost(result.host);
      await storage.writeAccessToken(result.accessToken);

      ref.invalidate(misskeyApiClientProvider);

      return AuthState.authenticated(
        host: result.host,
        accessToken: result.accessToken,
      );
    });
  }

  Future<void> logout() async {
    final storage = ref.read(tokenStorageProvider);
    await storage.clear();
    ref.invalidate(misskeyApiClientProvider);
    state = const AsyncValue.data(AuthState.unauthenticated());
  }
}
