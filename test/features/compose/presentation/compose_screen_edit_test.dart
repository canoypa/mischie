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

void main() {
  testWidgets('削除して編集は、本文・CW・公開範囲・添付・投票・返信先を復元して投稿できる', (tester) async {
    // 全部を入れた状態は既定の 800x600 に収まらない
    tester.view
      ..physicalSize = const Size(800, 1600)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final client = _Client();
    final note = Note(
      id: 'note1',
      createdAt: '2026-08-18T00:00:00.000Z',
      user: const User(id: 'me', username: 'me'),
      text: '書き直す本文',
      cw: '注意',
      visibility: 'home',
      replyId: 'parent1',
      reply: const Note(
        id: 'parent1',
        createdAt: '2026-08-17T00:00:00.000Z',
        user: User(id: 'alice', username: 'alice'),
        text: '返信先の本文',
      ),
      files: const [DriveFile(id: 'file1', type: 'image/png', url: 'u')],
      poll: const Poll(
        choices: [
          PollChoice(text: '選択肢A'),
          PollChoice(text: '選択肢B'),
        ],
        multiple: true,
      ),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          composeRepositoryProvider.overrideWithValue(
            ComposeRepository(client),
          ),
          draftsProvider.overrideWith(_Drafts.new),
        ],
        child: MaterialApp(home: ComposeScreen(editFrom: note)),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('書き直す本文'), findsOneWidget);
    expect(find.text('注意'), findsOneWidget);
    expect(find.text('選択肢A'), findsOneWidget);
    expect(find.text('返信先の本文'), findsOneWidget);

    // 返信先がある編集では、投稿ボタンは「返信」になる
    await tester.tap(find.widgetWithText(FilledButton, '返信'));
    await tester.pumpAndSettle();

    expect(client.created, {
      'visibility': 'home',
      'text': '書き直す本文',
      'cw': '注意',
      'replyId': 'parent1',
      'fileIds': ['file1'],
      'poll': {
        'choices': ['選択肢A', '選択肢B'],
        'multiple': true,
      },
    });
  });
}
