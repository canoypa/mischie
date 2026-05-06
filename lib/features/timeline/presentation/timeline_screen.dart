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
    _scrollController.addListener(_onScroll);
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
    setState(() {
      _pendingCount = ref
          .read(timelineNotifierProvider.notifier)
          .pendingCount
          .value;
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

  void scrollToTop() {
    if (!_scrollController.hasClients) return;
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  void _onScroll() {
    final pos = _scrollController.position;
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
                : ListView.builder(
                    controller: _scrollController,
                    itemCount: notes.length + 1,
                    itemBuilder: (context, index) {
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
                      return NoteCard(
                        note: notes[index],
                        serverEmojis: serverEmojis,
                      );
                    },
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

class _NewNotesChip extends StatelessWidget {
  const _NewNotesChip({required this.count, required this.onTap});

  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(40),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.arrow_upward,
                size: 16,
                color: colorScheme.onPrimaryContainer,
              ),
              const SizedBox(width: 4),
              Text(
                '新着 $count 件',
                style: TextStyle(
                  color: colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
