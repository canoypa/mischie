import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mischie/core/api/misskey_api_client.dart';
import 'package:mischie/features/compose/data/compose_repository.dart';
import 'package:mischie/features/compose/data/draft_store.dart';
import 'package:mischie/features/compose/domain/compose_notifier.dart';
import 'package:mischie/features/compose/domain/draft_notifier.dart';
import 'package:mischie/features/compose/presentation/compose_screen.dart';
import 'package:mischie/features/timeline/domain/drive_file.dart';
import 'package:mischie/features/timeline/domain/note.dart';
import 'package:mischie/features/timeline/domain/user.dart';

class _Client extends MisskeyApiClient {
  _Client() : super(host: 'example.test', getToken: () async => null);

  Map<String, dynamic>? created;

  @override
  Future<Map<String, dynamic>> post(
    String path, {
    Map<String, dynamic>? body,
  }) async {
    if (path == 'notes/create') created = body;
    return {};
  }
}

class _Drafts extends DraftsNotifier {
  @override
  Future<List<Draft>> build() async => const [];

  @override
  Future<void> remove(String id) async {}
}

Future<_Client> _pump(WidgetTester tester, ComposeScreen screen) async {
  final client = _Client();
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        composeRepositoryProvider.overrideWithValue(ComposeRepository(client)),
        draftsProvider.overrideWith(_Drafts.new),
      ],
      child: MaterialApp(home: screen),
    ),
  );
  await tester.pumpAndSettle();
  return client;
}

