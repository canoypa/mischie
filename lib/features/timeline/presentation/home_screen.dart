import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mischie/features/compose/presentation/compose_screen.dart';
import 'package:mischie/core/emoji/emoji_providers.dart';
import 'package:mischie/features/notification/domain/notification_notifier.dart';
import 'package:mischie/features/notification/presentation/notification_screen.dart';
import 'package:mischie/features/profile/presentation/profile_screen.dart';
import 'package:mischie/features/search/presentation/search_screen.dart';
import 'package:mischie/features/settings/presentation/settings_screen.dart';
import 'package:mischie/features/timeline/domain/timeline_kind.dart';
import 'package:mischie/features/timeline/domain/timeline_notifier.dart';
import 'package:mischie/features/timeline/domain/timeline_source.dart';
import 'package:mischie/features/timeline/domain/user_list.dart';
import 'package:mischie/features/timeline/presentation/timeline_screen.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with TickerProviderStateMixin {
  int _currentIndex = 0;
  StreamSubscription<List<SharedMediaFile>>? _shareSubscription;
  late TabController _tabController;

  List<TimelineSource> _sources = [
    for (final kind in TimelineKind.values) TimelineSource.builtin(kind),
  ];

  /// 復元待ちのキー。済んだら null。
  String? _savedSourceKey;

  static const _sourcePrefKey = 'selected_timeline';

  // ホームは下のタブが種類を示すので、タイトルはアプリ名にする
  static const _titles = ['Mischie', '検索', '通知', 'プロフィール'];

  final _screens = [
    TimelineScreen(),
    const SearchScreen(),
    NotificationScreen(),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = _createTabController();
    _restoreSelection();
    // 共有はログイン後にしか受け取れないので、ここで購読する。
    _shareSubscription = ReceiveSharingIntent.instance.getMediaStream().listen(
      _openComposeWithShared,
    );
    ReceiveSharingIntent.instance.getInitialMedia().then((media) {
      if (media.isEmpty) return;
      _openComposeWithShared(media);
      // 同じ共有で二重に開かないよう、受け取ったら破棄する
      ReceiveSharingIntent.instance.reset();
    });
  }

  /// リストは後から届くので、タブを組み直すたびに呼ぶ。
  Future<void> _restoreSelection() async {
    _savedSourceKey ??= await ref
        .read(prefsStoreProvider)
        .read<String>(_sourcePrefKey);
    final key = _savedSourceKey;
    if (key == null || !mounted) return;

    final index = _sources.indexWhere((s) => s.storageKey == key);
    if (index < 0) return; // まだリストが届いていない

    _savedSourceKey = null;
    if (index == _timelineTabIndex) return;
    _timelineTabIndex = index;
    _tabController.index = index;
    ref.read(selectedTimelineProvider.notifier).source = _sources[index];
  }

  TabController _createTabController({int initialIndex = 0}) => TabController(
    length: _sources.length,
    initialIndex: initialIndex,
    vsync: this,
  )..addListener(_onTimelineTabChanged);

  void _rebuildTabs(List<UserList> lists) {
    final sources = <TimelineSource>[
      for (final kind in TimelineKind.values) TimelineSource.builtin(kind),
      for (final list in lists)
        TimelineSource.list(id: list.id, name: list.name),
    ];
    final unchanged =
        sources.length == _sources.length &&
        Iterable.generate(sources.length).every(
          (i) =>
              sources[i] == _sources[i] &&
              sources[i].label == _sources[i].label,
        );
    if (unchanged) return;

    // 位置ではなく中身で追う。前にあるリストが消えると位置がずれる
    var index = sources.indexOf(_sources[_timelineTabIndex]);
    if (index < 0) {
      index = 0;
      ref.read(selectedTimelineProvider.notifier).source = sources[index];
    }

    final previous = _tabController..removeListener(_onTimelineTabChanged);
    setState(() {
      _sources = sources;
      _timelineTabIndex = index;
      _tabController = _createTabController(initialIndex: index);
    });
    previous.dispose();
    _restoreSelection();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _shareSubscription?.cancel();
    super.dispose();
  }

  int _timelineTabIndex = 0;

  void _onTimelineTabChanged() {
    // indexIsChanging を待つとタブの切り替えアニメーション分だけ
    // 表示が遅れるので、index が動いた時点で切り替える
    if (_tabController.index == _timelineTabIndex) return;
    _timelineTabIndex = _tabController.index;
    final source = _sources[_timelineTabIndex];
    ref.read(selectedTimelineProvider.notifier).source = source;
    ref.read(prefsStoreProvider).write(_sourcePrefKey, source.storageKey);
    timelineScreenKey.currentState?.jumpToTop();
  }

  void _openComposeWithShared(List<SharedMediaFile> media) {
    if (media.isEmpty || !mounted) return;

    final filePaths = <String>[];
    final texts = <String>[];
    for (final item in media) {
      switch (item.type) {
        case SharedMediaType.image:
        case SharedMediaType.video:
        case SharedMediaType.file:
          filePaths.add(item.path);
        case SharedMediaType.text:
          texts.add(item.path);
        case SharedMediaType.url:
          // OAuth のコールバック（mischie://）も共有として届くので捨てる
          if (Uri.tryParse(item.path)?.scheme == 'mischie') continue;
          texts.add(item.path);
      }
    }
    if (filePaths.isEmpty && texts.isEmpty) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ComposeScreen(
          initialText: texts.isEmpty ? null : texts.join('\n'),
          initialFilePaths: filePaths,
        ),
      ),
    );
  }

  void _onDestinationSelected(int i) {
    if (i == _currentIndex) {
      switch (i) {
        case 0:
          timelineScreenKey.currentState?.scrollToTop();
        case 2:
          notificationScreenKey.currentState?.scrollToTop();
      }
      return;
    }
    // 開いている間に届いた分も見たことになるので、離れるときにも既読にする
    if (i == 2 || _currentIndex == 2) {
      ref.read(notificationNotifierProvider.notifier).markAllRead();
    }
    setState(() => _currentIndex = i);
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(userListsProvider, (_, next) {
      final lists = next.value;
      if (lists != null) _rebuildTabs(lists);
    });
    // アカウントを切り替えるとホームに戻されるので、タブもそれに合わせる
    ref.listen(selectedTimelineProvider, (_, next) {
      final index = _sources.indexOf(next);
      if (index < 0 || index == _tabController.index) return;
      _timelineTabIndex = index;
      _tabController.index = index;
    });

    return PopScope(
      canPop: _currentIndex == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _onDestinationSelected(0);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(_titles[_currentIndex]),
          actions: [
            if (_currentIndex == 3)
              IconButton(
                icon: const Icon(Icons.settings_outlined),
                tooltip: '設定',
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const SettingsScreen()),
                ),
              ),
          ],
          bottom: _currentIndex == 0
              ? TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  tabAlignment: TabAlignment.start,
                  tabs: [
                    for (final source in _sources) Tab(text: source.label),
                  ],
                  onTap: (index) {
                    if (!_tabController.indexIsChanging &&
                        index == _timelineTabIndex) {
                      timelineScreenKey.currentState?.scrollToTop();
                    }
                  },
                )
              : null,
        ),
        body: IndexedStack(index: _currentIndex, children: _screens),
        floatingActionButton: FloatingActionButton(
          tooltip: 'ノートを書く',
          onPressed: () => Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => const ComposeScreen())),
          child: const Icon(Icons.edit),
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: _onDestinationSelected,
          destinations: [
            const NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: 'ホーム',
            ),
            const NavigationDestination(
              icon: Icon(Icons.search_outlined),
              selectedIcon: Icon(Icons.search),
              label: '検索',
            ),
            NavigationDestination(
              icon: _UnreadBadge(
                child: const Icon(Icons.notifications_outlined),
              ),
              selectedIcon: const Icon(Icons.notifications),
              label: '通知',
            ),
            const NavigationDestination(
              icon: Icon(Icons.person_outlined),
              selectedIcon: Icon(Icons.person),
              label: 'プロフィール',
            ),
          ],
        ),
      ),
    );
  }
}

/// 通知一覧の再構築に巻き込まれないよう、ValueNotifier を直接聴く。
class _UnreadBadge extends ConsumerWidget {
  const _UnreadBadge({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ValueListenableBuilder<int>(
      valueListenable: ref
          .read(notificationNotifierProvider.notifier)
          .unreadCount,
      builder: (context, count, child) =>
          Badge.count(count: count, isLabelVisible: count > 0, child: child),
      child: child,
    );
  }
}
