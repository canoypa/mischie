import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mischie/core/providers/core_providers.dart';
import 'package:mischie/core/storage/account_store.dart';
import 'package:mischie/features/auth/domain/account.dart';
import 'package:mischie/features/notification/domain/notification_item.dart';
import 'package:mischie/features/notification/domain/notification_notifier.dart';
import 'package:mischie/features/notification/presentation/notification_screen.dart';
import 'package:mischie/features/profile/domain/profile_notifier.dart';
import 'package:mischie/features/profile/domain/user_detailed.dart';
import 'package:mischie/features/profile/presentation/user_profile_screen.dart';
import 'package:mischie/features/timeline/domain/note.dart';
import 'package:mischie/features/timeline/domain/user.dart';
import 'package:timeago/timeago.dart' as timeago;

/// プロフィールと通知の見た目。更新: flutter test test/goldens --update-goldens
class _EmptyAccountStore implements AccountStore {
  @override
  Future<List<Account>> readAccounts() async => const [];
  @override
  Future<String?> readActiveId() async => null;
  @override
  Future<void> writeAccounts(List<Account> accounts) async {}
  @override
  Future<void> writeActiveId(String? id) async {}
  @override
  Future<void> clear() async {}
}

/// 通知一覧は取得せず、渡したものをそのまま出す。
class _StubNotifications extends NotificationNotifier {
  _StubNotifications(this.items);

  final List<NotificationItem> items;

  @override
  Future<List<NotificationItem>> build() async => items;
}

Future<void> _loadFont(String family, String path) async {
  final file = File(path);
  if (!await file.exists()) return;
  final loader = FontLoader(family)
    ..addFont(file.readAsBytes().then((b) => ByteData.view(b.buffer)));
  await loader.load();
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

Future<void> _pump(
  WidgetTester tester,
  Widget child, {
  List<dynamic> overrides = const [],
  Brightness brightness = Brightness.light,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        accountStoreProvider.overrideWithValue(_EmptyAccountStore()),
        ...overrides.cast(),
      ],
      child: MaterialApp(
        theme: ThemeData(
          useMaterial3: true,
          colorSchemeSeed: const Color(0xFFA8E800),
          brightness: brightness,
        ),
        home: child,
      ),
    ),
  );
  await tester.pump();
}

void main() {
  setUpAll(() async {
    timeago.setLocaleMessages('ja', timeago.JaMessages());
    await _loadFont('Roboto', '/System/Library/Fonts/ヒラギノ角ゴシック W3.ttc');
    final flutterRoot = Platform.environment['FLUTTER_ROOT'];
    if (flutterRoot != null) {
      await _loadFont(
        'MaterialIcons',
        '$flutterRoot/bin/cache/artifacts/material_fonts/'
            'MaterialIcons-Regular.otf',
      );
    }
  });

  testWidgets('通知の種別表示', (tester) async {
    await _pump(
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
    await _pump(
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
    await _pump(
      tester,
      const Scaffold(body: UserProfileView(userId: 'u1')),
      overrides: [
        userDetailProvider('u1').overrideWith(
          (ref) async => const UserDetailed(
            id: 'u1',
            username: 'cano',
            name: 'Cano',
            description: 'Flutter で Misskey クライアントを作っています。',
            isCat: true,
            followersCount: 128,
            followingCount: 64,
            notesCount: 1024,
            location: '東京',
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
