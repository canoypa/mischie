import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mischie/core/error/error_handler.dart';
import 'package:mischie/features/compose/domain/compose_notifier.dart';
import 'package:mischie/features/timeline/domain/note.dart';

const _maxLength = 3000;

class ComposeScreen extends ConsumerStatefulWidget {
  const ComposeScreen({super.key, this.replyTo, this.quoteOf});

  /// 返信先のノート。指定すると replyId 付きで投稿する。
  final Note? replyTo;

  /// 引用元のノート。指定すると renoteId 付きで投稿する。
  final Note? quoteOf;

  @override
  ConsumerState<ComposeScreen> createState() => _ComposeScreenState();
}

class _ComposeScreenState extends ConsumerState<ComposeScreen> {
  final _textController = TextEditingController();
  final _cwController = TextEditingController();
  bool _showCw = false;
  NoteVisibility _visibility = NoteVisibility.public;
  int _textLength = 0;

  @override
  void initState() {
    super.initState();
    _textController.addListener(
      () => setState(() => _textLength = _textController.text.length),
    );
    // 返信は元ノートの公開範囲を引き継ぐ（元より広く公開しない）
    final source = widget.replyTo;
    if (source != null) {
      _visibility = NoteVisibility.values.firstWhere(
        (v) => v.name == source.visibility,
        orElse: () => NoteVisibility.public,
      );
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    _cwController.dispose();
    super.dispose();
  }

  Future<void> _post() async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    await ref
        .read(composeNotifierProvider.notifier)
        .postNote(
          text,
          cw: _showCw ? _cwController.text.trim() : null,
          visibility: _visibility,
          replyId: widget.replyTo?.id,
          renoteId: widget.quoteOf?.id,
        );

    if (mounted) {
      final state = ref.read(composeNotifierProvider);
      if (state.hasError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(resolveErrorMessage(state.error!))),
        );
      } else {
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(composeNotifierProvider).isLoading;
    final remaining = _maxLength - _textLength;
    final isOverLimit = remaining < 0;

    final isReply = widget.replyTo != null;
    final isQuote = widget.quoteOf != null;
    final target = widget.replyTo ?? widget.quoteOf;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isReply
              ? '返信'
              : isQuote
              ? '引用'
              : 'ノートを書く',
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: isLoading || isOverLimit ? null : _post,
        icon: isLoading
            ? const SizedBox(
                height: 18,
                width: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.send),
        label: const Text('投稿'),
      ),
      body: Column(
        children: [
          if (target != null) _TargetPreview(note: target, isReply: isReply),
          if (_showCw)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: TextField(
                controller: _cwController,
                decoration: const InputDecoration(
                  hintText: '閲覧注意の説明',
                  border: UnderlineInputBorder(),
                ),
              ),
            ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _textController,
                autofocus: true,
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                decoration: InputDecoration(
                  hintText: isReply ? 'このノートに返信' : '今何してる？',
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Row(
            children: [
              // CW トグル
              IconButton(
                icon: Icon(
                  _showCw ? Icons.warning : Icons.warning_outlined,
                  color: _showCw ? Theme.of(context).colorScheme.primary : null,
                ),
                tooltip: 'CW (閲覧注意)',
                onPressed: () => setState(() => _showCw = !_showCw),
              ),
              // 公開範囲
              _VisibilitySelector(
                value: _visibility,
                onChanged: (v) => setState(() => _visibility = v),
              ),
              const Spacer(),
              // 文字数カウント
              Text(
                '$remaining',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: isOverLimit
                      ? Theme.of(context).colorScheme.error
                      : Theme.of(context).colorScheme.outline,
                  fontWeight: isOverLimit ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              const SizedBox(width: 80), // FAB の幅分のスペース
            ],
          ),
        ),
      ),
    );
  }
}

class _VisibilitySelector extends StatelessWidget {
  const _VisibilitySelector({required this.value, required this.onChanged});

  final NoteVisibility value;
  final ValueChanged<NoteVisibility> onChanged;

  IconData _icon(NoteVisibility v) => switch (v) {
    NoteVisibility.public => Icons.public,
    NoteVisibility.home => Icons.home,
    NoteVisibility.followers => Icons.lock,
    NoteVisibility.specified => Icons.mail,
  };

  String _label(NoteVisibility v) => switch (v) {
    NoteVisibility.public => 'パブリック',
    NoteVisibility.home => 'ホーム',
    NoteVisibility.followers => 'フォロワー',
    NoteVisibility.specified => 'ダイレクト',
  };

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<NoteVisibility>(
      initialValue: value,
      onSelected: onChanged,
      itemBuilder: (_) => NoteVisibility.values
          .map(
            (v) => PopupMenuItem(
              value: v,
              child: Row(
                children: [
                  Icon(_icon(v), size: 18),
                  const SizedBox(width: 8),
                  Text(_label(v)),
                ],
              ),
            ),
          )
          .toList(),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_icon(value), size: 20),
          const Icon(Icons.arrow_drop_down, size: 16),
        ],
      ),
    );
  }
}

/// 返信先・引用元を投稿画面の上部に薄く出す。
class _TargetPreview extends StatelessWidget {
  const _TargetPreview({required this.note, required this.isReply});

  final Note note;
  final bool isReply;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final handle = note.user.host != null
        ? '@${note.user.username}@${note.user.host}'
        : '@${note.user.username}';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      color: colorScheme.surfaceContainerHighest,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isReply ? Icons.reply : Icons.format_quote,
                size: 16,
                color: colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  '${isReply ? '返信先' : '引用元'}: ${note.user.name ?? note.user.username} $handle',
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
          if (note.text != null) ...[
            const SizedBox(height: 4),
            Text(
              note.text!,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: textTheme.bodyMedium,
            ),
          ],
        ],
      ),
    );
  }
}
