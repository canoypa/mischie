import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mischie/core/emoji/emoji_providers.dart';
import 'package:mischie/core/error/error_handler.dart';
import 'package:mischie/features/timeline/domain/timeline_notifier.dart';
import 'package:mischie/features/timeline/presentation/note_card.dart';

/// HomeScreen から scrollToTop() を呼ぶための GlobalKey。
final timelineScreenKey = GlobalKey<TimelineScreenState>();

class TimelineScreen extends ConsumerStatefulWidget {
  TimelineScreen() : super(key: timelineScreenKey);

  @override
  ConsumerState<TimelineScreen> createState() => TimelineScreenState();
}

class TimelineScreenState extends ConsumerState<TimelineScreen> {
  final _scrollController = ScrollController();
  bool _loadingMore = false;
  int _pendingCount = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // ValueNotifier を listen してカウントを受け取る
    final notifier = ref.read(timelineNotifierProvider.notifier);
    notifier.pendingCount.removeListener(_onPendingChanged);
    notifier.pendingCount.addListener(_onPendingChanged);
  }

  void _onPendingChanged() {
    if (!mounted) return;
    final notifier = ref.read(timelineNotifierProvider.notifier);
    final count = notifier.pendingCount.value;

    // 最上部にいる場合は自動で表示
    if (_scrollController.hasClients &&
        _scrollController.position.pixels == 0) {
      notifier.flushPending();
      // バッジを即座にリセット
      if (_pendingCount != 0) setState(() => _pendingCount = 0);
      return;
    }

    setState(() {
      _pendingCount = count;
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    // removeListener は notifier が先に dispose されている場合があるので try
    try {
      ref
          .read(timelineNotifierProvider.notifier)
          .pendingCount
          .removeListener(_onPendingChanged);
    } catch (_) {}
    super.dispose();
  }

  /// タイムラインを切り替えたときなど、アニメーションなしで先頭に戻す。
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
    final pos = _scrollController.position;
    // 最上部に戻ったとき、新着があれば自動表示
    if (pos.pixels == 0 && _pendingCount > 0) {
      ref.read(timelineNotifierProvider.notifier).flushPending();
      setState(() => _pendingCount = 0);
    }
    // 末尾 200px 以内に来たら追加ロード
    if (pos.pixels >= pos.maxScrollExtent - 200 && !_loadingMore) {
      _loadMore();
    }
  }

  Future<void> _loadMore() async {
    setState(() => _loadingMore = true);
    await ref.read(timelineNotifierProvider.notifier).loadMore();
    if (mounted) setState(() => _loadingMore = false);
  }

  @override
  Widget build(BuildContext context) {
    final timelineAsync = ref.watch(timelineNotifierProvider);
    final serverEmojis = ref.watch(emojiCacheProvider).value ?? const {};
    final pendingCount = _pendingCount;

    return timelineAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(
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
      data: (notes) => Stack(
        children: [
          RefreshIndicator(
            onRefresh: () =>
                ref.read(timelineNotifierProvider.notifier).refresh(),
            child: notes.isEmpty
                ? const Center(child: Text('ノートがありません'))
                : NotificationListener<ScrollUpdateNotification>(
                    onNotification: (n) {
                      _onScroll(n);
                      return false;
                    },
                    child: ListView.custom(
                      controller: _scrollController,
                      cacheExtent: 1000,
                      // 新着は先頭に挿入されるので、キーが無いと全カードの
                      // index がずれて、表示中のカードが丸ごと作り直される
                      // （新着のたびに一瞬ガクつく原因）。
                      childrenDelegate: SliverChildBuilderDelegate(
                        (context, index) {
                          if (index == notes.length) {
                            return _loadingMore
                                ? const Padding(
                                    padding: EdgeInsets.all(16),
                                    child: Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                  )
                                : const SizedBox(height: 80);
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
          // 新着ノートチップ
          if (pendingCount > 0)
            Positioned(
              top: 8,
              left: 0,
              right: 0,
              child: Center(
                child: _NewNotesChip(
                  count: pendingCount,
                  onTap: () {
                    ref.read(timelineNotifierProvider.notifier).flushPending();
                    scrollToTop();
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// 新着を知らせるボタン。影や角丸を自前で組まず、Material 3 の
/// tonal button に任せる（テーマの状態レイヤーや高さもそのまま乗る）。
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

/// 新着ノートを高さ 0 から開いて差し込む。
///
/// アニメーション無しで挿入すると、上に要素が生えた分だけ表示が飛んで見える。
/// 対象は「今回 flush で差し込まれたノート」だけで、最初から並んでいた
/// ノートやスクロールで作り直されたノートは動かさない。
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
    // 判定は生成時の一度きり。以降の再構築で animate が変わって
    // ウィジェットが差し替わる（＝途中で消える）のを避ける。
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
