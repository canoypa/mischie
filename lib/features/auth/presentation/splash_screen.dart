import 'package:flutter/material.dart';

/// 認証状態が決まるまでの繋ぎ。
///
/// Android の起動テーマと同じ背景だけを出す。ここにスピナーを置くと、
/// トークン読み出しは大抵一瞬なので、ちらついて見えるだけになる。
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) => const Scaffold();
}
