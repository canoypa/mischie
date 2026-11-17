import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mischie/features/timeline/data/note_repository.dart';
import 'package:mischie/features/timeline/domain/note.dart';
import 'package:mischie/features/timeline/domain/note_actions.dart';
import 'package:mischie/features/timeline/domain/note_store.dart';
import 'package:mischie/features/timeline/domain/user.dart';

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
  Future<Note> renote(
    String noteId, {
    String? visibility,
    String? channelId,
  }) async {
    calls.add('renote:$noteId:${visibility ?? '-'}:${channelId ?? '-'}');
    if (shouldFail) throw Exception('失敗');
    return _note();
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
  Future<NoteState> state(String noteId) async {
    calls.add('state:$noteId');
    return const NoteState(isFavorited: true, isMutedThread: false);
  }

  @override
  Future<void> favorite(String noteId) async => calls.add('favorite:$noteId');

  @override
  Future<void> unfavorite(String noteId) async =>
      calls.add('unfavorite:$noteId');

  @override
  Future<void> muteThread(String noteId) async =>
      calls.add('muteThread:$noteId');

  @override
  Future<void> unmuteThread(String noteId) async =>
      calls.add('unmuteThread:$noteId');

  @override
  Future<List<String>> pinnedNoteIds() async {
    calls.add('pinnedNoteIds');
    return ['note1', 'other'];
  }

  @override
  Future<void> pin(String noteId) async => calls.add('pin:$noteId');

  @override
  Future<void> unpin(String noteId) async => calls.add('unpin:$noteId');

  @override
  Future<void> reportAbuse(String userId, String comment) async =>
      calls.add('reportAbuse:$userId:$comment');

  @override
  Future<List<Note>> renotes(
    String noteId, {
    int limit = 30,
    String? untilId,
  }) async => [];

  @override
  Future<List<Note>> children(
    String noteId, {
    int limit = 30,
    String? untilId,
  }) async => [];

  @override
  Future<List<User>> reactionUsers(String noteId, {String? type}) async => [];

  @override
  Future<({List<Note> notes, String? nextUntilId})> favorites({
    String? untilId,
  }) async => (notes: const <Note>[], nextUntilId: null);

  @override
  Future<List<Note>> conversation(String noteId, {int limit = 30}) async => [];

  @override
  Future<Note> show(String noteId) async => _note();
}

class _FailAfterUnreactRepository extends _FakeNoteRepository {
  @override
  Future<void> react(String noteId, String reaction) async {
    calls.add('react:$noteId:$reaction');
    throw Exception('失敗');
  }
}

Note _note({
  Map<String, int> reactions = const {},
  String? myReaction,
  int renoteCount = 0,
  String visibility = 'public',
  NoteChannel? channel,
}) => Note(
  id: 'note1',
  createdAt: '2026-08-18T00:00:00.000Z',
  user: const User(id: 'user1', username: 'alice'),
  reactions: reactions,
  myReaction: myReaction,
  renoteCount: renoteCount,
  visibility: visibility,
  channelId: channel?.id,
  channel: channel,
);

