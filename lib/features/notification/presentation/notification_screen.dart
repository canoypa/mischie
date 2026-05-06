import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mischie/core/error/error_handler.dart';
import 'package:mischie/features/notification/domain/notification_item.dart';
import 'package:mischie/features/notification/domain/notification_notifier.dart';
import 'package:timeago/timeago.dart' as timeago;

class NotificationScreen extends ConsumerWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncState = ref.watch(notificationNotifierProvider);

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
                  return _NotificationTile(item: items[index]);
                },
              ),
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({required this.item});

  final NotificationItem item;

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
    final time = timeago.format(DateTime.parse(item.createdAt), locale: 'ja');

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: color.withAlpha(40),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text('$username が $label'),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (item.note?.text != null)
            Text(
              item.note!.text!,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
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
