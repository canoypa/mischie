import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mischie/features/compose/presentation/compose_screen.dart';
import 'package:mischie/features/notification/presentation/notification_screen.dart';
import 'package:mischie/features/profile/presentation/profile_screen.dart';
import 'package:mischie/features/timeline/domain/timeline_kind.dart';
import 'package:mischie/features/timeline/domain/timeline_notifier.dart';
import 'package:mischie/features/timeline/presentation/timeline_screen.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  StreamSubscription<List<SharedMediaFile>>? _shareSubscription;
  late final TabController _tabController;

  // ホームは下のタブが種類を示すので、タイトルはアプリ名にする
  static const _titles = ['Mischie', '通知', 'プロフィール'];

  final _screens = [
    TimelineScreen(),
    const NotificationScreen(),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: TimelineKind.values.length,
      vsync: this,
    )..addListener(_onTimelineTabChanged);
    // 共有を受け取れるのはログイン後だけなので、HomeScreen で購読する。
    // 起動中の共有と、共有から起動された場合の両方を拾う。
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
    ref.read(selectedTimelineKindProvider.notifier).kind =
        TimelineKind.values[_timelineTabIndex];
    // 別のタイムラインになるので、読んでいた位置には意味がない
    timelineScreenKey.currentState?.jumpToTop();
  }

  void _openComposeWithShared(List<SharedMediaFile> media) {
    if (media.isEmpty || !mounted) return;

    final imagePaths = <String>[];
    final texts = <String>[];
    for (final item in media) {
      switch (item.type) {
        case SharedMediaType.image:
          imagePaths.add(item.path);
        case SharedMediaType.text:
        case SharedMediaType.url:
          texts.add(item.path);
        case SharedMediaType.video:
        case SharedMediaType.file:
          break;
      }
    }
    if (imagePaths.isEmpty && texts.isEmpty) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ComposeScreen(
          initialText: texts.isEmpty ? null : texts.join('\n'),
          initialImagePaths: imagePaths,
        ),
      ),
    );
  }

  void _onDestinationSelected(int i) {
    if (i == 0 && _currentIndex == 0) {
      // すでにホームにいる → 最上部へスクロール
      timelineScreenKey.currentState?.scrollToTop();
      return;
    }
    setState(() => _currentIndex = i);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_currentIndex]),
        bottom: _currentIndex == 0
            ? TabBar(
                controller: _tabController,
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                tabs: [
                  for (final kind in TimelineKind.values) Tab(text: kind.label),
                ],
              )
            : null,
      ),
      body: IndexedStack(index: _currentIndex, children: _screens),
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton(
              onPressed: () => Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const ComposeScreen())),
              child: const Icon(Icons.edit),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: _onDestinationSelected,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'ホーム',
          ),
          NavigationDestination(
            icon: Icon(Icons.notifications_outlined),
            selectedIcon: Icon(Icons.notifications),
            label: '通知',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outlined),
            selectedIcon: Icon(Icons.person),
            label: 'プロフィール',
          ),
        ],
      ),
    );
  }
}
