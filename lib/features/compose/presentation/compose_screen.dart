import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mischie/features/compose/data/draft_store.dart';
import 'package:mischie/features/compose/domain/draft_notifier.dart';
import 'package:mischie/core/emoji/emoji_providers.dart';
import 'package:mischie/features/compose/domain/compose_completion.dart';
import 'package:mischie/features/compose/presentation/attachments.dart';
import 'package:mischie/features/compose/presentation/completion_bar.dart';
import 'package:mischie/features/compose/presentation/poll_editor.dart';
import 'package:mischie/core/error/error_handler.dart';
import 'package:mischie/features/compose/domain/compose_notifier.dart';
import 'package:mischie/features/timeline/domain/note.dart';
import 'package:mischie/features/timeline/domain/note_actions.dart';

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
    this.draft,
  });

  /// 下書きから再開する場合の元データ。
  final Draft? draft;

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
  final List<Attachment> _attachments = [];

  /// 投票を付けているあいだだけ持つ。null なら投票なし。
  PollDraft? _poll;

  /// カーソル位置で補完しようとしているもの。
  CompletionQuery? _completion;

  /// メンション検索へ渡す語。打鍵が落ち着いてから更新する。
  String _mentionQuery = '';
  Timer? _mentionDebounce;

  /// 下書きの同一性。保存し直しても増殖しないように使い回す。
  late final String _draftId =
      widget.draft?.id ?? DateTime.now().microsecondsSinceEpoch.toString();

  /// 返信先・引用元の id。フレッシュな返信・引用は widget から、
  /// 下書きから戻した場合は下書きに残っていたものから引く。
  /// 投稿・再保存は常にここを見る（widget.replyTo/quoteOf は直接見ない）。
  String? _replyId;
  String? _renoteId;

  /// ヘッダー表示用の本体。フレッシュな返信・引用では渡されるが、下書きから
  /// 戻した場合は id しか無いので取得する。取れなくても id があれば投稿できる。
  Note? _targetNote;
  bool _targetLoading = false;

  /// アップロード中の添付を、下書き保存時に待ち合わせるための Future。
  final Map<Attachment, Future<void>> _uploads = {};

  @override
  void initState() {
    super.initState();
    _textController.addListener(_onTextChanged);

    final draft = widget.draft;

    _replyId = widget.replyTo?.id ?? draft?.replyId;
    _renoteId = widget.quoteOf?.id ?? draft?.renoteId;
    _targetNote = widget.replyTo ?? widget.quoteOf;

    // 返信は元ノートの公開範囲を引き継ぐ（元より広く公開しない）
    final source = widget.replyTo;
    if (source != null) {
      _visibility = NoteVisibility.fromName(source.visibility);
    }

    if (widget.initialText != null) {
      _textController.text = widget.initialText!;
    }
    if (widget.initialImagePaths.isNotEmpty) {
      _addAttachments(widget.initialImagePaths);
    }

    if (draft != null) {
      _textController.text = draft.text;
      if (draft.cw != null && draft.cw!.isNotEmpty) {
        _showCw = true;
        _cwController.text = draft.cw!;
      }
      _visibility = NoteVisibility.fromName(draft.visibility);
      _attachments.addAll(draft.fileIds.map(Attachment.uploaded));

      final pollChoices = draft.pollChoices
          ?.take(PollDraft.maxChoices)
          .toList();
      if (pollChoices != null) {
        final poll = PollDraft();
        while (poll.controllers.length < pollChoices.length) {
          poll.addChoice();
        }
        for (var i = 0; i < pollChoices.length; i++) {
          poll.controllers[i].text = pollChoices[i];
        }
        poll.multiple = draft.pollMultiple;
        poll.duration = draft.pollExpiresInMs != null
            ? Duration(milliseconds: draft.pollExpiresInMs!)
            : null;
        _poll = poll;
      }
    }

    if (_targetNote == null && (_replyId != null || _renoteId != null)) {
      _targetLoading = true;
      _fetchTarget();
    }
  }

  /// 下書きから戻した返信・引用は id しか持たないので notes/show で取りに行く。
  Future<void> _fetchTarget() async {
    final id = _replyId ?? _renoteId;
    if (id == null) return;
    try {
      final repo = ref.read(noteRepositoryProvider);
      if (repo == null) throw Exception('未ログイン');
      final note = await repo.show(id);
      if (!mounted) return;
      setState(() {
        _targetNote = note;
        _targetLoading = false;
        // 返信は元ノートより広い公開範囲にはしない。下書きに残っていた
        // 公開範囲がすでにそれより狭ければそのまま保つ（勝手に広げない）。
        if (_replyId != null) {
          final sourceVisibility = NoteVisibility.fromName(note.visibility);
          if (sourceVisibility.index > _visibility.index) {
            _visibility = sourceVisibility;
          }
        }
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _targetLoading = false);
    }
  }

  void _onTextChanged() {
    final selection = _textController.selection;
    setState(() {
      _textLength = _textController.text.length;
      // 選択範囲があるときは補完しない（どこを置き換えるか決まらない）
      _completion = selection.isCollapsed
          ? completionAt(_textController.text, selection.baseOffset)
          : null;
    });
    _scheduleMentionSearch();
  }

  /// メンションだけはサーバーに聞くしかないので、打鍵が止まってから投げる。
  /// 1 文字ごとに検索すると、サーバーに無駄な負荷をかける。
  void _scheduleMentionSearch() {
    final completion = _completion;
    if (completion == null || completion.kind != CompletionKind.mention) {
      _mentionDebounce?.cancel();
      if (_mentionQuery.isNotEmpty) setState(() => _mentionQuery = '');
      return;
    }
    if (completion.query == _mentionQuery) return;

    _mentionDebounce?.cancel();
    _mentionDebounce = Timer(const Duration(milliseconds: 300), () {
      if (mounted) setState(() => _mentionQuery = completion.query);
    });
  }

  /// 候補を選んだら、記号ごと置き換えてカーソルを末尾へ送る。
  void _applyCompletion(String replacement) {
    final query = _completion;
    if (query == null) return;
    final text = _textController.text;
    final next = text.replaceRange(query.start, query.end, replacement);
    _textController.value = TextEditingValue(
      text: next,
      selection: TextSelection.collapsed(
        offset: query.start + replacement.length,
      ),
    );
  }

  bool get _hasContent =>
      _textController.text.trim().isNotEmpty ||
      _attachments.isNotEmpty ||
      _poll != null;

  Future<void> _saveDraft() async {
    // アップロード中のまま保存すると fileId が無く、その添付が
    // 静かに消えるので、書き込む前に完了を待つ。
    final pending = _attachments.where((a) => a.uploading).toList();
    if (pending.isNotEmpty) {
      await Future.wait(pending.map((a) => _uploads[a] ?? Future.value()));
    }

    await ref
        .read(draftsProvider.notifier)
        .save(
          Draft(
            id: _draftId,
            text: _textController.text,
            savedAt: DateTime.now().toIso8601String(),
            cw: _showCw ? _cwController.text : null,
            visibility: _visibility.name,
            fileIds: _attachments
                .map((a) => a.fileId)
                .whereType<String>()
                .toList(),
            replyId: _replyId,
            renoteId: _renoteId,
            pollChoices: _poll?.controllers.map((c) => c.text).toList(),
            pollMultiple: _poll?.multiple ?? false,
            pollExpiresInMs: _poll?.duration?.inMilliseconds,
          ),
        );

    final failed = _attachments.where((a) => a.error != null).toList();
    if (failed.isNotEmpty && mounted) {
      final names = failed
          .map((a) => a.path?.split('/').last ?? '添付')
          .join(', ');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('保存できなかった添付があります: $names')));
    }
  }

  /// 書きかけを黙って捨てない。破棄・下書き保存・書き続けるを選ばせる。
  Future<bool> _confirmDiscard() async {
    if (!_hasContent) return true;

    final action = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('書きかけのノート'),
        content: const Text('下書きに保存しますか？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, 'cancel'),
            child: const Text('書き続ける'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, 'discard'),
            child: const Text('破棄'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, 'save'),
            child: const Text('保存'),
          ),
        ],
      ),
    );

    if (action == 'save') {
      await _saveDraft();
      return true;
    }
    return action == 'discard';
  }

  Future<void> _openDrafts() async {
    final drafts = ref.read(draftsProvider).value ?? const [];
    if (drafts.isEmpty) return;

    final selected = await showModalBottomSheet<Draft>(
      context: context,
      builder: (context) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            for (final draft in drafts)
              ListTile(
                title: Text(
                  draft.text.isEmpty ? '(本文なし)' : draft.text,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(draft.savedAt.substring(0, 16)),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () =>
                      ref.read(draftsProvider.notifier).remove(draft.id),
                ),
                onTap: () => Navigator.pop(context, draft),
              ),
          ],
        ),
      ),
    );
    if (selected == null || !mounted) return;

    // 書きかけを黙って捨てない（PopScope と同じ確認を通す）。
    if (!await _confirmDiscard() || !mounted) return;

    // _confirmDiscard で保存すると selected 自身が上書きされることがあるので、
    // 遷移直前の最新の内容を読み直す。
    final latest = ref.read(draftsProvider).value ?? const [];
    final toOpen = latest.firstWhere(
      (d) => d.id == selected.id,
      orElse: () => selected,
    );

    await Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => ComposeScreen(draft: toOpen)),
    );
  }

  /// 選んだ時点でアップロードを始める。投稿ボタンを押してから
  /// 全部上げ始めると、その分だけユーザーを待たせることになるため。
  void _addAttachments(List<String> paths) {
    final room = _maxAttachments - _attachments.length;
    if (room <= 0) return;
    final added = paths.take(room).map(Attachment.new).toList();
    setState(() => _attachments.addAll(added));
    for (final attachment in added) {
      _uploads[attachment] = _upload(attachment);
    }
  }

  Future<void> _upload(Attachment attachment) async {
    final repo = ref.read(composeRepositoryProvider);
    final path = attachment.path;
    if (repo == null || path == null) return;
    try {
      final file = await repo.uploadFile(path);
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

  /// 添付の説明（alt）とセンシティブ指定。読み上げ環境のために alt は
  /// 付けられるようにしておく。
  Future<void> _editAttachment(Attachment attachment) async {
    final controller = TextEditingController(text: attachment.alt);
    var sensitive = attachment.isSensitive;

    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('画像の設定'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: controller,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: '説明 (alt)',
                  hintText: '画像の内容を書く',
                  border: OutlineInputBorder(),
                ),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('センシティブ'),
                value: sensitive,
                onChanged: (v) => setDialogState(() => sensitive = v),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('キャンセル'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('保存'),
            ),
          ],
        ),
      ),
    );
    controller.dispose();
    if (saved != true) return;

    final fileId = attachment.fileId;
    if (fileId == null) return;
    try {
      await ref
          .read(composeRepositoryProvider)!
          .updateFile(
            fileId,
            comment: controller.text.trim(),
            isSensitive: sensitive,
          );
      if (!mounted) return;
      setState(() {
        attachment
          ..alt = controller.text.trim()
          ..isSensitive = sensitive;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(resolveErrorMessage(e))));
    }
  }

  Future<void> _pickImages() async {
    final picked = await ImagePicker().pickMultiImage(limit: _maxAttachments);
    if (picked.isEmpty) return;
    _addAttachments(picked.map((x) => x.path).toList());
  }

  @override
  void dispose() {
    _mentionDebounce?.cancel();
    _poll?.dispose();
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
          replyId: _replyId,
          renoteId: _renoteId,
          fileIds: _attachments
              .map((a) => a.fileId)
              .whereType<String>()
              .toList(),
          pollChoices: _poll?.choices ?? const [],
          pollMultiple: _poll?.multiple ?? false,
          pollDuration: _poll?.duration,
        );

    if (mounted) {
      final state = ref.read(composeNotifierProvider);
      if (state.hasError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(resolveErrorMessage(state.error!))),
        );
      } else {
        await ref.read(draftsProvider.notifier).remove(_draftId);
        if (mounted) Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(composeNotifierProvider).isLoading;
    final remaining = _maxLength - _textLength;
    final isOverLimit = remaining < 0;
    final isUploading = _attachments.any((a) => a.uploading);
    final hasUploadError = _attachments.any((a) => a.error != null);
    final pollIncomplete = _poll != null && !_poll!.isValid;
    final isEmpty = _textLength == 0 && _attachments.isEmpty;

    final isReply = _replyId != null;
    final isQuote = _renoteId != null;
    final target = _targetNote;

    final draftCount = ref.watch(draftsProvider).value?.length ?? 0;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        if (await _confirmDiscard() && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            isReply
                ? '返信'
                : isQuote
                ? '引用'
                : 'ノートを書く',
          ),
          actions: [
            if (draftCount > 0)
              IconButton(
                icon: Badge(
                  label: Text('$draftCount'),
                  child: const Icon(Icons.drafts_outlined),
                ),
                tooltip: '下書き',
                onPressed: _openDrafts,
              ),
            // 送信はここに置く。下部に浮かせるとキーボード対策で本体末尾へ
            // 移したツールバーと重なり、文字数カウントが隠れる。
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: FilledButton(
                onPressed:
                    isLoading ||
                        isOverLimit ||
                        isUploading ||
                        hasUploadError ||
                        isEmpty ||
                        pollIncomplete
                    ? null
                    : _post,
                child: isLoading
                    ? const SizedBox(
                        height: 16,
                        width: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(isReply ? '返信' : '投稿'),
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            if (target != null)
              _TargetPreview(note: target, isReply: isReply)
            else if (isReply || isQuote)
              _TargetPreviewCompact(isReply: isReply, loading: _targetLoading),
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
              AttachmentStrip(
                attachments: _attachments,
                onRemove: (a) => setState(() => _attachments.remove(a)),
                onRetry: (a) {
                  setState(() {
                    a.uploading = true;
                    a.error = null;
                  });
                  _uploads[a] = _upload(a);
                },
                onEdit: _editAttachment,
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
            if (_completion case final completion?)
              CompletionBar(
                query: completion,
                emojis: ref.watch(emojiCacheProvider).value ?? const {},
                mentionQuery: _mentionQuery,
                onSelected: _applyCompletion,
              ),
            // 本文を書いてから選択肢を足す並びにする
            if (_poll case final poll?)
              PollEditor(
                draft: poll,
                onChanged: () => setState(() {}),
                onRemove: () => setState(() {
                  _poll?.dispose();
                  _poll = null;
                }),
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
                    // 投票
                    IconButton(
                      icon: Icon(
                        Icons.poll_outlined,
                        color: _poll != null
                            ? Theme.of(context).colorScheme.primary
                            : null,
                      ),
                      tooltip: '投票',
                      onPressed: () => setState(() {
                        if (_poll == null) {
                          _poll = PollDraft();
                        } else {
                          _poll!.dispose();
                          _poll = null;
                        }
                      }),
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
                  ],
                ),
              ),
            ),
          ],
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
    final handle = note.user.acct;

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

/// 返信先・引用元の本体を取得できていない間の簡易表示。
///
/// 下書きから戻した直後や notes/show が失敗した場合に出す。本体が無くても
/// id さえあれば投稿はできるので、ここでは「返信/引用であること」だけ示す。
class _TargetPreviewCompact extends StatelessWidget {
  const _TargetPreviewCompact({required this.isReply, required this.loading});

  final bool isReply;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      color: colorScheme.surfaceContainerHighest,
      child: Row(
        children: [
          Icon(
            isReply ? Icons.reply : Icons.format_quote,
            size: 16,
            color: colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 6),
          Text(
            isReply ? '返信先' : '引用元',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          if (loading) ...[
            const SizedBox(width: 8),
            SizedBox(
              height: 12,
              width: 12,
              child: CircularProgressIndicator(
                strokeWidth: 1.5,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
