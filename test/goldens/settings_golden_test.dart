import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import '../support/golden_support.dart';
import 'package:mischie/core/providers/core_providers.dart';
import 'package:mischie/features/auth/domain/account.dart';
import 'package:mischie/features/settings/presentation/settings_screen.dart';

/// 設定画面の見た目。アカウント切り替えは並びが崩れても気づきにくいので、
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

void main() {
  setUpAll(loadGoldenFonts);

  testWidgets('設定（アカウント切り替え）', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          accountStoreProvider.overrideWithValue(
            FakeAccountStore(accounts: _accounts),
          ),
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
