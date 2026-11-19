import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mischie/core/navigation/link_handler.dart';
import 'package:mischie/features/auth/domain/auth_notifier.dart';
import 'package:mischie/features/channel/domain/channel_notifier.dart';
import 'package:mischie/features/channel/presentation/channel_screen.dart';
import 'package:mischie/features/search/domain/search_notifier.dart';
import 'package:mischie/features/search/presentation/hashtag_screen.dart';

Future<void> _openLink(WidgetTester tester, String url) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        currentHostProvider.overrideWithValue('misskey.example'),
        // 画面の中身は取りに行かせない。遷移先だけを見る
        channelRepositoryProvider.overrideWithValue(null),
        searchRepositoryProvider.overrideWithValue(null),
      ],
      child: MaterialApp(
        home: Consumer(
          builder: (context, ref, _) => TextButton(
            onPressed: () => openLink(context, ref, url),
            child: const Text('link'),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('link'));
  await tester.pump();
  await tester.pump(const Duration(seconds: 1));
}

void main() {
  testWidgets('自サーバーのハッシュタグのリンクはアプリのタグ画面で開く', (tester) async {
    await _openLink(tester, 'https://misskey.example/tags/flutter');

    final screen = tester.widget<HashtagScreen>(find.byType(HashtagScreen));
    expect(screen.tag, 'flutter');
  });

  testWidgets('エンコードされたタグはデコードして開く', (tester) async {
    await _openLink(
      tester,
      'https://misskey.example/tags/%E3%81%8A%E7%B5%B5%E6%8F%8F%E3%81%8D',
    );

    final screen = tester.widget<HashtagScreen>(find.byType(HashtagScreen));
    expect(screen.tag, 'お絵描き');
  });

  testWidgets('自サーバーのチャンネルのリンクはアプリのチャンネル画面で開く', (tester) async {
    await _openLink(tester, 'https://misskey.example/channels/9abcdef');

    final screen = tester.widget<ChannelScreen>(find.byType(ChannelScreen));
    expect(screen.channelId, '9abcdef');
  });
}
