import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mischie/core/api/misskey_api_client.dart';
import 'package:mischie/features/profile/domain/profile_notifier.dart';
import 'package:mischie/features/timeline/data/note_repository.dart';
import 'package:mischie/features/timeline/domain/note.dart';
import 'package:mischie/features/timeline/domain/note_actions.dart';
import 'package:mischie/features/timeline/domain/user.dart';
import 'package:mischie/features/timeline/presentation/note/actions_row.dart';

const _me = User(id: 'me', username: 'me');
const _alice = User(id: 'alice', username: 'alice');

class _Profile extends ProfileNotifier {
  @override
  Future<User?> build() async => _me;
}

class _Client extends MisskeyApiClient {
  _Client({this.pinned = const []})
    : super(host: 'example.test', getToken: () async => null);

  final List<String> pinned;

  @override
  Future<Map<String, dynamic>> post(
    String path, {
    Map<String, dynamic>? body,
  }) async => switch (path) {
    'notes/state' => {'isFavorited': false, 'isMutedThread': true},
    'i' => {'pinnedNoteIds': pinned},
    _ => throw UnimplementedError(path),
  };
}

Note _note({
  User user = _alice,
  String visibility = 'public',
  bool localOnly = false,
  NoteChannel? channel,
  Note? renote,
}) => Note(
  id: 'note1',
  createdAt: '2026-08-18T00:00:00.000Z',
  user: user,
  userId: user.id,
  visibility: visibility,
  localOnly: localOnly,
  channelId: channel?.id,
  channel: channel,
  renote: renote,
);

Future<void> _pump(
  WidgetTester tester,
  Note note, {
  Note? renoteItem,
  List<String> pinned = const [],
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        profileNotifierProvider.overrideWith(_Profile.new),
        noteRepositoryProvider.overrideWithValue(
          NoteRepository(_Client(pinned: pinned)),
        ),
      ],
      child: MaterialApp(
        home: Scaffold(
          body: NoteActionsRow(
            note: note,
            onReact: () {},
            renoteItem: renoteItem,
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _openRenoteMenu(WidgetTester tester) async {
  await tester.tap(find.byTooltip('リノート'));
  await tester.pumpAndSettle();
}

Future<void> _openMoreMenu(WidgetTester tester) async {
  await tester.tap(find.byTooltip('その他'));
  await tester.pumpAndSettle();
}

Note _renoteOf(Note original, User by) => Note(
  id: 'renote1',
  createdAt: '2026-08-18T00:01:00.000Z',
  user: by,
  renote: original,
);

void main() {
  group('リノートメニュー', () {
    testWidgets('自分がリノートした投稿でなければ、リノート解除は出ない', (tester) async {
      await _pump(tester, _note());
      await _openRenoteMenu(tester);

      expect(find.text('リノート'), findsOneWidget);
      expect(find.text('引用'), findsOneWidget);
      expect(find.text('リノート解除'), findsNothing);
    });

    testWidgets('自分のリノート本体から開いたときだけ、リノート解除が出る', (tester) async {
      final original = _note();
      await _pump(tester, original, renoteItem: _renoteOf(original, _me));
      await _openRenoteMenu(tester);

      expect(find.text('リノート解除'), findsOneWidget);
    });

    testWidgets('他人のリノート本体では、リノート解除は出ない', (tester) async {
      final original = _note();
      await _pump(tester, original, renoteItem: _renoteOf(original, _alice));
      await _openRenoteMenu(tester);

      expect(find.text('リノート解除'), findsNothing);
    });

    testWidgets('外へのリノートを許さないチャンネルでは、チャンネル内のリノートだけ', (tester) async {
      await _pump(
        tester,
        _note(
          channel: const NoteChannel(id: 'ch1', allowRenoteToExternal: false),
        ),
      );
      await _openRenoteMenu(tester);

      expect(find.text('チャンネル内にリノート'), findsOneWidget);
      expect(find.text('引用'), findsNothing);
    });

    testWidgets('フォロワー限定は自分のノートだけリノートできる', (tester) async {
      await _pump(tester, _note(visibility: 'followers'));
      expect(tester.widget<InkWell>(find.byType(InkWell).at(1)).onTap, isNull);

      await _pump(tester, _note(visibility: 'followers', user: _me));
      expect(
        tester.widget<InkWell>(find.byType(InkWell).at(1)).onTap,
        isNotNull,
      );
    });
  });

  group('その他メニュー', () {
    testWidgets('他人のノートでは状態に応じた項目と通報が出て、ピン留めと編集は出ない', (tester) async {
      await _pump(tester, _note());
      await _openMoreMenu(tester);

      expect(find.text('共有'), findsOneWidget);
      expect(find.text('お気に入りに追加'), findsOneWidget);
      expect(find.text('スレッドのミュートを解除'), findsOneWidget);
      expect(find.text('通報'), findsOneWidget);
      expect(find.text('プロフィールにピン留め'), findsNothing);
      expect(find.text('削除して編集'), findsNothing);
    });

    testWidgets('自分のノートではピン留めと削除して編集が出て、通報は出ない', (tester) async {
      await _pump(tester, _note(user: _me));
      await _openMoreMenu(tester);

      expect(find.text('プロフィールにピン留め'), findsOneWidget);
      expect(find.text('削除して編集'), findsOneWidget);
      expect(find.text('削除'), findsOneWidget);
      expect(find.text('通報'), findsNothing);
    });

    testWidgets('ピン留め済みなら解除が出る', (tester) async {
      await _pump(tester, _note(user: _me), pinned: ['note1']);
      await _openMoreMenu(tester);

      expect(find.text('ピン留めを解除'), findsOneWidget);
    });

    final unsupported = {
      'チャンネル': _note(
        user: _me,
        channel: const NoteChannel(id: 'ch1'),
      ),
      'ローカル限定': _note(user: _me, localOnly: true),
      'ダイレクト': _note(user: _me, visibility: 'specified'),
    };
    for (final MapEntry(key: label, value: note) in unsupported.entries) {
      testWidgets('$labelのノートは削除して編集を出さない', (tester) async {
        await _pump(tester, note);
        await _openMoreMenu(tester);

        expect(find.text('削除して編集'), findsNothing);
        expect(find.text('削除'), findsOneWidget);
      });
    }
  });
}
