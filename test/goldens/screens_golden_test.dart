@Tags(['golden'])
library;

import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import '../support/golden_support.dart';
import 'package:mischie/features/channel/domain/channel.dart';
import 'package:mischie/features/channel/domain/channel_notifier.dart';
import 'package:mischie/features/channel/presentation/channel_list.dart';
import 'package:mischie/features/compose/data/draft_store.dart';
import 'package:mischie/features/compose/domain/draft_notifier.dart';
import 'package:mischie/features/compose/presentation/compose_screen.dart';

class _EmptyDraftStore implements DraftStore {
  @override
  Future<List<Draft>> load() async => const [];
  @override
  Future<List<Draft>> put(Draft draft) async => const [];
  @override
  Future<List<Draft>> remove(String id) async => const [];
}

Channel _channel(
  String name, {
  String? description,
  bool isFollowing = false,
}) => Channel(
  id: name,
  name: name,
  description: description,
  usersCount: 100,
  notesCount: 1000,
  isFollowing: isFollowing,
);

void main() {
  setUpAll(loadGoldenFonts);

  testWidgets('投稿画面', (tester) async {
    await pumpGolden(
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

  testWidgets('投稿画面（投票つき）', (tester) async {
    await pumpGolden(
      tester,
      const ComposeScreen(),
      overrides: [draftStoreProvider.overrideWithValue(_EmptyDraftStore())],
    );
    await tester.pump();

    await tester.tap(find.byIcon(Icons.poll_outlined).first);
    await tester.pump();

    await expectLater(
      find.byType(ComposeScreen),
      matchesGoldenFile('compose_poll.png'),
    );
  });

  testWidgets('入力補完', (tester) async {
    await pumpGolden(
      tester,
      const ComposeScreen(),
      overrides: [draftStoreProvider.overrideWithValue(_EmptyDraftStore())],
    );
    await tester.pump();

    // 絵文字候補はテスト環境で画像を読めないので、候補欄は MFM の装飾で確かめる。
    await tester.enterText(find.byType(TextField).last, r'すごい $[j');
    await tester.pump();

    await expectLater(
      find.byType(ComposeScreen),
      matchesGoldenFile('compose_completion.png'),
    );
  });

  testWidgets('チャンネル一覧', (tester) async {
    await pumpGolden(
      tester,
      const Scaffold(body: ChannelResults(query: '')),
      overrides: [
        followedChannelsProvider.overrideWith(
          (ref) async => [_channel('写真部', isFollowing: true)],
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
