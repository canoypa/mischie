import 'package:flutter/material.dart';

/// 認証状態が決まるまでの繋ぎ。読み出しは一瞬で終わるので、スピナーを置くとちらつくだけになる。
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) => const Scaffold();
}
