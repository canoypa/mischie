import 'package:flutter_test/flutter_test.dart';
import 'package:mischie/features/timeline/domain/note.dart';
import 'package:mischie/features/timeline/domain/user.dart';

void main() {
  group('User.fromJson', () {
    test('必須フィールドのみ', () {
      final user = User.fromJson({
        'id': 'user1',
        'username': 'alice',
      });
      expect(user.id, 'user1');
      expect(user.username, 'alice');
      expect(user.name, isNull);
      expect(user.avatarUrl, isNull);
      expect(user.host, isNull);
    });

    test('全フィールドあり', () {
      final user = User.fromJson({
        'id': 'user1',
        'username': 'alice',
        'name': 'Alice',
        'avatarUrl': 'https://example.com/avatar.png',
        'host': 'misskey.io',
      });
      expect(user.name, 'Alice');
      expect(user.avatarUrl, 'https://example.com/avatar.png');
      expect(user.host, 'misskey.io');
    });
  });

  group('Note.fromJson', () {
    final userJson = {'id': 'user1', 'username': 'alice'};

    test('テキストノート', () {
      final note = Note.fromJson({
        'id': 'note1',
        'createdAt': '2024-01-01T00:00:00.000Z',
        'user': userJson,
        'text': 'Hello',
      });
      expect(note.id, 'note1');
      expect(note.text, 'Hello');
      expect(note.renote, isNull);
    });

    test('テキストなし', () {
      final note = Note.fromJson({
        'id': 'note2',
        'createdAt': '2024-01-01T00:00:00.000Z',
        'user': userJson,
      });
      expect(note.text, isNull);
    });

    test('リノートあり', () {
      final note = Note.fromJson({
        'id': 'note3',
        'createdAt': '2024-01-01T00:00:00.000Z',
        'user': userJson,
        'renote': {
          'id': 'note_orig',
          'createdAt': '2024-01-01T00:00:00.000Z',
          'user': userJson,
          'text': 'Original',
        },
      });
      expect(note.renote, isNotNull);
      expect(note.renote!.id, 'note_orig');
      expect(note.renote!.text, 'Original');
    });
  });
}
