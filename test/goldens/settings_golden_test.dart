import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mischie/core/providers/core_providers.dart';
import 'package:mischie/core/storage/account_store.dart';
import 'package:mischie/core/storage/push_store.dart';
import 'package:mischie/features/auth/domain/account.dart';
import 'package:mischie/features/notification/domain/push_notifier.dart';
import 'package:mischie/features/settings/presentation/settings_screen.dart';

/// 設定画面の見た目。アカウント切り替えは新しく足したところなので、
/// 実機に入れる前にここで一度見る。
/// 更新: flutter test test/goldens --update-goldens
const _accounts = [
  Account(
    host: 'misskey.io',
    accessToken: 't1',
    userId: 'u1',
    username: 'cano',
    name: 'Cano',
  ),
  Account(
    host: 'mi.tepbyte.dev',
    accessToken: 't2',
    userId: 'u2',
    username: 'cano',
    name: 'Cano (開発用)',
  ),
];

class _StubAccountStore implements AccountStore {
  @override
  Future<List<Account>> readAccounts() async => _accounts;
  @override
  Future<String?> readActiveId() async => _accounts.first.id;
  @override
  Future<void> writeAccounts(List<Account> accounts) async {}
  @override
  Future<void> writeActiveId(String? id) async {}
  @override
  Future<void> clear() async {}
}

class _StubPushStore implements PushStore {
  @override
  Future<bool> readEnabled() async => false;
  @override
  Future<void> writeEnabled({required bool enabled}) async {}
  @override
  Future<String?> readEndpoint() async => null;
  @override
  Future<void> writeEndpoint(String? endpoint) async {}
}

Future<void> _loadFont(String family, String path) async {
  final file = File(path);
  if (!await file.exists()) return;
  final loader = FontLoader(family)
    ..addFont(file.readAsBytes().then((b) => ByteData.view(b.buffer)));
  await loader.load();
}

void main() {
  setUpAll(() async {
    await _loadFont('Roboto', '/System/Library/Fonts/ヒラギノ角ゴシック W3.ttc');
    final flutterRoot = Platform.environment['FLUTTER_ROOT'];
    if (flutterRoot != null) {
      await _loadFont(
        'MaterialIcons',
        '$flutterRoot/bin/cache/artifacts/material_fonts/'
            'MaterialIcons-Regular.otf',
      );
    }
  });

  testWidgets('設定（アカウント切り替え）', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          accountStoreProvider.overrideWithValue(_StubAccountStore()),
          pushStoreProvider.overrideWithValue(_StubPushStore()),
        ],
        child: MaterialApp(
          theme: ThemeData(
            useMaterial3: true,
            colorSchemeSeed: const Color(0xFFA8E800),
          ),
          home: const SettingsScreen(),
        ),
      ),
    );
    await tester.pump();
    await tester.pump();

    await expectLater(
      find.byType(SettingsScreen),
      matchesGoldenFile('settings_screen.png'),
    );
  });
}
