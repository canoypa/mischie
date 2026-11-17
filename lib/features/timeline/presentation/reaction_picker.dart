import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:mischie/core/image/image_cache_managers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mischie/core/emoji/emoji_providers.dart';
import 'package:mischie/core/widgets/custom_emoji_image.dart';
import 'package:mischie/features/timeline/domain/reaction_key.dart';
import 'package:mischie/features/timeline/presentation/note/reactions.dart';

/// サーバーが返すキーと突き合わせるため、正規化済み（VS16 無し）で持つ。
const _defaultReactions = [
  '👍',
  '❤',
  '😆',
  '🤔',
  '😮',
  '🎉',
  '💢',
  '😥',
  '😇',
  '🍮',
];

/// 正規化済みのリアクションキーを返す。
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

  // 打鍵のたびにソートし直さないためのキャッシュ。
  Map<String, String>? _lastEmojis;
  List<String> _local = const [];

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

  final Set<String> _openCategories = {};

  static const _gridDelegate = SliverGridDelegateWithMaxCrossAxisExtent(
    maxCrossAxisExtent: 56,
    mainAxisSpacing: 4,
    crossAxisSpacing: 4,
  );

  static const _uncategorized = 'その他';

  List<(String, List<String>)> _categorized(
    List<String> names,
    Map<String, String> categories,
  ) {
    final groups = <String, List<String>>{};
    for (final name in names) {
      groups
          .putIfAbsent(categories[name] ?? _uncategorized, () => [])
          .add(name);
    }
    final keys = groups.keys.where((k) => k != _uncategorized).toList()..sort();
    if (groups.containsKey(_uncategorized)) keys.add(_uncategorized);
    return [for (final key in keys) (key, groups[key]!)];
  }

  Widget _emojiTile(
    BuildContext context,
    String name,
    Map<String, String> emojis,
  ) {
    final key = normalizeReactionKey(':$name:');
    return InkWell(
      onTap: () => Navigator.of(context).pop(key),
      borderRadius: BorderRadius.circular(8),
      child: Tooltip(
        message: ':$name:',
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: CachedNetworkImage(
            imageUrl: emojis[name]!,
            cacheManager: EmojiCacheManager.instance,
            fit: BoxFit.contain,
            placeholder: (_, _) => const SizedBox(height: 32, width: 32),
            errorWidget: (_, _, _) => const Icon(Icons.broken_image, size: 20),
          ),
        ),
      ),
    );
  }

  List<String> _localNames(Map<String, String> emojis) {
    if (!identical(_lastEmojis, emojis)) {
      _lastEmojis = emojis;
      // 外部サーバーの絵文字 (name@host) は自サーバーへリアクションできない
      _local = emojis.keys.where((k) => !k.contains('@')).toList()..sort();
    }
    return _local;
  }

  @override
  Widget build(BuildContext context) {
    final emojis = ref.watch(emojiCacheProvider).value ?? const {};
    final history = ref.watch(reactionHistoryProvider).value ?? const [];
    final quickPicks = history.isEmpty ? _defaultReactions : history;
    final local = _localNames(emojis);
    final categories =
        ref.watch(emojiCatalogProvider).value?.categories ?? const {};
    final filtered = _query.isEmpty
        ? local
        : local.where((k) => k.toLowerCase().contains(_query)).toList();
    // キーボードの絵文字をそのまま打ち込んだら、それでリアクションできる
    final raw = _searchController.text.trim();
    final unicodeCandidate =
        raw.isNotEmpty && !raw.contains(RegExp(r'[A-Za-z0-9_:\s]'))
        ? raw
        : null;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: DraggableScrollableSheet(
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
              child: _query.isEmpty
                  ? CustomScrollView(
                      controller: scrollController,
                      slivers: [
                        for (final (category, names) in _categorized(
                          local,
                          categories,
                        )) ...[
                          SliverToBoxAdapter(
                            child: ListTile(
                              dense: true,
                              title: Text(category),
                              trailing: Icon(
                                _openCategories.contains(category)
                                    ? Icons.expand_less
                                    : Icons.expand_more,
                              ),
                              onTap: () => setState(() {
                                if (!_openCategories.remove(category)) {
                                  _openCategories.add(category);
                                }
                              }),
                            ),
                          ),
                          if (_openCategories.contains(category))
                            SliverPadding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              sliver: SliverGrid.builder(
                                gridDelegate: _gridDelegate,
                                itemCount: names.length,
                                itemBuilder: (context, index) =>
                                    _emojiTile(context, names[index], emojis),
                              ),
                            ),
                        ],
                      ],
                    )
                  : filtered.isEmpty && unicodeCandidate == null
                  ? const Center(child: Text('絵文字が見つかりません'))
                  : GridView.builder(
                      controller: scrollController,
                      padding: const EdgeInsets.all(12),
                      gridDelegate: _gridDelegate,
                      itemCount:
                          filtered.length + (unicodeCandidate == null ? 0 : 1),
                      itemBuilder: (context, index) {
                        if (unicodeCandidate != null) {
                          if (index == 0) {
                            return InkWell(
                              onTap: () => Navigator.of(
                                context,
                              ).pop(normalizeReactionKey(unicodeCandidate)),
                              borderRadius: BorderRadius.circular(8),
                              child: Center(
                                child: Text(
                                  unicodeCandidate,
                                  style: const TextStyle(fontSize: 28),
                                ),
                              ),
                            );
                          }
                          index--;
                        }
                        return _emojiTile(context, filtered[index], emojis);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickPick extends StatelessWidget {
  const _QuickPick({required this.reaction, required this.emojis});

  final String reaction;
  final Map<String, String> emojis;

  @override
  Widget build(BuildContext context) {
    final match = customEmojiPattern.firstMatch(reaction);
    final identifier = match?.group(1);
    // 履歴には `:name@.:` の形も入るので、ホスト付きでも引ける lookupEmojiUrl を使う。
    final url = identifier == null ? null : lookupEmojiUrl(emojis, identifier);
    if (url == null) {
      return Text(reaction, style: const TextStyle(fontSize: 26));
    }
    return CustomEmojiImage(url: url, size: 28, errorFallback: Text(reaction));
  }
}
