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
  Note? renote,
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
  renote: renote,
  files: files,
  myReaction: myReaction,
  repliesCount: repliesCount,
  renoteCount: renoteCount,
);

// 添付は画像以外（PDF）にする。画像はテスト環境で実際にネットワークへ
// 取りに行こうとしてしまい、ゴールデン比較の待ち時間の間にプラグイン
// 未実装のエラーで落ちる（このテスト環境の既知の制約）。件数だけ
// 十分あれば、画像と同じく「本文とは無関係に添付だけで閾値を超える」
// 状況を安全に再現できる。
List<DriveFile> _pdfFiles(int count) => [
  for (var i = 1; i <= count; i++)
    DriveFile(
      id: 'm$i',
      type: 'application/pdf',
      url: 'https://example.com/$i.pdf',
      name: '資料$i.pdf',
    ),
];

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

  testWidgets('リノートと引用', (tester) async {
    final original = Note(
      id: 'orig',
      createdAt: DateTime.now().toIso8601String(),
      user: const User(id: 'u2', username: 'other', name: '元の人'),
      text: '元のノートの本文',
    );

    await _pumpNotes(tester, [
      // 本文なしの純粋なリノート
      _note(text: null, renote: original),
      // 本文つき = 引用。元ノートを埋め込んで出す
      _note(text: 'これは引用です', renote: original),
      // 引用ノートをリノートした場合。引用元まで辿れないと文脈が切れる
      _note(
        text: null,
        renote: _note(text: '引用のコメント', renote: original),
      ),
    ]);

    await expectLater(
      find.byType(ListView),
      matchesGoldenFile('renote_quote.png'),
    );
  });

  final longNameQuote = Note(
    id: 'q1',
    createdAt: DateTime.now().toIso8601String(),
    user: const User(
      id: 'u3',
      username: 'remote',
      name: 'とても長い表示名でここが省略されて見えるかを確かめる人',
      host: 'misskey.example',
    ),
    text: '短い本文',
  );
  final imagesOnlyQuote = Note(
    id: 'q2',
    createdAt: DateTime.now().toIso8601String(),
    user: const User(id: 'u4', username: 'photo', name: '写真だけの人'),
    text: null,
    files: const [
      DriveFile(
        id: 'qf1',
        type: 'image/png',
        url: 'https://example.com/1.png',
        name: '1.png',
      ),
      DriveFile(
        id: 'qf2',
        type: 'image/png',
        url: 'https://example.com/2.png',
        name: '2.png',
      ),
    ],
  );
  final cwQuote = Note(
    id: 'q3',
    createdAt: DateTime.now().toIso8601String(),
    user: const User(id: 'u5', username: 'cwuser', name: 'CW の人'),
    cw: 'ネタバレ',
    text: '隠れているはずの本文',
  );
  final longTextQuote = Note(
    id: 'q4',
    createdAt: DateTime.now().toIso8601String(),
    user: const User(id: 'u6', username: 'writer', name: '長文の人'),
    text: List.generate(10, (i) => '長い本文の ${i + 1} 行目です。').join('\n'),
  );
  final pollQuote = Note(
    id: 'q5',
    createdAt: DateTime.now().toIso8601String(),
    user: const User(id: 'u7', username: 'voter', name: '投票の人'),
    text: '投票つき',
    poll: const Poll(
      choices: [
        PollChoice(text: 'きのこ', votes: 3),
        PollChoice(text: 'たけのこ', votes: 5),
      ],
    ),
    files: const [
      DriveFile(
        id: 'qf3',
        type: 'application/pdf',
        url: 'https://example.com/d.pdf',
        name: '資料.pdf',
      ),
    ],
  );

  testWidgets('引用の中身', (tester) async {
    // 縦に積むとテスト用の描画面(800x600)をすぐ超えるため、5パターンを
    // 3枚に分けて確かめる。
    await _pumpNotes(tester, [
      _note(text: '引用', renote: longNameQuote),
      _note(text: '引用', renote: imagesOnlyQuote),
    ]);

    await expectLater(
      find.byType(ListView),
      matchesGoldenFile('quote_contents.png'),
    );
  });

  testWidgets('引用の中身（CWと投票）', (tester) async {
    await _pumpNotes(tester, [
      _note(text: '引用', renote: cwQuote),
      _note(text: '引用', renote: pollQuote),
    ]);

    await expectLater(
      find.byType(ListView),
      matchesGoldenFile('quote_contents_cw_poll.png'),
    );
  });

  testWidgets('引用の中身（長文）', (tester) async {
    await _pumpNotes(tester, [_note(text: '引用', renote: longTextQuote)]);

    await expectLater(
      find.byType(ListView),
      matchesGoldenFile('quote_contents_long.png'),
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

  testWidgets('高さが添付だけから来るときは畳まない', (tester) async {
    // 本文は短いが、添付の並びだけで高さの閾値(320)を超える。以前はこの
    // 高さを理由に本文と一緒に畳まれていた。
    await _pumpNotes(tester, [_note(text: '資料です', files: _pdfFiles(8))]);

    await expectLater(
      find.byType(ListView),
      matchesGoldenFile('media_not_collapsed.png'),
    );
  });

  testWidgets('本文が長いときは本文だけ畳み、添付は見えたままにする', (tester) async {
    await _pumpNotes(tester, [
      _note(
        text: List.generate(30, (i) => '長い本文の ${i + 1} 行目です。').join('\n'),
        files: _pdfFiles(2),
      ),
    ]);

    await expectLater(
      find.byType(ListView),
      matchesGoldenFile('text_collapsed_media_visible.png'),
    );
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
