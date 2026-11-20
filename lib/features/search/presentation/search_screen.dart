import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mischie/core/emoji/emoji_providers.dart';
import 'package:mischie/core/error/error_handler.dart';
import 'package:mischie/core/navigation/link_handler.dart';
import 'package:mischie/core/widgets/decorated_avatar.dart';
import 'package:mischie/core/widgets/mfm_text.dart';
import 'package:mischie/features/profile/domain/user_detailed.dart';
import 'package:mischie/features/profile/presentation/user_profile_screen.dart';
import 'package:mischie/features/channel/presentation/channel_list.dart';
import 'package:mischie/features/search/domain/search_notifier.dart';
import 'package:mischie/features/timeline/presentation/note_card.dart';

/// スクロールから await せずに呼ぶので、失敗はここで知らせる。
Future<void> _loadMoreNotes(BuildContext context, WidgetRef ref) async {
  try {
    await ref.read(noteSearchProvider.notifier).loadMore();
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(resolveErrorMessage(e))));
    }
  }
}

Future<void> _loadMoreUsers(BuildContext context, WidgetRef ref) async {
  try {
    await ref.read(userSearchProvider.notifier).loadMore();
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(resolveErrorMessage(e))));
    }
  }
}

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen>
    with SingleTickerProviderStateMixin {
  final _controller = TextEditingController();
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    // クリアボタンの出し分けのため入力に追従する
    _controller.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _submit(String value) {
    ref.read(searchQueryProvider.notifier).query = value.trim();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: TextField(
            controller: _controller,
            textInputAction: TextInputAction.search,
            // 1 文字ごとに検索するとサーバーに無駄な負荷をかけるので確定時のみ
            onSubmitted: _submit,
            decoration: InputDecoration(
              hintText: 'ノートやユーザーを検索',
              prefixIcon: const Icon(Icons.search),
              border: const OutlineInputBorder(),
              isDense: true,
              suffixIcon: _controller.text.isEmpty
                  ? null
                  : IconButton(
                      icon: const Icon(Icons.clear),
                      tooltip: '消去',
                      onPressed: () {
                        _controller.clear();
                        _submit('');
                        setState(() {});
                      },
                    ),
            ),
          ),
        ),
        TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'ノート'),
            Tab(text: 'ユーザー'),
            Tab(text: 'チャンネル'),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              const _NoteResults(),
              const _UserResults(),
              Consumer(
                builder: (context, ref, _) =>
                    ChannelResults(query: ref.watch(searchQueryProvider)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _NoteResults extends ConsumerWidget {
  const _NoteResults();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final query = ref.watch(searchQueryProvider);
    if (query.isEmpty) return const _Placeholder();

    final serverEmojis = ref.watch(emojiCacheProvider).value ?? const {};
    return ref
        .watch(noteSearchProvider)
        .when(
          loading: () => const Center(child: CircularProgressIndicator()),
          // ノート検索は無効化されているサーバーもある。行き止まりにせず
          // Web クライアントの検索へ逃がす。
          error: (e, _) => _SearchError(
            message: resolveErrorMessage(e),
            onOpenWeb: () => openOnServer(
              ref,
              '/search?q=${Uri.encodeQueryComponent(query)}',
            ),
          ),
          data: (notes) => notes.isEmpty
              ? const Center(child: Text('見つかりませんでした'))
              : NotificationListener<ScrollUpdateNotification>(
                  onNotification: (n) {
                    final pos = n.metrics;
                    if (pos.pixels >= pos.maxScrollExtent - 200) {
                      _loadMoreNotes(context, ref);
                    }
                    return false;
                  },
                  child: ListView.builder(
                    // 最後の項目が投稿ボタン（FAB）に隠れないよう空ける
                    padding: const EdgeInsets.only(bottom: 80),
                    itemCount: notes.length,
                    itemBuilder: (context, index) => RepaintBoundary(
                      child: NoteCard(
                        note: notes[index],
                        serverEmojis: serverEmojis,
                      ),
                    ),
                  ),
                ),
        );
  }
}

class _UserResults extends ConsumerWidget {
  const _UserResults();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final query = ref.watch(searchQueryProvider);
    if (query.isEmpty) return const _Placeholder();

    final serverEmojis = ref.watch(emojiCacheProvider).value ?? const {};
    return ref
        .watch(userSearchProvider)
        .when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => _SearchError(
            message: resolveErrorMessage(e),
            onOpenWeb: () => openOnServer(
              ref,
              '/search?q=${Uri.encodeQueryComponent(query)}&type=user',
            ),
          ),
          data: (users) => users.isEmpty
              ? const Center(child: Text('見つかりませんでした'))
              : NotificationListener<ScrollUpdateNotification>(
                  onNotification: (n) {
                    final pos = n.metrics;
                    if (pos.pixels >= pos.maxScrollExtent - 200) {
                      _loadMoreUsers(context, ref);
                    }
                    return false;
                  },
                  child: ListView.builder(
                    // 最後の項目が投稿ボタン（FAB）に隠れないよう空ける
                    padding: const EdgeInsets.only(bottom: 80),
                    itemCount: users.length,
                    itemBuilder: (context, index) =>
                        _UserTile(user: users[index], emojis: serverEmojis),
                  ),
                ),
        );
  }
}

class _UserTile extends StatelessWidget {
  const _UserTile({required this.user, required this.emojis});

  final UserDetailed user;
  final Map<String, String> emojis;

  @override
  Widget build(BuildContext context) {
    final handle = user.acct;

    return ListTile(
      leading: DecoratedAvatar(
        avatarUrl: user.avatarUrl,
        isCat: user.isCat,
        decorations: user.avatarDecorations,
      ),
      title: MfmText(user.name ?? user.username, emojis: emojis),
      subtitle: Text(handle),
      onTap: () => openUserProfile(context, user.id),
    );
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'キーワードを入力してください',
        style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
      ),
    );
  }
}

class _SearchError extends StatelessWidget {
  const _SearchError({required this.message, required this.onOpenWeb});

  final String message;
  final VoidCallback onOpenWeb;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: onOpenWeb,
              icon: const Icon(Icons.open_in_browser),
              label: const Text('Web で検索'),
            ),
          ],
        ),
      ),
    );
  }
}
