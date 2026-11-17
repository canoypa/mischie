import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
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
    // ログイン前に notifier を読むと、ストリーミングが立ち上がってしまう。
    if (ref.read(authNotifierProvider).value is! AuthStateAuthenticated) {
      return;
    }
    // バックグラウンド中の切断は検知できないため、復帰時は常に張り直す。
    ref.read(timelineNotifierProvider.notifier).resumeStreaming();
    ref.read(notificationNotifierProvider.notifier).resumeStreaming();
  }

  @override
  void dispose() {
    _lifecycleListener?.dispose();
    super.dispose();
  }

  static ThemeData _theme(Brightness brightness) => ThemeData(
    useMaterial3: true,
    colorSchemeSeed: const Color(0xFFA8E800),
    brightness: brightness,
    bottomSheetTheme: const BottomSheetThemeData(showDragHandle: true),
  );

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(appRouterProvider);
    return MaterialApp.router(
      title: 'Mischie',
      theme: _theme(Brightness.light),
      darkTheme: _theme(Brightness.dark),
      themeMode: ThemeMode.system,
      // 画面の文言に合わせて、標準部品も日本語にする
      locale: const Locale('ja'),
      supportedLocales: const [Locale('ja')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      routerConfig: router,
    );
  }
}
