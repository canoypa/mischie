import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mischie/core/emoji/emoji_providers.dart';
import 'package:mischie/core/error/error_handler.dart';
import 'package:mischie/core/widgets/mfm_text.dart';
import 'package:mischie/features/notification/domain/notification_item.dart';
import 'package:mischie/features/notification/domain/notification_notifier.dart';
import 'package:timeago/timeago.dart' as timeago;

class NotificationScreen extends ConsumerWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
            : ListView.builder(
                itemCount: items.length + 1,
                itemBuilder: (context, index) {
                  if (index == items.length) {
                    return Padding(
                      padding: const EdgeInsets.all(16),
                      child: FilledButton(
                        onPressed: () => ref
                            .read(notificationNotifierProvider.notifier)
                            .loadMore(),
                        child: const Text('もっと読み込む'),
                      ),
                    );
                  }
                  return _NotificationTile(
                    item: items[index],
                    serverEmojis: serverEmojis,
                  );
                },
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
    final (icon, color, label) = switch (item.type) {
      'reaction' => (Icons.add_reaction, Colors.orange, 'リアクション'),
      'reply' => (Icons.reply, Colors.blue, 'リプライ'),
      'renote' => (Icons.repeat, Colors.green, 'リノート'),
      'quote' => (Icons.format_quote, Colors.green, '引用'),
      'mention' => (Icons.alternate_email, Colors.purple, 'メンション'),
      'follow' => (Icons.person_add, Colors.teal, 'フォロー'),
      'followRequestAccepted' => (Icons.how_to_reg, Colors.teal, 'フォロー承認'),
      _ => (Icons.notifications, Colors.grey, item.type),
    };

    final username = item.user?.name ?? item.user?.username ?? '不明';
    final handle = item.user != null
        ? (item.user!.host != null
              ? '@${item.user!.username}@${item.user!.host}'
              : '@${item.user!.username}')
        : null;
    final time = timeago.format(DateTime.parse(item.createdAt), locale: 'ja');
    final noteEmojis = {
      ...serverEmojis,
      ...?item.note?.emojis,
      ...?item.note?.reactionEmojis,
    };

    return ListTile(
      leading: SizedBox(
        width: 44,
        height: 44,
        child: Stack(
          children: [
            Positioned.fill(
              child: item.user?.avatarUrl != null
                  ? CircleAvatar(
                      backgroundImage: CachedNetworkImageProvider(
                        item.user!.avatarUrl!,
                      ),
                    )
                  : const CircleAvatar(child: Icon(Icons.person)),
            ),
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Theme.of(context).colorScheme.surface,
                    width: 1.5,
                  ),
                ),
                child: Icon(icon, size: 11, color: Colors.white),
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
              emojis: const {},
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
            Text(item.reaction!, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
      trailing: Text(time, style: Theme.of(context).textTheme.bodySmall),
    );
  }
}
