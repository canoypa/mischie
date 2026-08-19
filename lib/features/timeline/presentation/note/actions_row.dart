import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mischie/core/error/error_handler.dart';
import 'package:mischie/features/auth/domain/auth_notifier.dart';
import 'package:mischie/features/compose/presentation/compose_screen.dart';
import 'package:mischie/features/profile/domain/profile_notifier.dart';
import 'package:mischie/features/timeline/domain/note.dart';
import 'package:mischie/features/timeline/domain/note_actions.dart';
import 'package:mischie/features/timeline/presentation/renoters_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class NoteActionsRow extends ConsumerWidget {
  const NoteActionsRow({super.key, required this.note, required this.onReact});

  final Note note;
  final VoidCallback onReact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final myId = ref.watch(profileNotifierProvider).value?.id;
    final isMine = myId != null && myId == (note.userId ?? note.user.id);
    // ダイレクト/フォロワー限定はリノートできない
    final canRenote =
        note.visibility != 'specified' && note.visibility != 'followers';

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
          // 件数を押したら誰が広めたのかを辿れるようにする
          onLongPress: note.renoteCount > 0
              ? () => openRenoters(context, note.id)
              : null,
          color: canRenote ? null : colorScheme.outlineVariant,
          onPressed: canRenote ? () => _showRenoteMenu(context, ref) : null,
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

  Future<void> _showRenoteMenu(BuildContext context, WidgetRef ref) async {
    final action = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
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
            ListTile(
              leading: const Icon(Icons.repeat_on_outlined),
              title: const Text('リノート解除'),
              onTap: () => Navigator.of(context).pop('unrenote'),
            ),
          ],
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
        await _run(context, () => ref.read(noteActionsProvider).renote(note));
        if (context.mounted) _toast(context, 'リノートしました');
      case 'unrenote':
        await _run(context, () => ref.read(noteActionsProvider).unrenote(note));
        if (context.mounted) _toast(context, 'リノートを解除しました');
    }
  }

  Future<void> _showMoreMenu(
    BuildContext context,
    WidgetRef ref, {
    required bool isMine,
  }) async {
    final action = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => SafeArea(
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
            ],
            if (isMine)
              ListTile(
                leading: Icon(
                  Icons.delete_outline,
                  color: Theme.of(context).colorScheme.error,
                ),
                title: Text(
                  '削除',
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
                onTap: () => Navigator.of(context).pop('delete'),
              ),
          ],
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
      case 'mute':
        await _run(
          context,
          () => ref
              .read(moderationActionsProvider)
              .setMuted(note.user.id, muted: true),
        );
        if (context.mounted) _toast(context, 'ミュートしました');
      case 'block':
        final ok = await _confirm(
          context,
          title: 'ブロック',
          message: '@${note.user.username} をブロックしますか？相手からあなたのノートは見えなくなります。',
          action: 'ブロック',
        );
        if (ok != true || !context.mounted) return;
        await _run(
          context,
          () => ref
              .read(moderationActionsProvider)
              .setBlocked(note.user.id, blocked: true),
        );
        if (context.mounted) _toast(context, 'ブロックしました');
      case 'delete':
        final ok = await _confirm(
          context,
          title: 'ノートを削除',
          message: 'この操作は取り消せません。削除しますか？',
          action: '削除',
        );
        if (ok != true || !context.mounted) return;
        await _run(context, () => ref.read(noteActionsProvider).delete(note));
        if (context.mounted) _toast(context, '削除しました');
    }
  }

  Future<bool?> _confirm(
    BuildContext context, {
    required String title,
    required String message,
    required String action,
  }) => showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('キャンセル'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(action),
        ),
      ],
    ),
  );

  /// リモートのノートは元サーバーの URL。ローカルのノートは API が url を
  /// 返さないので、ログイン中のホストから組み立てる。
  String? _noteUrl(WidgetRef ref, Note note) {
    final remote = note.url ?? note.uri;
    if (remote != null) return remote;
    final host = ref.read(currentHostProvider);
    return host == null ? null : 'https://$host/notes/${note.id}';
  }

  Future<void> _run(
    BuildContext context,
    Future<void> Function() action,
  ) async {
    try {
      await action();
    } catch (e) {
      if (!context.mounted) return;
      _toast(context, resolveErrorMessage(e));
    }
  }

  void _toast(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
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
        // Material 3 の最小タップ領域は 48x48。返信・リノート・リアクションは
        // 隣り合うので、ここが小さいと押し間違いが起きる。
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

/// 引用リノートの中に埋め込まれる、枠付きの小さなノート。
