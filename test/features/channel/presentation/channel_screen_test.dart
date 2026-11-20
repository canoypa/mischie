import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mischie/features/channel/domain/channel.dart';
import 'package:mischie/features/channel/domain/channel_notifier.dart';
import 'package:mischie/features/channel/presentation/channel_screen.dart';
import 'package:mischie/features/compose/data/draft_store.dart';
import 'package:mischie/features/compose/domain/draft_notifier.dart';
import 'package:mischie/features/compose/presentation/compose_screen.dart';

class _Drafts extends DraftsNotifier {
  @override
  Future<List<Draft>> build() async => const [];
}

Future<void> _pump(WidgetTester tester, Channel channel) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        channelProvider(channel.id).overrideWith((ref) async => channel),
        draftsProvider.overrideWith(_Drafts.new),
      ],
      child: MaterialApp(home: ChannelScreen(channelId: channel.id)),
    ),
  );
  // 投稿一覧は取得先が無く読み込み中のままなので、settle を待てない
  await tester.pump();
  await tester.pump(const Duration(seconds: 1));
}

void main() {
  testWidgets('投稿ボタンはそのチャンネルを投稿先にした投稿画面を開く', (tester) async {
    await _pump(tester, const Channel(id: 'ch1', name: 'お絵かき'));

    await tester.tap(find.byTooltip('チャンネルに投稿'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    final compose = tester.widget<ComposeScreen>(find.byType(ComposeScreen));
    expect(compose.channel?.id, 'ch1');
    expect(compose.channel?.name, 'お絵かき');
  });

  testWidgets('アーカイブされたチャンネルには投稿ボタンを出さない', (tester) async {
    await _pump(
      tester,
      const Channel(id: 'ch1', name: '昔の部屋', isArchived: true),
    );

    expect(find.byTooltip('チャンネルに投稿'), findsNothing);
  });
}
