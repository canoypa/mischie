import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mischie/core/emoji/emoji_providers.dart';
import 'package:mischie/core/error/error_handler.dart';
import 'package:mischie/features/compose/presentation/compose_screen.dart';
import 'package:mischie/features/timeline/domain/note.dart';
import 'package:mischie/features/timeline/domain/note_actions.dart';
import 'package:mischie/features/timeline/presentation/note_card.dart';

/// ノート詳細（会話）を開く。引用や埋め込みからも呼ぶ。
void openNoteDetail(BuildContext context, Note note) {
  Navigator.of(
    context,
  ).push(MaterialPageRoute(builder: (_) => NoteDetailScreen(note: note)));
}

/// 1 つのノートを中心に、返信元（祖先）と返信（子）を縦に並べる会話ビュー。
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
      // 祖先と子は独立なので同時に取る
      final results = await Future.wait([
        widget.note.replyId == null
            ? Future.value(<Note>[])
            : repo.conversation(widget.note.id),
        repo.children(widget.note.id),
      ]);
      if (!mounted) return;
      setState(() {
        // conversation は新しい順で返るので、時系列に直す
        _ancestors = results[0].reversed.toList();
        _children = results[1];
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

  @override
  Widget build(BuildContext context) {
    final serverEmojis = ref.watch(emojiCacheProvider).value ?? const {};
    final note = resolveNote(ref, widget.note);

    return Scaffold(
      appBar: AppBar(title: const Text('ノート')),
      floatingActionButton: FloatingActionButton(
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
              NoteCard(note: ancestor, serverEmojis: serverEmojis),
            // 中心のノートは少し強調する
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
                  child: NoteCard(note: child, serverEmojis: serverEmojis),
                ),
            ],
          ],
        ),
      ),
    );
  }
}
