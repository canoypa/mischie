import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mischie/core/error/error_handler.dart';
import 'package:mischie/features/channel/domain/channel.dart';
import 'package:mischie/features/channel/domain/channel_notifier.dart';
import 'package:mischie/features/channel/presentation/channel_screen.dart';

/// 検索語が空のときは、フォロー中とおすすめを出す。
class ChannelResults extends ConsumerWidget {
  const ChannelResults({super.key, required this.query});

  final String query;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (query.isNotEmpty) {
      return _ChannelAsyncList(
        value: ref.watch(channelSearchProvider(query)),
        emptyMessage: '見つかりませんでした',
        onRetry: () => ref.invalidate(channelSearchProvider(query)),
      );
    }

    final followed = ref.watch(followedChannelsProvider);
    final featured = ref.watch(featuredChannelsProvider);

    return ListView(
      children: [
        if ((followed.value ?? const []).isNotEmpty) ...[
          const _SectionHeader(label: 'フォロー中'),
          for (final channel in followed.value!) _ChannelTile(channel: channel),
        ],
        const _SectionHeader(label: 'おすすめ'),
        ...switch (featured) {
          AsyncData(:final value) when value.isEmpty => [
            const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: Text('おすすめはありません')),
            ),
          ],
          AsyncData(:final value) => [
            for (final channel in value) _ChannelTile(channel: channel),
          ],
          AsyncError(:final error) => [
            Padding(
              padding: const EdgeInsets.all(24),
              child: Center(child: Text(resolveErrorMessage(error))),
            ),
          ],
          _ => [
            const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: CircularProgressIndicator()),
            ),
          ],
        },
      ],
    );
  }
}

class _ChannelAsyncList extends StatelessWidget {
  const _ChannelAsyncList({
    required this.value,
    required this.emptyMessage,
    required this.onRetry,
  });

  final AsyncValue<List<Channel>> value;
  final String emptyMessage;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return value.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(resolveErrorMessage(e)),
            const SizedBox(height: 8),
            FilledButton(onPressed: onRetry, child: const Text('再試行')),
          ],
        ),
      ),
      data: (channels) => channels.isEmpty
          ? Center(child: Text(emptyMessage))
          : ListView.builder(
              itemCount: channels.length,
              itemBuilder: (context, index) =>
                  _ChannelTile(channel: channels[index]),
            ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(
        label,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}

class _ChannelTile extends StatelessWidget {
  const _ChannelTile({required this.channel});

  final Channel channel;

  @override
  Widget build(BuildContext context) {
    final description = channel.description;

    return ListTile(
      leading: const Icon(Icons.tv),
      title: Text(channel.name),
      subtitle: description == null || description.isEmpty
          ? Text('${channel.usersCount} 人 / ${channel.notesCount} ノート')
          : Text(description, maxLines: 2, overflow: TextOverflow.ellipsis),
      trailing: channel.isFollowing
          ? Icon(Icons.check, color: Theme.of(context).colorScheme.primary)
          : null,
      onTap: () => openChannel(context, channel.id, name: channel.name),
    );
  }
}