void main() {
  testWidgets('キーボードが出ていて選択肢が 4 つあっても、本文欄は溢れずスクロールできる', (tester) async {
    tester.view
      ..physicalSize = const Size(400, 800)
      ..devicePixelRatio = 1
      ..viewInsets = const FakeViewPadding(bottom: 400);
    addTearDown(tester.view.reset);

    await _pump(tester, const ComposeScreen());

    await tester.tap(find.byIcon(Icons.poll_outlined));
    await tester.pumpAndSettle();
    await tester.tap(find.text('選択肢を追加'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('選択肢を追加'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);

    await tester.drag(find.byType(CustomScrollView), const Offset(0, -600));
    await tester.pumpAndSettle();
    expect(find.text('締め切り').hitTestable(), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('長い本文を打つと、キャレットのある行までスクロールする', (tester) async {
    tester.view
      ..physicalSize = const Size(400, 800)
      ..devicePixelRatio = 1
      ..viewInsets = const FakeViewPadding(bottom: 400);
    addTearDown(tester.view.reset);

    await _pump(tester, const ComposeScreen());

    await tester.enterText(
      find.byType(TextField).first,
      List.generate(40, (i) => '行 $i').join('\n'),
    );
    await tester.pumpAndSettle();

    final scrollable = tester.state<ScrollableState>(
      find
          .descendant(
            of: find.byType(CustomScrollView),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    expect(scrollable.position.pixels, greaterThan(0));
    expect(tester.takeException(), isNull);
  });

  testWidgets('余白をタップすると本文にフォーカスが戻る', (tester) async {
    await _pump(tester, const ComposeScreen());

    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pump();
    expect(find.byType(EditableText), findsOneWidget);
    expect(
      tester.widget<EditableText>(find.byType(EditableText)).focusNode.hasFocus,
      isFalse,
    );

    await tester.tapAt(const Offset(400, 500));
    await tester.pump();

    expect(
      tester.widget<EditableText>(find.byType(EditableText)).focusNode.hasFocus,
      isTrue,
    );
  });

  testWidgets('ドライブから選んだファイルは、アップロード済みの添付として投稿される', (tester) async {
    int? requestedMax;
    final client = await _pump(
      tester,
      ComposeScreen(
        driveFilePicker: (context, {int max = 16}) async {
          requestedMax = max;
          return const [
            DriveFile(
              id: 'file1',
              type: 'video/mp4',
              url: 'https://example.test/v.mp4',
              comment: '説明',
              isSensitive: true,
            ),
          ];
        },
      ),
    );

    await tester.tap(find.byTooltip('ドライブから添付'));
    await tester.pumpAndSettle();

    expect(requestedMax, 16);
    expect(find.text('ALT'), findsOneWidget);
    expect(find.text('NSFW'), findsOneWidget);

    await tester.tap(find.byTooltip('ドライブから添付'));
    await tester.pumpAndSettle();
    expect(requestedMax, 15);

    await tester.tap(find.widgetWithText(FilledButton, '投稿'));
    await tester.pumpAndSettle();

    expect(client.created?['fileIds'], ['file1']);
  });

  testWidgets('チャンネルを指定すると channelId 付きで投稿し、公開範囲は選べない', (tester) async {
    final client = await _pump(
      tester,
      const ComposeScreen(
        channel: NoteChannel(id: 'ch1', name: 'お絵かき'),
      ),
    );

    expect(find.text('お絵かき'), findsOneWidget);
    expect(find.byType(PopupMenuButton<NoteVisibility>), findsNothing);

    await tester.enterText(find.byType(TextField).first, 'こんにちは');
    await tester.pump();
    await tester.tap(find.widgetWithText(FilledButton, '投稿'));
    await tester.pumpAndSettle();

    expect(client.created?['channelId'], 'ch1');
  });

  testWidgets('チャンネルのノートへの返信は同じチャンネルへ投稿される', (tester) async {
    final client = await _pump(
      tester,
      const ComposeScreen(
        replyTo: Note(
          id: 'parent',
          createdAt: '2026-08-17T00:00:00.000Z',
          user: User(id: 'alice', username: 'alice'),
          text: '元のノート',
          channelId: 'ch1',
          channel: NoteChannel(id: 'ch1', name: 'お絵かき'),
        ),
      ),
    );

    expect(find.byType(PopupMenuButton<NoteVisibility>), findsNothing);

    await tester.enterText(find.byType(TextField).first, '返信');
    await tester.pump();
    await tester.tap(find.widgetWithText(FilledButton, '返信'));
    await tester.pumpAndSettle();

    expect(client.created?['channelId'], 'ch1');
    expect(client.created?['replyId'], 'parent');
  });

  testWidgets('チャンネルなしの投稿は channelId を送らず、公開範囲を選べる', (tester) async {
    final client = await _pump(tester, const ComposeScreen());

    expect(find.byTooltip('公開範囲: パブリック'), findsOneWidget);
    expect(
      tester.getSize(find.byTooltip('公開範囲: パブリック')).height,
      greaterThanOrEqualTo(48),
    );

    await tester.enterText(find.byType(TextField).first, 'こんにちは');
    await tester.pump();
    await tester.tap(find.widgetWithText(FilledButton, '投稿'));
    await tester.pumpAndSettle();

    expect(client.created?.containsKey('channelId'), isFalse);
  });

  testWidgets('入力済みの投票をやめるときは確認し、空なら黙って消す', (tester) async {
    await _pump(tester, const ComposeScreen());

    await tester.tap(find.byTooltip('投票'));
    await tester.pumpAndSettle();
    expect(find.text('選択肢 1'), findsOneWidget);
    await tester.tap(find.byTooltip('投票'));
    await tester.pumpAndSettle();
    expect(find.text('選択肢 1'), findsNothing);

    await tester.tap(find.byTooltip('投票'));
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextField, '選択肢 1'), 'A');
    await tester.tap(find.byTooltip('投票をやめる'));
    await tester.pumpAndSettle();
    expect(find.text('入力した選択肢は消えます。'), findsOneWidget);

    await tester.tap(find.text('キャンセル'));
    await tester.pumpAndSettle();
    expect(find.text('選択肢 1'), findsOneWidget);

    await tester.tap(find.byTooltip('投票'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'やめる'));
    await tester.pumpAndSettle();
    expect(find.text('選択肢 1'), findsNothing);
  });

  testWidgets('投票と CW のトグルは選択状態を持つ', (tester) async {
    await _pump(tester, const ComposeScreen());

    bool? selected(String tooltip) => tester
        .widget<IconButton>(
          find.byWidgetPredicate(
            (w) => w is IconButton && w.tooltip == tooltip,
          ),
        )
        .isSelected;

    expect(selected('投票'), isFalse);
    expect(selected('CW (閲覧注意)'), isFalse);

    await tester.tap(find.byTooltip('投票'));
    await tester.tap(find.byTooltip('CW (閲覧注意)'));
    await tester.pumpAndSettle();

    expect(selected('投票'), isTrue);
    expect(selected('CW (閲覧注意)'), isTrue);
  });
}
