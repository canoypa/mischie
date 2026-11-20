import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mischie/core/emoji/emoji_providers.dart';
import 'package:mischie/core/error/error_handler.dart';
import 'package:mischie/features/compose/presentation/compose_screen.dart';
import 'package:mischie/features/timeline/domain/note.dart';
import 'package:mischie/features/timeline/domain/note_actions.dart';
import 'package:mischie/features/timeline/domain/note_store.dart';
import 'package:mischie/features/timeline/presentation/note_card.dart';

void openNoteDetail(BuildContext context, Note note) {
  Navigator.of(
    context,
  ).push(MaterialPageRoute(builder: (_) => NoteDetailScreen(note: note)));
}

class NoteDetailScreen extends ConsumerStatefulWidget {
  const NoteDetailScreen({super.key, required this.note});

  final Note note;

  @override
  ConsumerState<NoteDetailScreen> createState() => _NoteDetailScreenState();
}

class _NoteDetailScreenState extends ConsumerState<NoteDetailScreen> {
  List<Note> _ancestors = const [];
  List<Note> _children = const [];
  bool _loading = true;
  Object? _error;

  bool _hasMoreChildren = false;
  bool _loadingMoreChildren = false;

  static const _childrenPageSize = 30;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final repo = ref.read(noteRepositoryProvider);
    if (repo == null) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final results = await Future.wait([
        widget.note.replyId == null
            ? Future.value(<Note>[])
            : repo.conversation(widget.note.id),
        repo.children(widget.note.id, limit: _childrenPageSize),
      ]);
      if (!mounted) return;
      // conversation は新しい順で返るので、時系列に直す
      final ancestors = results[0].reversed.toList();
      final children = results[1];
      // 中心のノート（widget.note）は取り直していない一覧側の値なので、
      // その上書きは残す。
      ref.read(noteOverridesProvider.notifier).evictFetched([
        ...ancestors,
        ...children,
      ]);
      setState(() {
        _ancestors = ancestors;
        _children = children;
        _hasMoreChildren = children.length >= _childrenPageSize;
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

  Future<void> _loadMoreChildren() async {
    final repo = ref.read(noteRepositoryProvider);
    if (repo == null || _children.isEmpty) return;
    setState(() => _loadingMoreChildren = true);
    try {
      final more = await repo.children(
        widget.note.id,
        limit: _childrenPageSize,
        untilId: _children.last.id,
      );
      if (!mounted) return;
      ref.read(noteOverridesProvider.notifier).evictFetched(more);
      setState(() {
        _children = [..._children, ...more];
        _hasMoreChildren = more.length >= _childrenPageSize;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(resolveErrorMessage(e))));
    } finally {
      if (mounted) setState(() => _loadingMoreChildren = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final serverEmojis = ref.watch(emojiCacheProvider).value ?? const {};
    final note = resolveNote(ref, widget.note);

    return Scaffold(
      appBar: AppBar(title: const Text('ノート')),
      floatingActionButton: FloatingActionButton(
        tooltip: '返信',
        onPressed: () async {
          await Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => ComposeScreen(replyTo: note)),
          );
          await _load();
        },
        child: const Icon(Icons.reply),
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.only(bottom: 96),
          children: [
            for (final ancestor in _ancestors)
              NoteCard(
                note: ancestor,
                serverEmojis: serverEmojis,
                showReplyTarget: false,
              ),
            Container(
              decoration: BoxDecoration(
                border: Border(
                  left: BorderSide(
                    color: Theme.of(context).colorScheme.primary,
                    width: 3,
                  ),
                ),
              ),
              child: NoteCard(
                note: note,
                serverEmojis: serverEmojis,
                onTap: () {},
                showReplyTarget: false,
              ),
            ),
            if (_loading)
              const Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_error != null)
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Text(resolveErrorMessage(_error!)),
                    const SizedBox(height: 8),
                    FilledButton(onPressed: _load, child: const Text('再試行')),
                  ],
                ),
              )
            else ...[
              if (_children.isNotEmpty)
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 8, 16, 4),
                  child: Text('返信'),
                ),
              for (final child in _children)
                Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: NoteCard(
                    note: child,
                    serverEmojis: serverEmojis,
                    showReplyTarget: false,
                  ),
                ),
              if (_hasMoreChildren)
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Center(
                    child: _loadingMoreChildren
                        ? const CircularProgressIndicator()
                        : TextButton(
                            onPressed: _loadMoreChildren,
                            child: const Text('返信をさらに読み込む'),
                          ),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}
