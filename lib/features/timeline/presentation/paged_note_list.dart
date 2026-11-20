import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mischie/core/emoji/emoji_providers.dart';
import 'package:mischie/core/error/error_handler.dart';
import 'package:mischie/features/timeline/domain/note.dart';
import 'package:mischie/features/timeline/domain/note_store.dart';
import 'package:mischie/features/timeline/presentation/note_card.dart';

/// 続きの起点がノートの ID とは限らないので、取得側が返す。
typedef NotePage = ({List<Note> notes, String? nextUntilId});

typedef NotePageFetcher = Future<NotePage> Function({String? untilId});

NotePageFetcher notePages(
  Future<List<Note>> Function({String? untilId}) fetch,
) => ({untilId}) async {
  final notes = await fetch(untilId: untilId);
  return (notes: notes, nextUntilId: notes.isEmpty ? null : notes.last.id);
};

/// [header] は sliver で渡す。
class PagedNoteList extends ConsumerStatefulWidget {
  const PagedNoteList({
    super.key,
    required this.fetch,
    required this.emptyText,
    this.header,
    this.onRefresh,
  });

  final NotePageFetcher fetch;
  final String emptyText;
  final Widget? header;

  /// 一覧の再取得と並行して呼ぶ。
  final Future<void> Function()? onRefresh;

  @override
  ConsumerState<PagedNoteList> createState() => _PagedNoteListState();
}

class _PagedNoteListState extends ConsumerState<PagedNoteList> {
  final List<Note> _notes = [];
  bool _loading = true;
  bool _loadingMore = false;
  String? _nextUntilId;
  Object? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final page = await widget.fetch();
      if (!mounted) return;
      ref.read(noteOverridesProvider.notifier).evictFetched(page.notes);
      setState(() {
        _notes
          ..clear()
          ..addAll(page.notes);
        _nextUntilId = page.nextUntilId;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e;
        _loading = false;
      });
    }
  }

  Future<void> _refresh() async {
    await Future.wait([_load(), ?widget.onRefresh?.call()]);
  }

  Future<void> _loadMore() async {
    final untilId = _nextUntilId;
    if (_loading || _loadingMore || untilId == null) return;
    setState(() => _loadingMore = true);
    try {
      final page = await widget.fetch(untilId: untilId);
      if (!mounted) return;
      ref.read(noteOverridesProvider.notifier).evictFetched(page.notes);
      setState(() {
        _notes.addAll(page.notes);
        _nextUntilId = page.nextUntilId;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(resolveErrorMessage(e))));
    } finally {
      if (mounted) setState(() => _loadingMore = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final serverEmojis = ref.watch(emojiCacheProvider).value ?? const {};

    return RefreshIndicator(
      onRefresh: _refresh,
      child: NotificationListener<ScrollUpdateNotification>(
        onNotification: (n) {
          final pos = n.metrics;
          if (pos.pixels >= pos.maxScrollExtent - 300) _loadMore();
          return false;
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            ?widget.header,
            if (_loading && _notes.isEmpty)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(child: CircularProgressIndicator()),
                ),
              )
            else if (_error != null && _notes.isEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    children: [
                      Text(resolveErrorMessage(_error!)),
                      const SizedBox(height: 8),
                      FilledButton(onPressed: _load, child: const Text('再試行')),
                    ],
                  ),
                ),
              )
            else if (_notes.isEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Center(child: Text(widget.emptyText)),
                ),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => RepaintBoundary(
                    key: ValueKey(_notes[index].id),
                    child: NoteCard(
                      note: _notes[index],
                      serverEmojis: serverEmojis,
                    ),
                  ),
                  childCount: _notes.length,
                ),
              ),
            SliverToBoxAdapter(
              child: _loadingMore
                  ? const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  : const SizedBox(height: 80),
            ),
          ],
        ),
      ),
    );
  }
}
