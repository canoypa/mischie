import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mischie/core/emoji/emoji_providers.dart';

/// 履歴が空のときに出す既定。カスタム絵文字が無いサーバーでも押せる。
const _defaultReactions = [
  '👍',
  '❤️',
  '😆',
  '🤔',
  '😮',
  '🎉',
  '💢',
  '😥',
  '😇',
  '🍮',
];

/// リアクションを選ぶボトムシート。
/// 選ばれたリアクション（Unicode 絵文字そのもの、または `:name:`）を返す。
Future<String?> showReactionPicker(BuildContext context) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => const _ReactionPicker(),
  );
}

class _ReactionPicker extends ConsumerStatefulWidget {
  const _ReactionPicker();

  @override
  ConsumerState<_ReactionPicker> createState() => _ReactionPickerState();
}

class _ReactionPickerState extends ConsumerState<_ReactionPicker> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(
      () =>
          setState(() => _query = _searchController.text.trim().toLowerCase()),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final emojis = ref.watch(emojiCacheProvider).value ?? const {};
    final history = ref.watch(reactionHistoryProvider).value ?? const [];
    final quickPicks = history.isEmpty ? _defaultReactions : history;
    // 外部サーバーの絵文字 (name@host) は自サーバーへリアクションできない
    final local = emojis.keys.where((k) => !k.contains('@')).toList()..sort();
    final filtered = _query.isEmpty
        ? local
        : local.where((k) => k.toLowerCase().contains(_query)).toList();

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.3,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) => Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              controller: _searchController,
              autofocus: false,
              decoration: const InputDecoration(
                hintText: '絵文字を検索',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
          ),
          if (_query.isEmpty)
            SizedBox(
              height: 52,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                children: [
                  for (final reaction in quickPicks)
                    InkWell(
                      onTap: () => Navigator.of(context).pop(reaction),
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: _QuickPick(reaction: reaction, emojis: emojis),
                      ),
                    ),
                ],
              ),
            ),
          const Divider(height: 1),
          Expanded(
            child: filtered.isEmpty
                ? const Center(child: Text('絵文字が見つかりません'))
                : GridView.builder(
                    controller: scrollController,
                    padding: const EdgeInsets.all(12),
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 56,
                          mainAxisSpacing: 4,
                          crossAxisSpacing: 4,
                        ),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final name = filtered[index];
                      return InkWell(
                        onTap: () => Navigator.of(context).pop(':$name:'),
                        borderRadius: BorderRadius.circular(8),
                        child: Tooltip(
                          message: ':$name:',
                          child: Padding(
                            padding: const EdgeInsets.all(6),
                            child: CachedNetworkImage(
                              imageUrl: emojis[name]!,
                              fit: BoxFit.contain,
                              placeholder: (_, _) =>
                                  const SizedBox(height: 32, width: 32),
                              errorWidget: (_, _, _) =>
                                  const Icon(Icons.broken_image, size: 20),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

/// 履歴の 1 つ。カスタム絵文字 (`:name:`) は画像で、Unicode はそのまま出す。
class _QuickPick extends StatelessWidget {
  const _QuickPick({required this.reaction, required this.emojis});

  final String reaction;
  final Map<String, String> emojis;

  @override
  Widget build(BuildContext context) {
    final match = RegExp(r'^:([^:]+):$').firstMatch(reaction);
    final url = match == null ? null : emojis[match.group(1)];
    if (url == null) {
      return Text(reaction, style: const TextStyle(fontSize: 26));
    }
    return CachedNetworkImage(
      imageUrl: url,
      height: 28,
      placeholder: (_, _) => const SizedBox(height: 28, width: 28),
      errorWidget: (_, _, _) => Text(reaction),
    );
  }
}
