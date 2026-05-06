import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mischie/router/app_router.dart';

class MischieApp extends ConsumerWidget {
  const MischieApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    return MaterialApp.router(
      title: 'mischie',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFFA8E800),
      ),
      routerConfig: router,
    );
  }
}