Note _myRenote(Note original) => Note(
  id: 'renote1',
  createdAt: '2026-08-18T00:01:00.000Z',
  user: const User(id: 'user2', username: 'bob'),
  renote: original,
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

      await container.read(noteActionsProvider).toggleReaction(note, '❤');

      final updated = container.read(noteOverridesProvider)['note1']!;
      expect(updated.myReaction, '❤');
      expect(updated.reactions, {'👍': 2, '❤': 1});
      expect(repo.calls, ['react:note1:❤']);
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
      final note = _note(reactions: {'👍': 2, '❤': 1}, myReaction: '👍');

      await container.read(noteActionsProvider).toggleReaction(note, '❤');

      final updated = container.read(noteOverridesProvider)['note1']!;
      expect(updated.myReaction, '❤');
      expect(updated.reactions, {'👍': 1, '❤': 2});
      expect(repo.calls, ['unreact:note1', 'react:note1:❤']);
    });

    test('API が失敗したら元の状態に戻す', () async {
      final repo = _FakeNoteRepository(shouldFail: true);
      final container = _container(repo);
      final note = _note(reactions: {'👍': 2});

      await expectLater(
        container.read(noteActionsProvider).toggleReaction(note, '❤'),
        throwsA(isA<Exception>()),
      );

      final updated = container.read(noteOverridesProvider)['note1']!;
      expect(updated.myReaction, isNull);
      expect(updated.reactions, {'👍': 2});
    });

    test('付け替えで unreact 後に react が失敗したら無リアクションへ戻す', () async {
      final repo = _FailAfterUnreactRepository();
      final container = _container(repo);
      final note = _note(reactions: {'👍': 2, '❤': 1}, myReaction: '👍');

      await expectLater(
        container.read(noteActionsProvider).toggleReaction(note, '❤'),
        throwsA(isA<Exception>()),
      );

      // unreact は成功済みなので、自分の 👍 は外れたままになる
      final updated = container.read(noteOverridesProvider)['note1']!;
      expect(updated.myReaction, isNull);
      expect(updated.reactions, {'👍': 1, '❤': 1});
    });

    test('ピッカーの :kawaii: がサーバーの :kawaii@.: と同じチップになる', () async {
      final repo = _FakeNoteRepository();
      final container = _container(repo);
      final note = _note(reactions: {':kawaii@.:': 3});

      await container
          .read(noteActionsProvider)
          .toggleReaction(note, ':kawaii:');

      final updated = container.read(noteOverridesProvider)['note1']!;
      expect(updated.myReaction, ':kawaii@.:');
      expect(updated.reactions, {':kawaii@.:': 4});
      expect(repo.calls, ['react:note1::kawaii@.:']);
    });
  });

  group('NoteActions', () {
    test('リノートするとカウントが増える', () async {
      final repo = _FakeNoteRepository();
      final container = _container(repo);

      await container.read(noteActionsProvider).renote(_note(renoteCount: 4));

      expect(container.read(noteOverridesProvider)['note1']!.renoteCount, 5);
    });

    test('リノートは元のノートの公開範囲を保つ', () async {
      final repo = _FakeNoteRepository();
      final container = _container(repo);

      await container
          .read(noteActionsProvider)
          .renote(_note(visibility: 'home'));

      expect(repo.calls, ['renote:note1:home:-']);
    });

    test('センシティブなチャンネルの公開ノートはホームでリノートする', () async {
      final repo = _FakeNoteRepository();
      final container = _container(repo);
      const channel = NoteChannel(id: 'ch1', isSensitive: true);

      await container.read(noteActionsProvider).renote(_note(channel: channel));

      expect(repo.calls, ['renote:note1:home:-']);
    });

    test('チャンネル内へのリノートは公開範囲を送らずチャンネルを指す', () async {
      final repo = _FakeNoteRepository();
      final container = _container(repo);
      const channel = NoteChannel(id: 'ch1');

      await container
          .read(noteActionsProvider)
          .renote(_note(channel: channel), inChannel: true);

      expect(repo.calls, ['renote:note1:-:ch1']);
      expect(container.read(noteOverridesProvider)['note1']!.renoteCount, 1);
    });

    test('リノートの失敗でカウントが戻る', () async {
      final repo = _FakeNoteRepository(shouldFail: true);
      final container = _container(repo);

      await expectLater(
        container.read(noteActionsProvider).renote(_note(renoteCount: 4)),
        throwsA(isA<Exception>()),
      );

      expect(container.read(noteOverridesProvider)['note1']!.renoteCount, 4);
    });

    test('リノート解除は自分のリノート本体を消し、件数を 1 減らす', () async {
      final repo = _FakeNoteRepository();
      final container = _container(repo);

      await container
          .read(noteActionsProvider)
          .unrenote(_myRenote(_note(renoteCount: 4)));

      expect(repo.calls, ['delete:renote1']);
      expect(container.read(noteOverridesProvider)['note1']!.renoteCount, 3);
      expect(container.read(deletedNoteIdsProvider), contains('renote1'));
    });

    test('リノート解除の失敗でカウントが戻り、本体は残る', () async {
      final repo = _FakeNoteRepository(shouldFail: true);
      final container = _container(repo);

      await expectLater(
        container
            .read(noteActionsProvider)
            .unrenote(_myRenote(_note(renoteCount: 4))),
        throwsA(isA<Exception>()),
      );

      expect(container.read(noteOverridesProvider)['note1']!.renoteCount, 4);
      expect(container.read(deletedNoteIdsProvider), isEmpty);
    });

    test('お気に入り・スレッドミュート・ピン留めは付ける側と外す側で別の API', () async {
      final repo = _FakeNoteRepository();
      final container = _container(repo);
      final actions = container.read(noteActionsProvider);
      final note = _note();

      await actions.setFavorite(note, favorite: true);
      await actions.setFavorite(note, favorite: false);
      await actions.setThreadMuted(note, muted: true);
      await actions.setThreadMuted(note, muted: false);
      await actions.setPinned(note, pinned: true);
      await actions.setPinned(note, pinned: false);

      expect(repo.calls, [
        'favorite:note1',
        'unfavorite:note1',
        'muteThread:note1',
        'unmuteThread:note1',
        'pin:note1',
        'unpin:note1',
      ]);
    });

    test('ピン留め中かは、自分のピン留め一覧にそのノートがあるかで決まる', () async {
      final container = _container(_FakeNoteRepository());
      final actions = container.read(noteActionsProvider);

      expect(await actions.isPinned(_note()), isTrue);
      expect(await actions.isPinned(_note().copyWith(id: 'note9')), isFalse);
    });

    test('通報は投稿者のユーザー ID を送る', () async {
      final repo = _FakeNoteRepository();
      final container = _container(repo);

      await container.read(noteActionsProvider).reportAbuse(_note(), '迷惑');

      expect(repo.calls, ['reportAbuse:user1:迷惑']);
    });

    test('削除すると削除済み ID に入る', () async {
      final repo = _FakeNoteRepository();
      final container = _container(repo);

      await container.read(noteActionsProvider).delete(_note());

      expect(container.read(deletedNoteIdsProvider), contains('note1'));
    });
  });
}
