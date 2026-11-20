import 'package:cached_network_image/cached_network_image.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mischie/core/image/image_cache_managers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mischie/core/emoji/emoji_providers.dart';
import 'package:mischie/core/error/error_handler.dart';
import 'package:mischie/core/widgets/mfm_text.dart';
import 'package:mischie/features/channel/domain/channel.dart';
import 'package:mischie/features/channel/domain/channel_notifier.dart';
import 'package:mischie/features/compose/presentation/compose_screen.dart';
import 'package:mischie/features/timeline/domain/note.dart';
import 'package:mischie/features/timeline/domain/note_store.dart';
import 'package:mischie/features/timeline/presentation/note_card.dart';

void openChannel(BuildContext context, String channelId, {String? name}) {
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => ChannelScreen(channelId: channelId, initialName: name),
    ),
  );
}

class ChannelScreen extends ConsumerStatefulWidget {
  const ChannelScreen({super.key, required this.channelId, this.initialName});

  final String channelId;
  final String? initialName;

  @override
  ConsumerState<ChannelScreen> createState() => _ChannelScreenState();
}

class _ChannelScreenState extends ConsumerState<ChannelScreen> {
  final _scrollController = ScrollController();
  final List<Note> _notes = [];
  bool _loading = true;
  bool _loadingMore = false;
  Object? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final repo = ref.read(channelRepositoryProvider);
    if (repo == null) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final notes = await repo.timeline(widget.channelId);
      if (!mounted) return;
      ref.read(noteOverridesProvider.notifier).evictFetched(notes);
      setState(() {
        _notes
          ..clear()
          ..addAll(notes);
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e;
        _loading = false;
      });
    }
  }

  Future<void> _loadMore() async {
    final repo = ref.read(channelRepositoryProvider);
    if (repo == null || _notes.isEmpty || _loadingMore) return;
    setState(() => _loadingMore = true);
    try {
      final older = await repo.timeline(
        widget.channelId,
        untilId: _notes.last.id,
      );
      if (!mounted) return;
      ref.read(noteOverridesProvider.notifier).evictFetched(older);
      setState(() => _notes.addAll(older));
    } catch (_) {
      // 追加読み込みの失敗は黙って諦める（先頭は読めているため）
    } finally {
      if (mounted) setState(() => _loadingMore = false);
    }
  }

  Future<void> _compose(Channel channel) async {
    final posted = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => ComposeScreen(
          channel: NoteChannel(id: channel.id, name: channel.name),
        ),
      ),
    );
    if (posted == true && mounted) _load();
  }

  @override
  Widget build(BuildContext context) {
    final channelAsync = ref.watch(channelProvider(widget.channelId));
    final serverEmojis = ref.watch(emojiCacheProvider).value ?? const {};
    final channel = channelAsync.value;
    final title = channel?.name ?? widget.initialName ?? 'チャンネル';

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      // アーカイブされたチャンネルには投稿できない
      floatingActionButton: channel == null || channel.isArchived
          ? null
          : FloatingActionButton(
              tooltip: 'チャンネルに投稿',
              onPressed: () => _compose(channel),
              child: const Icon(Icons.edit),
            ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: NotificationListener<ScrollUpdateNotification>(
          onNotification: (n) {
            final pos = n.metrics;
            if (pos.pixels >= pos.maxScrollExtent - 300) _loadMore();
            return false;
          },
          child: CustomScrollView(
            controller: _scrollController,
            slivers: [
              SliverToBoxAdapter(
                child: channelAsync.when(
                  loading: () => const SizedBox(height: 120),
                  error: (e, _) => Padding(
                    padding: const EdgeInsets.all(24),
                    child: Center(child: Text(resolveErrorMessage(e))),
                  ),
                  data: (channel) => _ChannelHeader(channel: channel),
                ),
              ),
              if (_loading && _notes.isEmpty)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                )
              else if (_error != null && _notes.isEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      children: [
                        Text(resolveErrorMessage(_error!)),
                        const SizedBox(height: 8),
                        FilledButton(
                          onPressed: _load,
                          child: const Text('再試行'),
                        ),
                      ],
                    ),
                  ),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => RepaintBoundary(
                      key: ValueKey(_notes[index].id),
                      child: NoteCard(
                        note: _notes[index],
                        serverEmojis: serverEmojis,
                      ),
                    ),
                    childCount: _notes.length,
                  ),
                ),
              SliverToBoxAdapter(
                child: _loadingMore
                    ? const Padding(
                        padding: EdgeInsets.all(16),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    : const SizedBox(height: 80),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChannelHeader extends ConsumerWidget {
  const _ChannelHeader({required this.channel});

  final Channel channel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (channel.bannerUrl != null)
          SizedBox(
            height: 120,
            width: double.infinity,
            child: CachedNetworkImage(
              imageUrl: channel.bannerUrl!,
              cacheManager: MediaCacheManager.instance,
              fit: BoxFit.cover,
              placeholder: (_, _) =>
                  Container(color: colorScheme.surfaceContainerHighest),
            ),
          ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      channel.name,
                      style: textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  _ChannelFollowButton(channel: channel),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                '${channel.usersCount} 人 ・ ${channel.notesCount} ノート',
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              if (channel.description != null &&
                  channel.description!.isNotEmpty) ...[
                const SizedBox(height: 8),
                MfmText(channel.description!),
              ],
            ],
          ),
        ),
        const Divider(),
      ],
    );
  }
}

class _ChannelFollowButton extends ConsumerWidget {
  const _ChannelFollowButton({required this.channel});

  final Channel channel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final override = ref.watch(
      channelFollowOverridesProvider.select((m) => m[channel.id]),
    );
    final isFollowing = override ?? channel.isFollowing;

    Future<void> toggle() async {
      try {
        await ref
            .read(channelFollowActionsProvider)
            .setFollowing(channel.id, following: !isFollowing);
      } catch (e) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(resolveErrorMessage(e))));
      }
    }

    if (isFollowing) {
      return OutlinedButton.icon(
        onPressed: toggle,
        icon: const Icon(Icons.check, size: 18),
        label: const Text('フォロー中'),
      );
    }
    return FilledButton.icon(
      onPressed: toggle,
      icon: const Icon(Icons.add, size: 18),
      label: const Text('フォロー'),
    );
  }
}
