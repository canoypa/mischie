import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mischie/features/timeline/presentation/note_card.dart';
import '../support/golden_support.dart';
import 'package:mischie/features/timeline/domain/drive_file.dart';
import 'package:mischie/features/timeline/domain/note.dart';
import 'package:mischie/features/timeline/domain/user.dart';

/// 実機を繋がずにノートの見た目を確かめるためのゴールデン。
///
/// ウィジェットプレビューは web 環境で動くため、セキュアストレージや
/// 画像キャッシュに触れる NoteCard は載せられない。こちらはテスト環境で
/// 動くので、プロバイダーを差し替えれば素のまま描ける。
///
/// 更新するとき: flutter test test/goldens --update-goldens
Note _note({
  String? text = 'ノートの本文です。ここに書いた内容がそのまま出ます。',
  Poll? poll,
  List<DriveFile> files = const [],
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
  files: files,
  myReaction: myReaction,
  repliesCount: repliesCount,
  renoteCount: renoteCount,
);

/// ノートを並べて描く。カード自体の見た目を見るためのもの。
Future<void> _pumpNotes(
  WidgetTester tester,
  List<Note> notes, {
  Brightness brightness = Brightness.light,
}) => pumpGolden(
  tester,
  Scaffold(
    body: ListView(
      children: [
        for (final note in notes) NoteCard(note: note, serverEmojis: const {}),
      ],
    ),
  ),
  brightness: brightness,
);

void main() {
  setUpAll(loadGoldenFonts);

  testWidgets('ノートの基本形', (tester) async {
    await _pumpNotes(tester, [
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

  testWidgets('画像以外の添付', (tester) async {
    // 画像しか出していなかったため、動画や音声だけのノートは添付が
    // 無かったことになっていた
    await _pumpNotes(tester, [
      _note(
        text: '動画つき',
        files: const [
          DriveFile(
            id: 'f1',
            type: 'video/mp4',
            url: 'https://example.com/v.mp4',
            name: '海.mp4',
          ),
        ],
      ),
      _note(
        text: '音声とファイル',
        files: const [
          DriveFile(
            id: 'f2',
            type: 'audio/mpeg',
            url: 'https://example.com/a.mp3',
            name: 'demo.mp3',
          ),
          DriveFile(
            id: 'f3',
            type: 'application/pdf',
            url: 'https://example.com/d.pdf',
            name: '資料.pdf',
          ),
        ],
      ),
    ]);

    await expectLater(
      find.byType(ListView),
      matchesGoldenFile('attachments.png'),
    );
  });

  testWidgets('投票', (tester) async {
    await _pumpNotes(tester, [
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
    await _pumpNotes(tester, [
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
