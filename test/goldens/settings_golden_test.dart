import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import '../support/golden_support.dart';
import 'package:mischie/core/providers/core_providers.dart';
import 'package:mischie/features/auth/domain/account.dart';
import 'package:mischie/features/settings/presentation/settings_screen.dart';

const _accounts = [
  Account(
    host: 'example.com',
    accessToken: 't1',
    userId: 'u1',
    username: 'alice',
    name: 'Alice',
  ),
  Account(
    host: 'example.org',
    accessToken: 't2',
    userId: 'u2',
    username: 'alice',
    name: 'Alice (サブ)',
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
