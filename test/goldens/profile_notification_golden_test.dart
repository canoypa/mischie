import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../support/golden_support.dart';
import 'package:mischie/features/notification/domain/notification_item.dart';
import 'package:mischie/features/notification/domain/notification_notifier.dart';
import 'package:mischie/features/notification/presentation/notification_screen.dart';
import 'package:mischie/features/profile/domain/profile_notifier.dart';
import 'package:mischie/features/profile/domain/user_detailed.dart';
import 'package:mischie/features/profile/presentation/user_profile_screen.dart';
import 'package:mischie/features/timeline/domain/note.dart';
import 'package:mischie/features/timeline/domain/user.dart';

/// プロフィールと通知の見た目。更新: flutter test test/goldens --update-goldens
/// 通知一覧は取得せず、渡したものをそのまま出す。
class _StubNotifications extends NotificationNotifier {
  _StubNotifications(this.items);

  final List<NotificationItem> items;

  @override
  Future<List<NotificationItem>> build() async => items;
}

const _user = User(id: 'u1', username: 'cano', name: 'Cano', isCat: true);
const _user2 = User(id: 'u2', username: 'alice', name: 'Alice');
const _user3 = User(id: 'u3', username: 'bob', name: 'Bob');
const _user4 = User(id: 'u4', username: 'eve', name: 'Eve');
const _user5 = User(id: 'u5', username: 'mallory', name: 'Mallory');
const _user6 = User(id: 'u6', username: 'trent', name: 'Trent');
const _user7 = User(id: 'u7', username: 'carol', name: 'Carol');
const _user8 = User(id: 'u8', username: 'dave', name: 'Dave');

NotificationItem _item(String type, {String? reaction, Note? note}) =>
    NotificationItem(
      id: type,
      createdAt: DateTime.now()
          .subtract(const Duration(minutes: 3))
          .toIso8601String(),
      type: type,
      user: _user,
      note: note,
      reaction: reaction,
    );

Note _note(String text) => Note(
  id: 'n1',
  createdAt: DateTime.now().toIso8601String(),
  user: _user,
  text: text,
);

// ストリーミングでの束ね（notification_merge.dart）が作るのと同じ形。
// 先頭 = 最新の相手。8 人にして、スタックの上限（6 人 + "+2"）も見る。
NotificationItem _groupedReaction() => NotificationItem(
  id: 'g-reaction',
  createdAt: DateTime.now()
      .subtract(const Duration(minutes: 1))
      .toIso8601String(),
  type: 'reaction:grouped',
  note: _note('リアクションされたノート'),
  reactions: const [
    GroupedReaction(user: _user, reaction: '👍'),
    GroupedReaction(user: _user2, reaction: '👍'),
    GroupedReaction(user: _user3, reaction: '🎉'),
    GroupedReaction(user: _user4, reaction: '👍'),
    GroupedReaction(user: _user5, reaction: '😀'),
    GroupedReaction(user: _user6, reaction: '👍'),
    GroupedReaction(user: _user7, reaction: '🎉'),
    GroupedReaction(user: _user8, reaction: '👍'),
  ],
);

NotificationItem _groupedRenote() => NotificationItem(
  id: 'g-renote',
  createdAt: DateTime.now()
      .subtract(const Duration(minutes: 2))
      .toIso8601String(),
  type: 'renote:grouped',
  note: _note('リノートされたノート'),
  users: const [_user, _user2, _user3],
);

void main() {
  setUpAll(loadGoldenFonts);

  testWidgets('通知の種別表示', (tester) async {
    // まとめ通知の行は 1 行増えるぶん縦に長い。既定の 600 では末尾の
    // まとめ通知がビューポートの外に出て、ListView.builder に
    // 描かれなくなる（ゴールデンにも映らない）。
    addTearDown(tester.view.reset);
    tester.view.physicalSize = const Size(800, 900);
    tester.view.devicePixelRatio = 1;
    await pumpGolden(
      tester,
      const Scaffold(body: NotificationScreen()),
      overrides: [
        notificationNotifierProvider.overrideWith(
          () => _StubNotifications([
            _item('reaction', reaction: '👍', note: _note('リアクションされたノート')),
            _item('reply', note: _note('返信の本文')),
            _item('renote', note: _note('リノートされたノート')),
            _item('mention', note: _note('@cano めんしょん')),
            _item('follow'),
            // 相手のいない通知でも文が壊れないこと
            _item('pollEnded'),
            _item('achievementEarned'),
            // まとめ通知（reaction:grouped / renote:grouped）
            _groupedReaction(),
            _groupedRenote(),
          ]),
        ),
      ],
    );
    await tester.pump();

    await expectLater(
      find.byType(NotificationScreen),
      matchesGoldenFile('notification_screen.png'),
    );
  });

  // 種別バッジは primary / tertiary の上に onPrimary / onTertiary を置く。
  // 暗所でコントラストが崩れないかを見る。
  testWidgets('通知の種別表示 / ダーク', (tester) async {
    addTearDown(tester.view.reset);
    tester.view.physicalSize = const Size(800, 900);
    tester.view.devicePixelRatio = 1;
    await pumpGolden(
      tester,
      const Scaffold(body: NotificationScreen()),
      brightness: Brightness.dark,
      overrides: [
        notificationNotifierProvider.overrideWith(
          () => _StubNotifications([
            _item('reaction', reaction: '👍', note: _note('リアクションされたノート')),
            _item('reply', note: _note('返信の本文')),
            _item('renote', note: _note('リノートされたノート')),
            _item('follow'),
            // 相手のいない通知でも文が壊れないこと
            _item('pollEnded'),
            _item('achievementEarned'),
            // まとめ通知（reaction:grouped / renote:grouped）
            _groupedReaction(),
            _groupedRenote(),
          ]),
        ),
      ],
    );
    await tester.pump();

    await expectLater(
      find.byType(NotificationScreen),
      matchesGoldenFile('notification_screen_dark.png'),
    );
  });

  testWidgets('プロフィールのヘッダー', (tester) async {
    await pumpGolden(
      tester,
      const Scaffold(body: UserProfileView(userId: 'u1')),
      overrides: [
        userDetailProvider('u1').overrideWith(
          (ref) async => UserDetailed(
            id: 'u1',
            username: 'cano',
            name: 'Cano',
            description: 'Flutter で Misskey クライアントを作っています。',
            isCat: true,
            followersCount: 128,
            followingCount: 64,
            notesCount: 1024,
            location: '東京',
            pinnedNotes: [
              Note(
                id: 'pinned1',
                // 固定日時にすると相対時刻の表示が日ごとに変わり、
                // 見た目が同じでもゴールデンが落ちる
                createdAt: DateTime.now()
                    .subtract(const Duration(hours: 4))
                    .toIso8601String(),
                user: _user,
                text: 'ここに固定した投稿が出ます。',
              ),
            ],
          ),
        ),
      ],
    );
    await tester.pump();

    await expectLater(
      find.byType(UserProfileView),
      matchesGoldenFile('profile_header.png'),
    );
  });
}
