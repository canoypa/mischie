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

void main() {
  setUpAll(loadGoldenFonts);

  testWidgets('通知の種別表示', (tester) async {
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
                createdAt: '2026-08-19T00:00:00.000Z',
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
