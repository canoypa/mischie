import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mischie/app.dart';
import 'package:timeago/timeago.dart' as timeago;

void main() {
  timeago.setLocaleMessages('ja', timeago.JaMessages());
  runApp(const ProviderScope(child: MischieApp()));
}
