import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mischie/features/notification/domain/push_notifier.dart';
import 'package:mischie/router/app_router.dart';

class MischieApp extends ConsumerStatefulWidget {
  const MischieApp({super.key});

  @override
  ConsumerState<MischieApp> createState() => _MischieAppState();
}

class _MischieAppState extends ConsumerState<MischieApp> {
  @override
  void initState() {
    super.initState();
    // 受信ハンドラを繋ぐだけ。購読は設定で有効にしたときだけ走る。
    ref.read(pushServiceProvider).initialize();
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(appRouterProvider);
    return MaterialApp.router(
      title: 'Mischie',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFFA8E800),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFFA8E800),
        brightness: Brightness.dark,
      ),
      themeMode: ThemeMode.system,
      routerConfig: router,
    );
  }
}
