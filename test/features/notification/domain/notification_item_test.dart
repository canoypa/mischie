import 'package:flutter_test/flutter_test.dart';
import 'package:mischie/features/notification/domain/notification_item.dart';

void main() {
  final userJson = {'id': 'u1', 'username': 'cano', 'name': 'Cano'};
  final noteJson = {
    'id': 'note1',
    'createdAt': '2024-01-01T00:00:00.000Z',
    'user': userJson,
    'text': 'hello',
  };

  group('NotificationItem.fromJson / 既存の種別', () {
    test('reaction は user と reaction を持つ', () {
      final item = NotificationItem.fromJson({
        'id': 'n1',
        'createdAt': '2024-01-01T00:00:00.000Z',
        'type': 'reaction',
        'user': userJson,
        'note': noteJson,
        'reaction': '👍',
      });

      expect(item.type, 'reaction');
      expect(item.user?.username, 'cano');
      expect(item.reaction, '👍');
      expect(item.reactions, isNull);
      expect(item.users, isNull);
    });

    test('follow は note を持たない', () {
      final item = NotificationItem.fromJson({
        'id': 'n2',
        'createdAt': '2024-01-01T00:00:00.000Z',
        'type': 'follow',
        'user': userJson,
      });

      expect(item.note, isNull);
      expect(item.reactions, isNull);
    });
  });

  group('NotificationItem.fromJson / まとめ通知', () {
    test('reaction:grouped は reactions を持ち、user は無い', () {
      final item = NotificationItem.fromJson({
        'id': 'g1',
        'createdAt': '2024-01-01T00:00:00.000Z',
        'type': 'reaction:grouped',
        'note': noteJson,
        'reactions': [
          {'user': userJson, 'reaction': '👍'},
          {
            'user': {'id': 'u2', 'username': 'alice'},
            'reaction': '🎉',
          },
        ],
      });

      expect(item.type, 'reaction:grouped');
      expect(item.user, isNull);
      expect(item.note?.id, 'note1');
      expect(item.reactions, hasLength(2));
      expect(item.reactions![0].user.username, 'cano');
      expect(item.reactions![0].reaction, '👍');
      expect(item.reactions![1].user.username, 'alice');
      expect(item.reactions![1].reaction, '🎉');
    });

    test('renote:grouped は users を持ち、user は無い', () {
      final item = NotificationItem.fromJson({
        'id': 'g2',
        'createdAt': '2024-01-01T00:00:00.000Z',
        'type': 'renote:grouped',
        'note': noteJson,
        'users': [
          userJson,
          {'id': 'u2', 'username': 'alice'},
        ],
      });

      expect(item.type, 'renote:grouped');
      expect(item.user, isNull);
      expect(item.users, hasLength(2));
      expect(item.users![0].username, 'cano');
      expect(item.users![1].username, 'alice');
    });
  });
}
