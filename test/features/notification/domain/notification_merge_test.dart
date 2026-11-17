import 'package:flutter_test/flutter_test.dart';
import 'package:mischie/features/notification/domain/notification_item.dart';
import 'package:mischie/features/notification/domain/notification_merge.dart';
import 'package:mischie/features/timeline/domain/note.dart';
import 'package:mischie/features/timeline/domain/user.dart';

const _carol = User(id: 'u1', username: 'carol', name: 'Carol');
const _alice = User(id: 'u2', username: 'alice', name: 'Alice');
const _bob = User(id: 'u3', username: 'bob', name: 'Bob');

Note _note(String id) =>
    Note(id: id, createdAt: '2024-01-01T00:00:00.000Z', user: _carol);

NotificationItem _reaction({
  required String id,
  required User user,
  required Note note,
  String reaction = '👍',
  String createdAt = '2024-01-01T00:00:01.000Z',
}) => NotificationItem(
  id: id,
  createdAt: createdAt,
  type: 'reaction',
  user: user,
  note: note,
  reaction: reaction,
);

NotificationItem _renote({
  required String id,
  required User user,
  required Note note,
  String createdAt = '2024-01-01T00:00:01.000Z',
}) => NotificationItem(
  id: id,
  createdAt: createdAt,
  type: 'renote',
  user: user,
  note: note,
);

void main() {
  group('mergeIncomingNotification / reaction', () {
    test('先頭が同じノートへの reaction なら reaction:grouped に束ねる', () {
      final note = _note('note1');
      final top = _reaction(id: 'old', user: _carol, note: note);
      final incoming = _reaction(
        id: 'new',
        user: _alice,
        note: note,
        reaction: '🎉',
      );

      final result = mergeIncomingNotification(incoming, [top]);

      expect(result, hasLength(1));
      final merged = result.first;
      expect(merged.type, 'reaction:grouped');
      // untilId でのページングのため、グループの id は最古のメンバーのものにする
      expect(merged.id, 'old');
      expect(merged.createdAt, incoming.createdAt);
      expect(merged.reactions, hasLength(2));
      expect(merged.reactions![0].user, _alice);
      expect(merged.reactions![0].reaction, '🎉');
      expect(merged.reactions![1].user, _carol);
      expect(merged.reactions![1].reaction, '👍');
    });

    test('先頭が既に reaction:grouped ならさらに束ねる', () {
      final note = _note('note1');
      final top = NotificationItem(
        id: 'g1',
        createdAt: '2024-01-01T00:00:01.000Z',
        type: 'reaction:grouped',
        note: note,
        reactions: const [
          GroupedReaction(user: _alice, reaction: '🎉'),
          GroupedReaction(user: _carol, reaction: '👍'),
        ],
      );
      final incoming = _reaction(
        id: 'new',
        user: _bob,
        note: note,
        reaction: '😀',
      );

      final result = mergeIncomingNotification(incoming, [top]);

      expect(result, hasLength(1));
      final merged = result.first;
      expect(merged.type, 'reaction:grouped');
      expect(merged.id, 'g1');
      expect(merged.reactions, hasLength(3));
      expect(merged.reactions![0].user, _bob);
      expect(merged.reactions![1].user, _alice);
      expect(merged.reactions![2].user, _carol);
    });

    test('先頭が別のノートへの reaction なら束ねず先頭に追加する', () {
      final top = _reaction(id: 'old', user: _carol, note: _note('note1'));
      final incoming = _reaction(id: 'new', user: _alice, note: _note('note2'));

      final result = mergeIncomingNotification(incoming, [top]);

      expect(result, hasLength(2));
      expect(result[0], incoming);
      expect(result[1], top);
    });

    test('先頭が同じノートでも種別が違う（renote）なら束ねない', () {
      final note = _note('note1');
      final top = _renote(id: 'old', user: _carol, note: note);
      final incoming = _reaction(id: 'new', user: _alice, note: note);

      final result = mergeIncomingNotification(incoming, [top]);

      expect(result, hasLength(2));
      expect(result[0].type, 'reaction');
      expect(result[1].type, 'renote');
    });

    test('現在のリストが空なら単に先頭に置く', () {
      final incoming = _reaction(id: 'new', user: _carol, note: _note('note1'));
      expect(mergeIncomingNotification(incoming, []), [incoming]);
    });
  });

  group('mergeIncomingNotification / renote', () {
    test('先頭が同じノートへの renote なら renote:grouped に束ねる', () {
      final note = _note('note1');
      final top = _renote(id: 'old', user: _carol, note: note);
      final incoming = _renote(id: 'new', user: _alice, note: note);

      final result = mergeIncomingNotification(incoming, [top]);

      expect(result, hasLength(1));
      final merged = result.first;
      expect(merged.type, 'renote:grouped');
      expect(merged.id, 'old');
      expect(merged.users, [_alice, _carol]);
    });

    test('先頭が既に renote:grouped ならさらに束ねる', () {
      final note = _note('note1');
      final top = NotificationItem(
        id: 'g1',
        createdAt: '2024-01-01T00:00:01.000Z',
        type: 'renote:grouped',
        note: note,
        users: const [_alice, _carol],
      );
      final incoming = _renote(id: 'new', user: _bob, note: note);

      final result = mergeIncomingNotification(incoming, [top]);

      expect(result, hasLength(1));
      expect(result.first.users, [_bob, _alice, _carol]);
    });

    test('先頭が別のノートへの renote なら束ねない', () {
      final top = _renote(id: 'old', user: _carol, note: _note('note1'));
      final incoming = _renote(id: 'new', user: _alice, note: _note('note2'));

      final result = mergeIncomingNotification(incoming, [top]);

      expect(result, hasLength(2));
      expect(result[0], incoming);
      expect(result[1], top);
    });
  });
}
