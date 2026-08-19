import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mischie/core/providers/core_providers.dart';
import 'package:mischie/core/storage/account_store.dart';
import 'package:mischie/features/auth/domain/account.dart';
import 'package:mischie/features/timeline/domain/note.dart';
import 'package:mischie/features/timeline/domain/user.dart';
import 'package:mischie/features/timeline/presentation/note_card.dart';
import 'package:timeago/timeago.dart' as timeago;

/// 実機を繋がずにノートの見た目を確かめるためのゴールデン。
///
/// ウィジェットプレビューは web 環境で動くため、セキュアストレージや
/// 画像キャッシュに触れる NoteCard は載せられない。こちらはテスト環境で
/// 動くので、プロバイダーを差し替えれば素のまま描ける。
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

Note _note({
  String? text = 'ノートの本文です。ここに書いた内容がそのまま出ます。',
  Poll? poll,
  Map<String, int> reactions = const {},
  String? myReaction,
  String? cw,
  int repliesCount = 0,
  int renoteCount = 0,
}) => Note(
  id: 'note1',
  createdAt: DateTime.now()
      .subtract(const Duration(minutes: 5))
      .toIso8601String(),
  user: const User(id: 'u1', username: 'cano', name: 'Cano'),
  text: text,
  cw: cw,
  reactions: reactions,
  poll: poll,
  myReaction: myReaction,
  repliesCount: repliesCount,
  renoteCount: renoteCount,
);

Future<void> _pump(
  WidgetTester tester,
  List<Note> notes, {
  Brightness brightness = Brightness.light,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [accountStoreProvider.overrideWithValue(_EmptyAccountStore())],
      child: MaterialApp(
        theme: ThemeData(
          useMaterial3: true,
          colorSchemeSeed: const Color(0xFFA8E800),
          brightness: brightness,
        ),
        home: Scaffold(
          body: ListView(
            children: [
              for (final note in notes)
                NoteCard(note: note, serverEmojis: const {}),
            ],
          ),
        ),
      ),
    ),
  );
  await tester.pump();
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
    timeago.setLocaleMessages('ja', timeago.JaMessages());
    // テスト環境は既定でフォントを持たず、文字もアイコンも黒い箱になる。
    // 見た目の確認にならないので、本文用とアイコン用を読み込ませる。
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

  testWidgets('ノートの基本形', (tester) async {
    await _pump(tester, [
      _note(repliesCount: 3, renoteCount: 2),
      _note(
        text: 'リアクション付き',
        reactions: {'👍': 4, '❤️': 1, ':kawaii@misskey.io:': 2},
        myReaction: '👍',
      ),
      _note(text: '隠された本文', cw: '閲覧注意の説明'),
    ]);

    await expectLater(
      find.byType(ListView),
      matchesGoldenFile('note_card.png'),
    );
  });

  testWidgets('投票', (tester) async {
    await _pump(tester, [
      // 未投票は押せるボタン、投票済みと締め切り後は結果として出る
      _note(
        text: '投票（未投票）',
        poll: const Poll(
          choices: [
            PollChoice(text: 'きのこ', votes: 3),
            PollChoice(text: 'たけのこ', votes: 5),
          ],
        ),
      ),
      _note(
        text: '投票（投票済み・複数選択可）',
        poll: const Poll(
          multiple: true,
          choices: [
            PollChoice(text: 'きのこ', votes: 3, isVoted: true),
            PollChoice(text: 'たけのこ', votes: 5),
            PollChoice(text: 'どちらでもない', votes: 0),
          ],
        ),
      ),
    ]);

    await expectLater(find.byType(ListView), matchesGoldenFile('poll.png'));
  });

  // ダークでしか出ない問題（色の直書き、コントラスト不足）を拾う
  testWidgets('ノートの基本形 / ダーク', (tester) async {
    await _pump(tester, [
      _note(repliesCount: 3, renoteCount: 2),
      _note(
        text: 'リアクション付き',
        reactions: {'👍': 4, '❤️': 1, ':kawaii@misskey.io:': 2},
        myReaction: '👍',
      ),
      _note(text: '隠された本文', cw: '閲覧注意の説明'),
    ], brightness: Brightness.dark);

    await expectLater(
      find.byType(ListView),
      matchesGoldenFile('note_card_dark.png'),
    );
  });
}
