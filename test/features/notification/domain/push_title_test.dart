import 'package:flutter_test/flutter_test.dart';
import 'package:mischie/features/notification/domain/notification_item.dart';
import 'package:mischie/features/notification/domain/notification_label.dart';
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
  group('notificationSummary', () {
    test('リアクションは内容まで出す', () {
      expect(
        notificationSummary(_item('reaction', reaction: '👍')),
        'Cano がリアクション 👍',
      );
    });

    test('リアクションの内容が無くても末尾が空かない', () {
      // 以前は '${item.reaction ?? ''}' で末尾に空白が残っていた
      expect(notificationSummary(_item('reaction')), 'Cano がリアクション');
    });

    test('種別ごとの文言', () {
      expect(notificationSummary(_item('reply')), 'Cano が返信');
      expect(notificationSummary(_item('renote')), 'Cano がリノート');
      expect(notificationSummary(_item('quote')), 'Cano が引用');
      expect(notificationSummary(_item('mention')), 'Cano がメンション');
      expect(notificationSummary(_item('follow')), 'Cano にフォローされました');
      expect(
        notificationSummary(_item('followRequestAccepted')),
        'Cano がフォローを承認しました',
      );
    });

    test('表示名が無ければユーザー名を使う', () {
      expect(
        notificationSummary(
          _item(
            'reply',
            user: const User(id: 'u1', username: 'cano'),
          ),
        ),
        'cano が返信',
      );
    });

    test('相手のいない通知は名前を付けない', () {
      // 「Cano が 投票が終了しました」では文が壊れる
      expect(notificationSummary(_item('pollEnded')), '投票が終了しました');
      expect(notificationSummary(_item('achievementEarned')), '実績を獲得しました');
    });

    test('訳の無い種別でも識別子を出さない', () {
      // 以前は 'roleAssignedTo' のような英語がそのまま画面に出ていた
      expect(notificationSummary(_item('somethingNew')), '通知');
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
