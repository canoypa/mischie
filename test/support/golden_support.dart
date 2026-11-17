import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mischie/core/providers/core_providers.dart';
import 'package:mischie/core/storage/account_store.dart';
import 'package:mischie/features/auth/domain/account.dart';
import 'package:timeago/timeago.dart' as timeago;

class FakeAccountStore implements AccountStore {
  FakeAccountStore({this.accounts = const []});

  final List<Account> accounts;

  @override
  Future<List<Account>> readAccounts() async => accounts;

  @override
  Future<String?> readActiveId() async =>
      accounts.isEmpty ? null : accounts.first.id;

  @override
  Future<void> writeAccounts(List<Account> accounts) async {}

  @override
  Future<void> writeActiveId(String? id) async {}

  @override
  Future<void> clear() async {}
}

/// 既定では文字もアイコンも箱で描かれ、見た目を確かめられない。
Future<void> loadGoldenFonts() async {
  timeago.setLocaleMessages('ja', timeago.JaMessages());
  await _loadFont('Roboto', '/System/Library/Fonts/ヒラギノ角ゴシック W3.ttc');
  final flutterRoot = Platform.environment['FLUTTER_ROOT'];
  if (flutterRoot != null) {
    await _loadFont(
      'MaterialIcons',
      '$flutterRoot/bin/cache/artifacts/material_fonts/'
          'MaterialIcons-Regular.otf',
    );
  }
}

Future<void> _loadFont(String family, String path) async {
  final file = File(path);
  if (!await file.exists()) return;
  final loader = FontLoader(family)
    ..addFont(file.readAsBytes().then((b) => ByteData.view(b.buffer)));
  await loader.load();
}

/// アプリと同じテーマで包んで描く。
///
/// overrides は型を書かずに受ける（Riverpod 3 の Override 型は公開されて
/// いないため）。
Future<void> pumpGolden(
  WidgetTester tester,
  Widget child, {
  List<dynamic> overrides = const [],
  Brightness brightness = Brightness.light,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        accountStoreProvider.overrideWithValue(FakeAccountStore()),
        ...overrides.cast(),
      ],
      child: MaterialApp(
        theme: ThemeData(
          useMaterial3: true,
          colorSchemeSeed: const Color(0xFFA8E800),
          brightness: brightness,
        ),
        home: child,
      ),
    ),
  );
  await tester.pump();
}
