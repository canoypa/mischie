import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mischie/core/emoji/emoji_providers.dart';
import 'package:mischie/core/emoji/layered_emojis.dart';
import 'package:mischie/core/error/error_handler.dart';
import 'package:mischie/core/widgets/decorated_avatar.dart';
import 'package:mischie/core/widgets/mfm_text.dart';
import 'package:mischie/features/profile/presentation/user_profile_screen.dart';
import 'package:mischie/features/notification/domain/notification_item.dart';
import 'package:mischie/features/notification/domain/notification_label.dart';
import 'package:mischie/features/notification/domain/notification_notifier.dart';
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
    try {
      await ref.read(notificationNotifierProvider.notifier).loadMore();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(resolveErrorMessage(e))));
      }
    } finally {
      if (mounted) setState(() => _loadingMore = false);
    }
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
    final colorScheme = Theme.of(context).colorScheme;
    final label = notificationLabel(item.type);
    // 種類の区別はアイコンで付ける。色は Material 3 のカラーロールから
    // 取り、seed から導かれた調和の中に収める。
    final (badgeColor, onBadgeColor) = switch (label.role) {
      NotificationRole.primary => (colorScheme.primary, colorScheme.onPrimary),
      NotificationRole.secondary => (
        colorScheme.secondary,
        colorScheme.onSecondary,
      ),
      NotificationRole.tertiary => (
        colorScheme.tertiary,
        colorScheme.onTertiary,
      ),
      NotificationRole.neutral => (
        colorScheme.surfaceContainerHighest,
        colorScheme.onSurfaceVariant,
      ),
    };

    final username = item.user?.name ?? item.user?.username ?? '不明';
    final handle = item.user?.acct;
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
                    : () => openUserProfile(
                        context,
                        item.user!.id,
                        initialUser: item.user,
                      ),
                child: DecoratedAvatar(
                  avatarUrl: item.user?.avatarUrl,
                  isCat: item.user?.isCat ?? false,
                  avatarBlurhash: item.user?.avatarBlurhash,
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
                child: Icon(label.icon, size: 11, color: onBadgeColor),
              ),
            ),
          ],
        ),
      ),
      // 相手のいない通知（投票の終了・実績など）では名前を出さない。
      // 付けると「Cano が 投票が終了しました」のように文が壊れる。
      title: label.hasActor
          ? Row(
              children: [
                Flexible(
                  child: MfmText(
                    username,
                    emojis: serverEmojis,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (handle != null)
                  Text(
                    ' $handle',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                Text(
                  ' ${label.text}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            )
          : Text(label.text, style: Theme.of(context).textTheme.bodyMedium),
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
        if (user != null) openUserProfile(context, user.id, initialUser: user);
      },
    );
  }
}
