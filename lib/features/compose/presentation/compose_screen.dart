import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mischie/core/error/error_handler.dart';
import 'package:mischie/features/compose/domain/compose_notifier.dart';
import 'package:mischie/features/timeline/domain/note.dart';

const _maxLength = 3000;

/// Misskey が 1 ノートに添付できる上限。
const _maxAttachments = 16;

class ComposeScreen extends ConsumerStatefulWidget {
  const ComposeScreen({
    super.key,
    this.replyTo,
    this.quoteOf,
    this.initialText,
    this.initialImagePaths = const [],
  });

  /// 他アプリからの共有で渡された本文。
  final String? initialText;

  /// 他アプリからの共有で渡された画像のローカルパス。
  final List<String> initialImagePaths;

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
  final List<_Attachment> _attachments = [];

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

    if (widget.initialText != null) {
      _textController.text = widget.initialText!;
    }
    if (widget.initialImagePaths.isNotEmpty) {
      _addAttachments(widget.initialImagePaths);
    }
  }

  /// 選んだ時点でアップロードを始める。投稿ボタンを押してから
  /// 全部上げ始めると、その分だけユーザーを待たせることになるため。
  void _addAttachments(List<String> paths) {
    final room = _maxAttachments - _attachments.length;
    if (room <= 0) return;
    final added = paths.take(room).map(_Attachment.new).toList();
    setState(() => _attachments.addAll(added));
    for (final attachment in added) {
      _upload(attachment);
    }
  }

  Future<void> _upload(_Attachment attachment) async {
    final repo = ref.read(composeRepositoryProvider);
    if (repo == null) return;
    try {
      final file = await repo.uploadFile(attachment.path);
      if (!mounted) return;
      setState(() {
        attachment.fileId = file.id;
        attachment.uploading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        attachment.uploading = false;
        attachment.error = e;
      });
    }
  }

  Future<void> _pickImages() async {
    final picked = await ImagePicker().pickMultiImage(limit: _maxAttachments);
    if (picked.isEmpty) return;
    _addAttachments(picked.map((x) => x.path).toList());
  }

  @override
  void dispose() {
    _textController.dispose();
    _cwController.dispose();
    super.dispose();
  }

  Future<void> _post() async {
    final text = _textController.text.trim();
    if (text.isEmpty && _attachments.isEmpty) return;

    await ref
        .read(composeNotifierProvider.notifier)
        .postNote(
          text,
          cw: _showCw ? _cwController.text.trim() : null,
          visibility: _visibility,
          replyId: widget.replyTo?.id,
          renoteId: widget.quoteOf?.id,
          fileIds: _attachments
              .map((a) => a.fileId)
              .whereType<String>()
              .toList(),
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
    final isUploading = _attachments.any((a) => a.uploading);
    final isEmpty = _textLength == 0 && _attachments.isEmpty;

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
        onPressed: isLoading || isOverLimit || isUploading || isEmpty
            ? null
            : _post,
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
          if (_attachments.isNotEmpty)
            _AttachmentStrip(
              attachments: _attachments,
              onRemove: (a) => setState(() => _attachments.remove(a)),
              onRetry: (a) {
                setState(() {
                  a.uploading = true;
                  a.error = null;
                });
                _upload(a);
              },
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
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                children: [
                  // 画像添付
                  IconButton(
                    icon: const Icon(Icons.image_outlined),
                    tooltip: '画像を追加',
                    onPressed: _attachments.length >= _maxAttachments
                        ? null
                        : _pickImages,
                  ),
                  // CW トグル
                  IconButton(
                    icon: Icon(
                      _showCw ? Icons.warning : Icons.warning_outlined,
                      color: _showCw
                          ? Theme.of(context).colorScheme.primary
                          : null,
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
                      fontWeight: isOverLimit
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                  const SizedBox(width: 80), // FAB の幅分のスペース
                ],
              ),
            ),
          ),
        ],
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

/// 添付画像 1 枚ぶんの状態。選択した直後にアップロードを開始し、
/// 完了すると fileId が入る。
class _Attachment {
  _Attachment(this.path);

  final String path;
  String? fileId;
  bool uploading = true;
  Object? error;
}

class _AttachmentStrip extends StatelessWidget {
  const _AttachmentStrip({
    required this.attachments,
    required this.onRemove,
    required this.onRetry,
  });

  final List<_Attachment> attachments;
  final ValueChanged<_Attachment> onRemove;
  final ValueChanged<_Attachment> onRetry;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 104,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: attachments.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final attachment = attachments[index];
          return Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(
                  File(attachment.path),
                  width: 88,
                  height: 88,
                  fit: BoxFit.cover,
                  cacheWidth: 264, // 表示は 88dp。原寸をデコードしない
                ),
              ),
              if (attachment.uploading)
                const Positioned.fill(
                  child: ColoredBox(
                    color: Colors.black38,
                    child: Center(
                      child: SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              if (attachment.error != null)
                Positioned.fill(
                  child: GestureDetector(
                    onTap: () => onRetry(attachment),
                    child: ColoredBox(
                      color: Theme.of(
                        context,
                      ).colorScheme.errorContainer.withValues(alpha: 0.8),
                      child: const Center(child: Icon(Icons.refresh)),
                    ),
                  ),
                ),
              Positioned(
                top: -6,
                right: -6,
                child: IconButton(
                  icon: const Icon(Icons.cancel, size: 20),
                  color: Colors.white,
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.black54,
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(24, 24),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  onPressed: () => onRemove(attachment),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
