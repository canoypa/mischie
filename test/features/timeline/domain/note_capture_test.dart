import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mischie/features/profile/domain/profile_notifier.dart';
import 'package:mischie/features/timeline/domain/note.dart';
import 'package:mischie/features/timeline/domain/note_capture.dart';
import 'package:mischie/features/timeline/domain/note_store.dart';
import 'package:mischie/features/timeline/domain/user.dart';

final _refProvider = Provider<Ref>((ref) => ref);

class _FakeProfileNotifier extends ProfileNotifier {
  _FakeProfileNotifier(this._me);

  final User? _me;

  @override
  Future<User?> build() async => _me;
}

const _myId = 'me';

Note _note({Map<String, int> reactions = const {}, String? myReaction}) => Note(
  id: 'note1',
  createdAt: '2026-08-18T00:00:00.000Z',
  user: const User(id: 'user1', username: 'alice'),
  reactions: reactions,
  myReaction: myReaction,
);

Future<ProviderContainer> _container({
  User? me = const User(id: _myId, username: 'me'),
}) async {
  final container = ProviderContainer(
    overrides: [
      profileNotifierProvider.overrideWith(() => _FakeProfileNotifier(me)),
    ],
  );
  addTearDown(container.dispose);
  await container.read(profileNotifierProvider.future);
  return container;
}

Map<String, dynamic> _event({
  required String type,
  required String userId,
  required String reaction,
}) => {
  'id': 'note1',
  'type': type,
  'body': {'reaction': reaction, 'userId': userId},
};

void main() {
  group('applyNoteUpdate', () {
    test('自分の reacted で既に楽観的更新済みなら無視する', () async {
      final container = await _container();
      container
          .read(noteOverridesProvider.notifier)
          .put(_note(reactions: {'❤': 1}, myReaction: '❤'));
      final ref = container.read(_refProvider);

      applyNoteUpdate(
        ref,
        _event(type: 'reacted', userId: _myId, reaction: '❤'),
      );

      final note = container.read(noteOverridesProvider)['note1']!;
      expect(note.myReaction, '❤');
      expect(note.reactions, {'❤': 1});
    });

    test('自分の reacted が別端末からなら件数と myReaction を反映する', () async {
      final container = await _container();
      container
          .read(noteOverridesProvider.notifier)
          .put(_note(reactions: {'👍': 1}, myReaction: null));
      final ref = container.read(_refProvider);

      applyNoteUpdate(
        ref,
        _event(type: 'reacted', userId: _myId, reaction: '❤'),
      );

      final note = container.read(noteOverridesProvider)['note1']!;
      expect(note.myReaction, '❤');
      expect(note.reactions, {'👍': 1, '❤': 1});
    });

    test('自分の unreacted がアプリ内の付け替えで既に反映済みなら無視する', () async {
      final container = await _container();
      // 👍 → ❤ に付け替えた直後
      container
          .read(noteOverridesProvider.notifier)
          .put(_note(reactions: {'❤': 1}, myReaction: '❤'));
      final ref = container.read(_refProvider);

      applyNoteUpdate(
        ref,
        _event(type: 'unreacted', userId: _myId, reaction: '👍'),
      );

      final note = container.read(noteOverridesProvider)['note1']!;
      expect(note.myReaction, '❤');
      expect(note.reactions, {'❤': 1});
    });

    test('自分の unreacted が別端末からなら件数を減らし myReaction を外す', () async {
      final container = await _container();
      container
          .read(noteOverridesProvider.notifier)
          .put(_note(reactions: {'❤': 1}, myReaction: '❤'));
      final ref = container.read(_refProvider);

      applyNoteUpdate(
        ref,
        _event(type: 'unreacted', userId: _myId, reaction: '❤'),
      );

      final note = container.read(noteOverridesProvider)['note1']!;
      expect(note.myReaction, isNull);
      expect(note.reactions, isEmpty);
    });

    test('他人の reacted は件数だけ増える', () async {
      final container = await _container();
      container
          .read(noteOverridesProvider.notifier)
          .put(_note(reactions: {'❤': 1}, myReaction: '❤'));
      final ref = container.read(_refProvider);

      applyNoteUpdate(
        ref,
        _event(type: 'reacted', userId: 'someone-else', reaction: '❤'),
      );

      final note = container.read(noteOverridesProvider)['note1']!;
      expect(note.myReaction, '❤');
      expect(note.reactions, {'❤': 2});
    });

    test('他人の unreacted は件数だけ減る', () async {
      final container = await _container();
      container
          .read(noteOverridesProvider.notifier)
          .put(_note(reactions: {'❤': 2}, myReaction: '❤'));
      final ref = container.read(_refProvider);

      applyNoteUpdate(
        ref,
        _event(type: 'unreacted', userId: 'someone-else', reaction: '❤'),
      );

      final note = container.read(noteOverridesProvider)['note1']!;
      expect(note.myReaction, '❤');
      expect(note.reactions, {'❤': 1});
    });

    test('サーバー側の未正規化キー (:name:) も自分の myReaction と揃える', () async {
      final container = await _container();
      container
          .read(noteOverridesProvider.notifier)
          .put(_note(reactions: {':kawaii@.:': 1}, myReaction: ':kawaii@.:'));
      final ref = container.read(_refProvider);

      applyNoteUpdate(
        ref,
        _event(type: 'reacted', userId: _myId, reaction: ':kawaii:'),
      );

      final note = container.read(noteOverridesProvider)['note1']!;
      expect(note.myReaction, ':kawaii@.:');
      expect(note.reactions, {':kawaii@.:': 1});
    });
  });
}
