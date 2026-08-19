import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mischie/features/timeline/data/note_repository.dart';
import 'package:mischie/features/timeline/domain/note.dart';
import 'package:mischie/features/timeline/domain/note_actions.dart';
import 'package:mischie/features/timeline/domain/user.dart';

/// API を呼ばずに、呼ばれた内容と失敗させるかだけを記録するリポジトリ。
class _FakeNoteRepository implements NoteRepository {
  _FakeNoteRepository({this.shouldFail = false});

  final bool shouldFail;
  final List<String> calls = [];

  @override
  Future<void> react(String noteId, String reaction) async {
    calls.add('react:$noteId:$reaction');
    if (shouldFail) throw Exception('失敗');
  }

  @override
  Future<void> unreact(String noteId) async {
    calls.add('unreact:$noteId');
    if (shouldFail) throw Exception('失敗');
  }

  @override
  Future<Note> renote(String noteId) async {
    calls.add('renote:$noteId');
    if (shouldFail) throw Exception('失敗');
    return _note();
  }

  @override
  Future<void> unrenote(String noteId) async {
    calls.add('unrenote:$noteId');
    if (shouldFail) throw Exception('失敗');
  }

  @override
  Future<void> vote(String noteId, int choice) async {
    calls.add('vote:$noteId:$choice');
    if (shouldFail) throw Exception('失敗');
  }

  @override
  Future<void> delete(String noteId) async {
    calls.add('delete:$noteId');
    if (shouldFail) throw Exception('失敗');
  }

  @override
  Future<List<Note>> children(String noteId, {int limit = 30}) async => [];

  @override
  Future<List<Note>> conversation(String noteId, {int limit = 30}) async => [];

  @override
  Future<Note> show(String noteId) async => _note();
}

Note _note({
  Map<String, int> reactions = const {},
  String? myReaction,
  int renoteCount = 0,
}) => Note(
  id: 'note1',
  createdAt: '2026-08-18T00:00:00.000Z',
  user: const User(id: 'user1', username: 'alice'),
  reactions: reactions,
  myReaction: myReaction,
  renoteCount: renoteCount,
);

ProviderContainer _container(_FakeNoteRepository repo) {
  final container = ProviderContainer(
    overrides: [noteRepositoryProvider.overrideWithValue(repo)],
  );
  addTearDown(container.dispose);
  return container;
}

void main() {
  group('NoteActions.toggleReaction', () {
    test('未リアクション → 付ける', () async {
      final repo = _FakeNoteRepository();
      final container = _container(repo);
      final note = _note(reactions: {'👍': 2});

      await container.read(noteActionsProvider).toggleReaction(note, '❤️');

      final updated = container.read(noteOverridesProvider)['note1']!;
      expect(updated.myReaction, '❤️');
      expect(updated.reactions, {'👍': 2, '❤️': 1});
      expect(repo.calls, ['react:note1:❤️']);
    });

    test('同じリアクションをもう一度 → 取り消す', () async {
      final repo = _FakeNoteRepository();
      final container = _container(repo);
      final note = _note(reactions: {'👍': 3}, myReaction: '👍');

      await container.read(noteActionsProvider).toggleReaction(note, '👍');

      final updated = container.read(noteOverridesProvider)['note1']!;
      expect(updated.myReaction, isNull);
      expect(updated.reactions, {'👍': 2});
      expect(repo.calls, ['unreact:note1']);
    });

    test('自分だけのリアクションを取り消すとキーごと消える', () async {
      final repo = _FakeNoteRepository();
      final container = _container(repo);
      final note = _note(reactions: {'👍': 1}, myReaction: '👍');

      await container.read(noteActionsProvider).toggleReaction(note, '👍');

      expect(
        container.read(noteOverridesProvider)['note1']!.reactions,
        isEmpty,
      );
    });

    test('別のリアクションへ付け替える', () async {
      final repo = _FakeNoteRepository();
      final container = _container(repo);
      final note = _note(reactions: {'👍': 2, '❤️': 1}, myReaction: '👍');

      await container.read(noteActionsProvider).toggleReaction(note, '❤️');

      final updated = container.read(noteOverridesProvider)['note1']!;
      expect(updated.myReaction, '❤️');
      expect(updated.reactions, {'👍': 1, '❤️': 2});
      expect(repo.calls, ['unreact:note1', 'react:note1:❤️']);
    });

    test('API が失敗したら元の状態に戻す', () async {
      final repo = _FakeNoteRepository(shouldFail: true);
      final container = _container(repo);
      final note = _note(reactions: {'👍': 2});

      await expectLater(
        container.read(noteActionsProvider).toggleReaction(note, '❤️'),
        throwsA(isA<Exception>()),
      );

      final updated = container.read(noteOverridesProvider)['note1']!;
      expect(updated.myReaction, isNull);
      expect(updated.reactions, {'👍': 2});
    });
  });

  group('NoteActions', () {
    test('リノートするとカウントが増える', () async {
      final repo = _FakeNoteRepository();
      final container = _container(repo);

      await container.read(noteActionsProvider).renote(_note(renoteCount: 4));

      expect(container.read(noteOverridesProvider)['note1']!.renoteCount, 5);
    });

    test('リノート解除の失敗でカウントが戻る', () async {
      final repo = _FakeNoteRepository(shouldFail: true);
      final container = _container(repo);

      await expectLater(
        container.read(noteActionsProvider).unrenote(_note(renoteCount: 4)),
        throwsA(isA<Exception>()),
      );

      expect(container.read(noteOverridesProvider)['note1']!.renoteCount, 4);
    });

    test('削除すると削除済み ID に入る', () async {
      final repo = _FakeNoteRepository();
      final container = _container(repo);

      await container.read(noteActionsProvider).delete(_note());

      expect(container.read(deletedNoteIdsProvider), contains('note1'));
    });
  });
}
