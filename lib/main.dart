import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mischie/app.dart';
import 'package:timeago/timeago.dart' as timeago;

void main() {
  timeago.setLocaleMessages('ja', timeago.JaMessages());
  runApp(
    ProviderScope(
      // 失敗はすぐエラー表示にし、やり直しはユーザーの操作に任せる
      retry: (retryCount, error) => null,
      child: const MischieApp(),
    ),
  );
}
