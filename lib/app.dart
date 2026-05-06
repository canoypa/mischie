import 'package:flutter/material.dart';
import 'package:mischie/router/app_router.dart';

class MischieApp extends StatelessWidget {
  const MischieApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'mischie',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFFA8E800),
      ),
      routerConfig: appRouter,
    );
  }
}
