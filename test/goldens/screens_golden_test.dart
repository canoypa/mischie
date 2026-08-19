import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mischie/core/providers/core_providers.dart';
import 'package:mischie/core/storage/account_store.dart';
import 'package:mischie/features/auth/domain/account.dart';
import 'package:mischie/features/channel/domain/channel.dart';
import 'package:mischie/features/channel/domain/channel_notifier.dart';
import 'package:mischie/features/channel/presentation/channel_list.dart';
import 'package:mischie/features/compose/data/draft_store.dart';
import 'package:mischie/features/compose/domain/draft_notifier.dart';
import 'package:mischie/features/compose/presentation/compose_screen.dart';

/// 画面まるごとの見た目を、実機を繋がずに確かめるためのゴールデン。
///
/// 更新するとき: flutter test test/goldens --update-goldens
class _EmptyAccountStore implements AccountStore {
  @override
  Future<List<Account>> readAccounts() async => const [];
  @override
  Future<String?> readActiveId() async => null;
  @override
  Future<void> writeAccounts(List<Account> accounts) async {}
  @override
  Future<void> writeActiveId(String? id) async {}
  @override
  Future<void> clear() async {}
}

/// 下書きはファイルに触るので、テストでは何も持たないものに差し替える。
class _EmptyDraftStore implements DraftStore {
  @override
  Future<List<Draft>> load() async => const [];
  @override
  Future<List<Draft>> put(Draft draft) async => const [];
  @override
  Future<List<Draft>> remove(String id) async => const [];
}

Future<void> _loadFont(String family, String path) async {
  final file = File(path);
  if (!await file.exists()) return;
  final loader = FontLoader(family)
    ..addFont(file.readAsBytes().then((b) => ByteData.view(b.buffer)));
  await loader.load();
}

Future<void> _pump(
  WidgetTester tester,
  Widget child, {
  // Riverpod 3 の Override 型は公開されていないので、型を書かずに受けて
  // ProviderScope へ渡すときに変換する
  List<dynamic> overrides = const [],
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        accountStoreProvider.overrideWithValue(_EmptyAccountStore()),
        ...overrides.cast(),
      ],
      child: MaterialApp(
        theme: ThemeData(
          useMaterial3: true,
          colorSchemeSeed: const Color(0xFFA8E800),
        ),
        home: child,
      ),
    ),
  );
  await tester.pump();
}

Channel _channel(
  String name, {
  String? description,
  bool isFollowing = false,
}) => Channel(
  id: name,
  name: name,
  description: description,
  usersCount: 244,
  notesCount: 57647,
  isFollowing: isFollowing,
);

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

  testWidgets('投稿画面', (tester) async {
    await _pump(
      tester,
      const ComposeScreen(),
      overrides: [draftStoreProvider.overrideWithValue(_EmptyDraftStore())],
    );
    await tester.pump();

    await expectLater(
      find.byType(ComposeScreen),
      matchesGoldenFile('compose_screen.png'),
    );
  });

  testWidgets('チャンネル一覧', (tester) async {
    await _pump(
      tester,
      const Scaffold(body: ChannelResults(query: '')),
      overrides: [
        followedChannelsProvider.overrideWith(
          (ref) async => [_channel('艦これ部', isFollowing: true)],
        ),
        featuredChannelsProvider.overrideWith(
          (ref) async => [
            _channel('お絵かき', description: '絵を描く人の集まり'),
            _channel('ゲーム'),
          ],
        ),
      ],
    );
    await tester.pump();

    await expectLater(
      find.byType(ChannelResults),
      matchesGoldenFile('channel_list.png'),
    );
  });
}
