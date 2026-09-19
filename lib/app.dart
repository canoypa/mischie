import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mischie/features/auth/domain/auth_notifier.dart';
import 'package:mischie/features/auth/domain/auth_state.dart';
import 'package:mischie/features/notification/domain/notification_notifier.dart';
import 'package:mischie/features/timeline/domain/timeline_notifier.dart';
import 'package:mischie/router/app_router.dart';

class MischieApp extends ConsumerStatefulWidget {
  const MischieApp({super.key});

  @override
  ConsumerState<MischieApp> createState() => _MischieAppState();
}

class _MischieAppState extends ConsumerState<MischieApp> {
  AppLifecycleListener? _lifecycleListener;

  @override
  void initState() {
    super.initState();
    _lifecycleListener = AppLifecycleListener(onResume: _onResume);
  }

  void _onResume() {
    // 未ログイン中は notifier に触れない。ref.read(...notifier) は
    // provider を作ってしまうので、ログイン前に呼ぶとストリーミングが
    // 意図せず立ち上がる。
    if (ref.read(authNotifierProvider).value is! AuthStateAuthenticated) {
      return;
    }
    // バックグラウンド中にソケットがサイレントに死んでいることがあるため、
    // 生きているように見えても張り直して取りこぼしを取り戻す。
    ref.read(timelineNotifierProvider.notifier).resumeStreaming();
    ref.read(notificationNotifierProvider.notifier).resumeStreaming();
  }

  @override
  void dispose() {
    _lifecycleListener?.dispose();
    super.dispose();
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
