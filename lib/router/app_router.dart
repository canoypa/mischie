import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mischie/features/auth/domain/auth_notifier.dart';
import 'package:mischie/features/auth/domain/auth_state.dart';
import 'package:mischie/features/auth/presentation/login_screen.dart';
import 'package:mischie/features/auth/presentation/splash_screen.dart';
import 'package:mischie/features/timeline/presentation/home_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authNotifier = ref.watch(authNotifierProvider);
  final authStateListenable = _AuthStateListenable(ref);
  ref.onDispose(authStateListenable.dispose);

  return GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) {
      final authState = authNotifier.value;
      final isSplashRoute = state.matchedLocation == '/splash';

      // 認証状態が分かる前に '/' を描くと、空のタイムラインが一瞬見える。
      if (authState == null) return isSplashRoute ? null : '/splash';

      final isLoginRoute = state.matchedLocation == '/login';
      final isAuthenticated = authState is AuthStateAuthenticated;

      if (!isAuthenticated) return isLoginRoute ? null : '/login';
      if (isLoginRoute || isSplashRoute) return '/';
      return null;
    },
    refreshListenable: authStateListenable,
    routes: [
      GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    ],
  );
});

class _AuthStateListenable extends ChangeNotifier {
  _AuthStateListenable(Ref ref) {
    ref.listen(authNotifierProvider, (prev, next) => notifyListeners());
  }
}
