import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mischie/core/error/error_handler.dart';
import 'package:mischie/core/widgets/confirm_dialog.dart';
import 'package:mischie/features/auth/domain/auth_notifier.dart';
import 'package:mischie/features/compose/presentation/compose_screen.dart';
import 'package:mischie/features/profile/domain/profile_notifier.dart';
import 'package:mischie/features/timeline/domain/note.dart';
import 'package:mischie/features/timeline/domain/note_actions.dart';
import 'package:mischie/features/timeline/presentation/renoters_screen.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class NoteActionsRow extends ConsumerWidget {
  const NoteActionsRow({
    super.key,
    required this.note,
    required this.onReact,
    this.renoteItem,
  });

  final Note note;
  final VoidCallback onReact;

  /// [note] を包むリノート本体。自分のものなら、リノート解除で消す対象になる。
  final Note? renoteItem;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final myId = ref.watch(profileNotifierProvider).value?.id;
    final isMine = myId != null && myId == (note.userId ?? note.user.id);
    final canRenote =
        note.visibility == 'public' ||
        note.visibility == 'home' ||
        (note.visibility == 'followers' && isMine);
    final myRenote = renoteItem != null && renoteItem!.user.id == myId
        ? renoteItem
        : null;

    return Row(
      spacing: 4,
      children: [
        _ActionButton(
          icon: Icons.reply,
          count: note.repliesCount,
          tooltip: '返信',
          onPressed: () => _openReply(context),
        ),
        _ActionButton(
          icon: Icons.repeat,
          count: note.renoteCount,
          tooltip: 'リノート',
          onLongPress: note.renoteCount > 0
              ? () => openRenoters(context, note.id)
              : null,
          color: canRenote ? null : colorScheme.outlineVariant,
          onPressed: canRenote
              ? () => _showRenoteMenu(context, ref, myRenote: myRenote)
              : null,
        ),
        _ActionButton(
          icon: note.myReaction != null
              ? Icons.emoji_emotions
              : Icons.add_reaction_outlined,
          tooltip: 'リアクション',
          color: note.myReaction != null ? colorScheme.primary : null,
          onPressed: onReact,
        ),
        const Spacer(),
        _ActionButton(
          icon: Icons.more_horiz,
          tooltip: 'その他',
          onPressed: () => _showMoreMenu(context, ref, isMine: isMine),
        ),
      ],
    );
  }

  void _openReply(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => ComposeScreen(replyTo: note)));
  }

  Future<void> _showRenoteMenu(
    BuildContext context,
    WidgetRef ref, {
    Note? myRenote,
  }) async {
    final channel = note.channel;
    final allowExternal = channel == null || channel.allowRenoteToExternal;
    final action = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (allowExternal) ...[
                ListTile(
                  leading: const Icon(Icons.repeat),
                  title: const Text('リノート'),
                  onTap: () => Navigator.of(context).pop('renote'),
                ),
                ListTile(
                  leading: const Icon(Icons.format_quote),
                  title: const Text('引用'),
                  onTap: () => Navigator.of(context).pop('quote'),
                ),
              ],
              if (allowExternal && channel != null) const Divider(height: 1),
              if (channel != null)
                ListTile(
                  leading: const Icon(Icons.repeat),
                  title: const Text('チャンネル内にリノート'),
                  onTap: () => Navigator.of(context).pop('channelRenote'),
                ),
              if (myRenote != null) ...[
                const Divider(height: 1),
                ListTile(
                  leading: Icon(
                    Icons.delete_outline,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  title: Text(
                    'リノート解除',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                  onTap: () => Navigator.of(context).pop('unrenote'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
    if (action == null || !context.mounted) return;

    switch (action) {
      case 'quote':
        await Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => ComposeScreen(quoteOf: note)));
      case 'renote':
        await _run(
          context,
          () => ref.read(noteActionsProvider).renote(note),
          done: 'リノートしました',
        );
      case 'channelRenote':
        await _run(
          context,
          () => ref.read(noteActionsProvider).renote(note, inChannel: true),
          done: 'チャンネル内にリノートしました',
        );
      case 'unrenote':
        if (myRenote == null) return;
        await _run(
          context,
          () => ref.read(noteActionsProvider).unrenote(myRenote),
          done: 'リノートを解除しました',
        );
    }
  }

  Future<void> _showMoreMenu(
    BuildContext context,
    WidgetRef ref, {
    required bool isMine,
  }) async {
    final actions = ref.read(noteActionsProvider);
    final navigator = Navigator.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    // 状態は開いたときにだけ引く。表示を待たせないよう、取れた項目から出す。
    final stateFuture = actions.noteState(note);
    final pinnedFuture = isMine ? actions.isPinned(note) : null;
    // 削除して編集は、チャンネル・ローカル限定・ダイレクトの指定を
    // 投稿画面が持てず、書き直すと公開範囲が広がってしまうので出さない
    final canDeleteAndEdit =
        note.channelId == null &&
        !note.localOnly &&
        note.visibility != 'specified';

    final action = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (note.renoteCount > 0)
                ListTile(
                  leading: const Icon(Icons.repeat),
                  title: const Text('リノートした人を見る'),
                  onTap: () => Navigator.of(context).pop('renoters'),
                ),
              ListTile(
                leading: const Icon(Icons.link),
                title: const Text('リンクをコピー'),
                onTap: () => Navigator.of(context).pop('copy'),
              ),
              ListTile(
                leading: const Icon(Icons.content_copy),
                title: const Text('本文をコピー'),
                onTap: () => Navigator.of(context).pop('copyText'),
              ),
              ListTile(
                leading: const Icon(Icons.open_in_browser),
                title: const Text('ブラウザで開く'),
                onTap: () => Navigator.of(context).pop('browser'),
              ),
              ListTile(
                leading: const Icon(Icons.share),
                title: const Text('共有'),
                onTap: () => Navigator.of(context).pop('share'),
              ),
              FutureBuilder(
                future: stateFuture,
                builder: (context, snapshot) {
                  final state = snapshot.data;
                  if (state == null) return const SizedBox.shrink();
                  return Column(
                    children: [
                      const Divider(height: 1),
                      ListTile(
                        leading: Icon(
                          state.isFavorited ? Icons.star : Icons.star_outline,
                        ),
                        title: Text(
                          state.isFavorited ? 'お気に入りを解除' : 'お気に入りに追加',
                        ),
                        onTap: () => Navigator.of(
                          context,
                        ).pop(state.isFavorited ? 'unfavorite' : 'favorite'),
                      ),
                      ListTile(
                        leading: const Icon(Icons.speaker_notes_off_outlined),
                        title: Text(
                          state.isMutedThread ? 'スレッドのミュートを解除' : 'スレッドをミュート',
                        ),
                        onTap: () => Navigator.of(context).pop(
                          state.isMutedThread ? 'unmuteThread' : 'muteThread',
                        ),
                      ),
                    ],
                  );
                },
              ),
              if (pinnedFuture != null)
                FutureBuilder(
                  future: pinnedFuture,
                  builder: (context, snapshot) {
                    final pinned = snapshot.data;
                    if (pinned == null) return const SizedBox.shrink();
                    return ListTile(
                      leading: Icon(
                        pinned ? Icons.push_pin : Icons.push_pin_outlined,
                      ),
                      title: Text(pinned ? 'ピン留めを解除' : 'プロフィールにピン留め'),
                      onTap: () =>
                          Navigator.of(context).pop(pinned ? 'unpin' : 'pin'),
                    );
                  },
                ),
              if (!isMine) ...[
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.volume_off_outlined),
                  title: Text('@${note.user.username} をミュート'),
                  onTap: () => Navigator.of(context).pop('mute'),
                ),
                ListTile(
                  leading: const Icon(Icons.block),
                  title: Text('@${note.user.username} をブロック'),
                  onTap: () => Navigator.of(context).pop('block'),
                ),
                ListTile(
                  leading: const Icon(Icons.report_outlined),
                  title: const Text('通報'),
                  onTap: () => Navigator.of(context).pop('report'),
                ),
              ],
              if (isMine) ...[
                const Divider(height: 1),
                if (canDeleteAndEdit)
                  ListTile(
                    leading: const Icon(Icons.edit_outlined),
                    title: const Text('削除して編集'),
                    onTap: () => Navigator.of(context).pop('deleteAndEdit'),
                  ),
                ListTile(
                  leading: Icon(Icons.delete_outline, color: colorScheme.error),
                  title: Text('削除', style: TextStyle(color: colorScheme.error)),
                  onTap: () => Navigator.of(context).pop('delete'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
    if (action == null || !context.mounted) return;

    switch (action) {
      case 'renoters':
        openRenoters(context, note.id);
      case 'copy':
        final link = _noteUrl(ref, note);
        if (link == null) return;
        await Clipboard.setData(ClipboardData(text: link));
        if (context.mounted) _toast(context, 'リンクをコピーしました');
      case 'copyText':
        await Clipboard.setData(ClipboardData(text: note.text ?? ''));
        if (context.mounted) _toast(context, 'コピーしました');
      case 'browser':
        final url = _noteUrl(ref, note);
        if (url != null) {
          await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
        }
      case 'share':
        final link = _noteUrl(ref, note);
        if (link == null) return;
        await _run(
          context,
          () => SharePlus.instance.share(
            ShareParams(
              uri: Uri.parse(link),
              subject: '${note.user.name ?? note.user.username} のノート',
            ),
          ),
        );
      case 'favorite' || 'unfavorite':
        final favorite = action == 'favorite';
        await _run(
          context,
          () => actions.setFavorite(note, favorite: favorite),
          done: favorite ? 'お気に入りに追加しました' : 'お気に入りを解除しました',
        );
      case 'muteThread' || 'unmuteThread':
        final muted = action == 'muteThread';
        await _run(
          context,
          () => actions.setThreadMuted(note, muted: muted),
          done: muted ? 'スレッドをミュートしました' : 'スレッドのミュートを解除しました',
        );
      case 'pin' || 'unpin':
        final pinned = action == 'pin';
        await _run(
          context,
          () => actions.setPinned(note, pinned: pinned),
          done: pinned ? 'プロフィールにピン留めしました' : 'ピン留めを解除しました',
        );
      case 'mute':
        await _run(
          context,
          () => ref
              .read(moderationActionsProvider)
              .setMuted(note.user.id, muted: true),
          done: 'ミュートしました',
        );
      case 'block':
        final ok = await showConfirmDialog(
          context,
          title: 'ブロック',
          message: '@${note.user.username} をブロックしますか？相手からあなたのノートは見えなくなります。',
          action: 'ブロック',
        );
        if (!ok || !context.mounted) return;
        await _run(
          context,
          () => ref
              .read(moderationActionsProvider)
              .setBlocked(note.user.id, blocked: true),
          done: 'ブロックしました',
        );
      case 'report':
        final comment = await showDialog<String>(
          context: context,
          builder: (_) =>
              _ReportDialog(initialComment: _reportComment(ref, note)),
        );
        if (comment == null || !context.mounted) return;
        await _run(
          context,
          () => actions.reportAbuse(note, comment),
          done: '通報しました',
        );
      case 'deleteAndEdit':
        final ok = await showConfirmDialog(
          context,
          title: '削除して編集',
          message: 'このノートを削除して、内容を書き直します。リアクションやリノートも失われます。',
          action: '削除して編集',
        );
        if (!ok || !context.mounted) return;
        // 削除するとカードごと消えるので、画面遷移は先に確保した navigator で行う
        final deleted = await _run(context, () => actions.delete(note));
        if (deleted) {
          await navigator.push(
            MaterialPageRoute(builder: (_) => ComposeScreen(editFrom: note)),
          );
        }
      case 'delete':
        final ok = await showConfirmDialog(
          context,
          title: 'ノートを削除',
          message: 'この操作は取り消せません。削除しますか？',
          action: '削除',
        );
        if (!ok || !context.mounted) return;
        await _run(context, () => actions.delete(note), done: '削除しました');
    }
  }

  /// ローカルのノートは url が無いので、ログイン中のホストから組み立てる。
  String? _noteUrl(WidgetRef ref, Note note) {
    final remote = note.url ?? note.uri;
    if (remote != null) return remote;
    final host = ref.read(currentHostProvider);
    return host == null ? null : 'https://$host/notes/${note.id}';
  }

  Future<bool> _run(
    BuildContext context,
    Future<void> Function() action, {
    String? done,
  }) async {
    // 削除のようにカードごと消える操作では、終わったあとに context が使えない
    final messenger = ScaffoldMessenger.of(context);
    try {
      await action();
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(resolveErrorMessage(e))));
      return false;
    }
    if (done != null) {
      messenger.showSnackBar(SnackBar(content: Text(done)));
    }
    return true;
  }

  String _reportComment(WidgetRef ref, Note note) {
    final remote = note.url ?? note.uri;
    final host = ref.read(currentHostProvider);
    return [
      if (remote != null) 'Note: $remote',
      if (host != null) 'Local Note: https://$host/notes/${note.id}',
      '-----',
      '',
    ].join('\n');
  }

  void _toast(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

class _ReportDialog extends StatefulWidget {
  const _ReportDialog({required this.initialComment});

  final String initialComment;

  @override
  State<_ReportDialog> createState() => _ReportDialogState();
}

class _ReportDialogState extends State<_ReportDialog> {
  late final _controller = TextEditingController(text: widget.initialComment);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('通報'),
      content: TextField(
        controller: _controller,
        autofocus: true,
        minLines: 4,
        maxLines: 8,
        maxLength: 2048,
        decoration: const InputDecoration(
          hintText: '問題の内容を書いてください',
          border: OutlineInputBorder(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('キャンセル'),
        ),
        ListenableBuilder(
          listenable: _controller,
          builder: (context, _) => FilledButton(
            onPressed: _controller.text.trim().isEmpty
                ? null
                : () => Navigator.of(context).pop(_controller.text.trim()),
            child: const Text('通報'),
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.count,
    this.color,
    this.onLongPress,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;
  final int? count;
  final Color? color;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final effectiveColor =
        color ?? Theme.of(context).colorScheme.onSurfaceVariant;

    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onPressed,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(24),
        // 隣り合うボタンの押し間違いを防ぐため、48 未満にしない。
        child: ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 20, color: effectiveColor),
                if (count != null && count! > 0) ...[
                  const SizedBox(width: 6),
                  Text(
                    '$count',
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: effectiveColor),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
