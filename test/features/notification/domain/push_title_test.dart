import 'package:flutter_test/flutter_test.dart';
import 'package:mischie/features/notification/domain/notification_item.dart';
import 'package:mischie/features/notification/domain/push_notifier.dart';
import 'package:mischie/features/timeline/domain/user.dart';

NotificationItem _item(String type, {String? reaction, User? user}) =>
    NotificationItem(
      id: 'n1',
      createdAt: '2026-08-19T00:00:00.000Z',
      type: type,
      user: user ?? const User(id: 'u1', username: 'cano', name: 'Cano'),
      reaction: reaction,
    );

void main() {
  group('pushNotificationTitle', () {
    test('リアクションは内容まで出す', () {
      expect(
        pushNotificationTitle(_item('reaction', reaction: '👍')),
        'Cano がリアクション 👍',
      );
    });

    test('リアクションの内容が無くても末尾が空かない', () {
      // 以前は '${item.reaction ?? ''}' で末尾に空白が残っていた
      expect(pushNotificationTitle(_item('reaction')), 'Cano がリアクション');
    });

    test('種別ごとの文言', () {
      expect(pushNotificationTitle(_item('reply')), 'Cano が返信');
      expect(pushNotificationTitle(_item('renote')), 'Cano がリノート');
      expect(pushNotificationTitle(_item('quote')), 'Cano が引用');
      expect(pushNotificationTitle(_item('mention')), 'Cano がメンション');
      expect(pushNotificationTitle(_item('follow')), 'Cano にフォローされました');
      expect(
        pushNotificationTitle(_item('followRequestAccepted')),
        'Cano がフォローを承認しました',
      );
    });

    test('表示名が無ければユーザー名を使う', () {
      expect(
        pushNotificationTitle(
          _item(
            'reply',
            user: const User(id: 'u1', username: 'cano'),
          ),
        ),
        'cano が返信',
      );
    });

    test('知らない種別でも名前だけは出す', () {
      expect(pushNotificationTitle(_item('achievementEarned')), 'Cano');
    });
  });

  group('NotificationItem.fromJson', () {
    test('プッシュのペイロードを読める', () {
      // Misskey の Web Push は {type: 'notification', body: <通知>} を送る。
      // body は i/notifications と同じ形。
      final item = NotificationItem.fromJson({
        'id': 'abc',
        'createdAt': '2026-08-19T00:00:00.000Z',
        'type': 'reaction',
        'reaction': ':kawaii@.:',
        'user': {'id': 'u1', 'username': 'cano', 'name': 'Cano'},
        'note': {
          'id': 'n1',
          'createdAt': '2026-08-19T00:00:00.000Z',
          'user': {'id': 'u2', 'username': 'other'},
          'text': '本文',
        },
      });

      expect(item.type, 'reaction');
      expect(item.reaction, ':kawaii@.:');
      expect(item.user?.name, 'Cano');
      expect(item.note?.text, '本文');
    });
  });
}
