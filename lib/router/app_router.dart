import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mischie/features/auth/domain/auth_notifier.dart';
import 'package:mischie/features/auth/domain/auth_state.dart';
import 'package:mischie/features/auth/presentation/login_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authNotifier = ref.watch(authNotifierProvider);

  return GoRouter(
    redirect: (context, state) {
      final authState = authNotifier.value;
      if (authState == null) return null;

      final isLoginRoute = state.matchedLocation == '/login';
      final isAuthenticated = authState is AuthStateAuthenticated;

      if (!isAuthenticated && !isLoginRoute) return '/login';
      if (isAuthenticated && isLoginRoute) return '/';
      return null;
    },
    refreshListenable: _AuthStateListenable(ref, authNotifier),
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) =>
            const Scaffold(body: Center(child: Text('Home'))),
      ),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    ],
  );
});

class _AuthStateListenable extends ChangeNotifier {
  _AuthStateListenable(Ref ref, AsyncValue<AuthState> initial) {
    ref.listen(authNotifierProvider, (prev, next) => notifyListeners());
  }
}
