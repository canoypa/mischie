import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mischie/core/emoji/emoji_providers.dart';
import 'package:mischie/core/error/error_handler.dart';
import 'package:mischie/core/widgets/scrollable_message.dart';
import 'package:mischie/features/timeline/domain/timeline_notifier.dart';
import 'package:mischie/features/timeline/presentation/note_card.dart';

final timelineScreenKey = GlobalKey<TimelineScreenState>();

class TimelineScreen extends ConsumerStatefulWidget {
  TimelineScreen() : super(key: timelineScreenKey);

  @override
  ConsumerState<TimelineScreen> createState() => TimelineScreenState();
}

class TimelineScreenState extends ConsumerState<TimelineScreen> {
  final _scrollController = ScrollController();
  final _loadingMore = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final notifier = ref.read(timelineNotifierProvider.notifier);
    notifier.pendingCount.removeListener(_onPendingChanged);
    notifier.pendingCount.addListener(_onPendingChanged);
  }

  void _onPendingChanged() {
    if (!mounted) return;
    _flushIfAtTop();
  }

  void _flushIfAtTop() {
    if (!_scrollController.hasClients ||
        _scrollController.position.pixels != 0) {
      return;
    }
    final notifier = ref.read(timelineNotifierProvider.notifier);
    if (notifier.pendingCount.value > 0) notifier.flushPending();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _loadingMore.dispose();
    // removeListener は notifier が先に dispose されている場合があるので try
    try {
      ref
          .read(timelineNotifierProvider.notifier)
          .pendingCount
          .removeListener(_onPendingChanged);
    } catch (_) {}
    super.dispose();
  }

  void jumpToTop() {
    if (!_scrollController.hasClients) return;
    _scrollController.jumpTo(0);
  }

  void scrollToTop() {
    if (!_scrollController.hasClients) return;
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  void _onScroll(ScrollUpdateNotification notification) {
    _flushIfAtTop();
    final pos = _scrollController.position;
    if (pos.pixels >= pos.maxScrollExtent - 200 && !_loadingMore.value) {
      _loadMore();
    }
  }

  Future<void> _loadMore() async {
    _loadingMore.value = true;
    try {
      await ref.read(timelineNotifierProvider.notifier).loadMore();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(resolveErrorMessage(e))));
      }
    } finally {
      if (mounted) _loadingMore.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final timelineAsync = ref.watch(timelineNotifierProvider);
    final serverEmojis = ref.watch(emojiCacheProvider).value ?? const {};

    return timelineAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => RefreshIndicator(
        onRefresh: () => ref.read(timelineNotifierProvider.notifier).refresh(),
        child: ScrollableMessage(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(resolveErrorMessage(e)),
              const SizedBox(height: 8),
              FilledButton(
                onPressed: () => ref.invalidate(timelineNotifierProvider),
                child: const Text('再試行'),
              ),
            ],
          ),
        ),
      ),
      data: (notes) => Stack(
        children: [
          RefreshIndicator(
            onRefresh: () =>
                ref.read(timelineNotifierProvider.notifier).refresh(),
            child: notes.isEmpty
                ? const ScrollableMessage(child: Text('ノートがありません'))
                : NotificationListener<ScrollUpdateNotification>(
                    onNotification: (n) {
                      _onScroll(n);
                      return false;
                    },
                    child: ListView.custom(
                      controller: _scrollController,
                      cacheExtent: 1000,
                      // キーで追わないと、先頭に新着が入るたびに表示中のカードが作り直されてガクつく。
                      childrenDelegate: SliverChildBuilderDelegate(
                        (context, index) {
                          if (index == notes.length) {
                            return ValueListenableBuilder<bool>(
                              valueListenable: _loadingMore,
                              builder: (context, loading, _) => loading
                                  ? const Padding(
                                      padding: EdgeInsets.all(16),
                                      child: Center(
                                        child: CircularProgressIndicator(),
                                      ),
                                    )
                                  : const SizedBox(height: 80),
                            );
                          }
                          final note = notes[index];
                          return RepaintBoundary(
                            key: ValueKey(note.id),
                            child: _NoteAppear(
                              noteId: note.id,
                              child: NoteCard(
                                note: note,
                                serverEmojis: serverEmojis,
                              ),
                            ),
                          );
                        },
                        childCount: notes.length + 1,
                        findChildIndexCallback: (key) {
                          if (key is! ValueKey<String>) return null;
                          final index = notes.indexWhere(
                            (n) => n.id == key.value,
                          );
                          return index < 0 ? null : index;
                        },
                      ),
                    ),
                  ),
          ),
          Positioned(
            top: 8,
            left: 0,
            right: 0,
            child: Center(
              child: ValueListenableBuilder<int>(
                valueListenable: ref
                    .read(timelineNotifierProvider.notifier)
                    .pendingCount,
                builder: (context, pendingCount, _) {
                  if (pendingCount == 0) return const SizedBox.shrink();
                  return _NewNotesChip(
                    count: pendingCount,
                    onTap: () {
                      ref
                          .read(timelineNotifierProvider.notifier)
                          .flushPending();
                      scrollToTop();
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NewNotesChip extends StatelessWidget {
  const _NewNotesChip({required this.count, required this.onTap});

  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return FilledButton.tonalIcon(
      onPressed: onTap,
      icon: const Icon(Icons.arrow_upward, size: 18),
      label: Text('新着 $count 件'),
      style: FilledButton.styleFrom(elevation: 3),
    );
  }
}

/// 新着を高さ 0 から開いて差し込む。いきなり挿入すると表示が飛んで見える。
class _NoteAppear extends ConsumerStatefulWidget {
  const _NoteAppear({required this.noteId, required this.child});

  final String noteId;
  final Widget child;

  @override
  ConsumerState<_NoteAppear> createState() => _NoteAppearState();
}

class _NoteAppearState extends ConsumerState<_NoteAppear>
    with SingleTickerProviderStateMixin {
  AnimationController? _controller;

  @override
  void initState() {
    super.initState();
    // 判定は生成時の一度だけ。再構築のたびに判定すると、アニメーションが途中で消える。
    final isNew = ref
        .read(timelineNotifierProvider.notifier)
        .justInserted
        .remove(widget.noteId);
    if (!isNew) return;

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    )..forward();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    if (controller == null) return widget.child;

    final curve = CurvedAnimation(parent: controller, curve: Curves.easeOut);
    return SizeTransition(
      sizeFactor: curve,
      axisAlignment: -1,
      child: FadeTransition(opacity: curve, child: widget.child),
    );
  }
}
