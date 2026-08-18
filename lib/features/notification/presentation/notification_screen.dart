import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mischie/core/emoji/emoji_providers.dart';
import 'package:mischie/core/emoji/layered_emojis.dart';
import 'package:mischie/core/error/error_handler.dart';
import 'package:mischie/core/widgets/decorated_avatar.dart';
import 'package:mischie/core/widgets/mfm_text.dart';
import 'package:mischie/features/profile/presentation/user_profile_screen.dart';
import 'package:mischie/features/notification/domain/notification_item.dart';
import 'package:mischie/features/notification/domain/notification_notifier.dart';
import 'package:mischie/features/timeline/domain/user.dart';
import 'package:mischie/features/timeline/presentation/note_detail_screen.dart';
import 'package:timeago/timeago.dart' as timeago;

class NotificationScreen extends ConsumerStatefulWidget {
  const NotificationScreen({super.key});

  @override
  ConsumerState<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends ConsumerState<NotificationScreen> {
  bool _loadingMore = false;

  Future<void> _loadMore() async {
    if (_loadingMore) return;
    setState(() => _loadingMore = true);
    await ref.read(notificationNotifierProvider.notifier).loadMore();
    if (mounted) setState(() => _loadingMore = false);
  }

  @override
  Widget build(BuildContext context) {
    final asyncState = ref.watch(notificationNotifierProvider);
    final serverEmojis = ref.watch(emojiCacheProvider).value ?? {};

    return asyncState.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(resolveErrorMessage(e)),
            const SizedBox(height: 8),
            FilledButton(
              onPressed: () => ref.invalidate(notificationNotifierProvider),
              child: const Text('再試行'),
            ),
          ],
        ),
      ),
      data: (items) => RefreshIndicator(
        onRefresh: () =>
            ref.read(notificationNotifierProvider.notifier).refresh(),
        child: items.isEmpty
            ? const Center(child: Text('通知はありません'))
            : NotificationListener<ScrollUpdateNotification>(
                onNotification: (n) {
                  final pos = n.metrics;
                  if (pos.pixels >= pos.maxScrollExtent - 200) _loadMore();
                  return false;
                },
                child: ListView.builder(
                  itemCount: items.length + 1,
                  itemBuilder: (context, index) {
                    if (index == items.length) {
                      return _loadingMore
                          ? const Padding(
                              padding: EdgeInsets.all(16),
                              child: Center(child: CircularProgressIndicator()),
                            )
                          : const SizedBox(height: 80);
                    }
                    return _NotificationTile(
                      item: items[index],
                      serverEmojis: serverEmojis,
                    );
                  },
                ),
              ),
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({required this.item, required this.serverEmojis});

  final NotificationItem item;
  final Map<String, String> serverEmojis;

  @override
  Widget build(BuildContext context) {
    // 種類の区別はアイコンで付ける。色は Material 3 のカラーロールから
    // 取り、seed から導かれた調和の中に収める（既製の赤や青を直接使うと
    // テーマから浮く）。
    final colorScheme = Theme.of(context).colorScheme;
    final (icon, badgeColor, onBadgeColor, label) = switch (item.type) {
      'reaction' => (
        Icons.add_reaction,
        colorScheme.tertiary,
        colorScheme.onTertiary,
        'リアクション',
      ),
      'reply' => (
        Icons.reply,
        colorScheme.primary,
        colorScheme.onPrimary,
        'リプライ',
      ),
      'renote' => (
        Icons.repeat,
        colorScheme.secondary,
        colorScheme.onSecondary,
        'リノート',
      ),
      'quote' => (
        Icons.format_quote,
        colorScheme.secondary,
        colorScheme.onSecondary,
        '引用',
      ),
      'mention' => (
        Icons.alternate_email,
        colorScheme.primary,
        colorScheme.onPrimary,
        'メンション',
      ),
      'follow' => (
        Icons.person_add,
        colorScheme.tertiary,
        colorScheme.onTertiary,
        'フォロー',
      ),
      'followRequestAccepted' => (
        Icons.how_to_reg,
        colorScheme.tertiary,
        colorScheme.onTertiary,
        'フォロー承認',
      ),
      _ => (
        Icons.notifications,
        colorScheme.surfaceContainerHighest,
        colorScheme.onSurfaceVariant,
        item.type,
      ),
    };

    final username = item.user?.name ?? item.user?.username ?? '不明';
    final handle = item.user != null
        ? (item.user!.host != null
              ? '@${item.user!.username}@${item.user!.host}'
              : '@${item.user!.username}')
        : null;
    final time = timeago.format(DateTime.parse(item.createdAt), locale: 'ja');
    final noteEmojis = LayeredEmojis(
      base: serverEmojis,
      overlay: {...?item.note?.emojis, ...?item.note?.reactionEmojis},
    );

    return ListTile(
      leading: SizedBox(
        width: 44,
        height: 44,
        child: Stack(
          children: [
            // アイコンからは相手のプロフィールへ。通知そのもののタップ先
            // （ノート）とは期待される行き先が違う。
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: item.user == null
                    ? null
                    : () => _openProfile(context, item.user!),
                child: DecoratedAvatar(
                  avatarUrl: item.user?.avatarUrl,
                  isCat: item.user?.isCat ?? false,
                  decorations: item.user?.avatarDecorations ?? const [],
                ),
              ),
            ),
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  color: badgeColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: colorScheme.surface, width: 1.5),
                ),
                child: Icon(icon, size: 11, color: onBadgeColor),
              ),
            ),
          ],
        ),
      ),
      title: Row(
        children: [
          Flexible(
            child: MfmText(
              username,
              emojis: serverEmojis,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          if (handle != null)
            Text(
              ' $handle',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          Text(' が $label', style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (item.note?.text != null)
            MfmText(
              item.note!.text!,
              emojis: noteEmojis,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          if (item.reaction != null)
            MfmText(
              item.reaction!,
              emojis: noteEmojis,
              style: Theme.of(context).textTheme.bodySmall,
            ),
        ],
      ),
      trailing: Text(time, style: Theme.of(context).textTheme.bodySmall),
      // 通知は「開けて当然」なので、ノートがあればノートへ、
      // なければ相手のプロフィールへ飛ぶ
      onTap: () {
        final note = item.note;
        if (note != null) {
          openNoteDetail(context, note);
          return;
        }
        final user = item.user;
        if (user != null) _openProfile(context, user);
      },
    );
  }

  void _openProfile(BuildContext context, User user) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => UserProfileScreen(userId: user.id, initialUser: user),
      ),
    );
  }
}
