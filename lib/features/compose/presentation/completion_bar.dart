import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mischie/core/widgets/custom_emoji_image.dart';
import 'package:mischie/features/compose/domain/compose_completion.dart';

class CompletionBar extends ConsumerWidget {
  const CompletionBar({
    super.key,
    required this.query,
    required this.emojis,
    required this.mentionQuery,
    required this.onSelected,
  });

  final CompletionQuery query;
  final Map<String, String> emojis;

  /// 打鍵を間引いたあとの検索語。
  final String mentionQuery;

  final ValueChanged<String> onSelected;

  static const _maxItems = 30;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = _items(ref);
    if (items.isEmpty) return const SizedBox.shrink();

    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        border: Border(
          top: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
        ),
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: ActionChip(
                avatar: item.imageUrl == null
                    ? null
                    : CustomEmojiImage(
                        url: item.imageUrl!,
                        size: 18,
                        errorFallback: const SizedBox.shrink(),
                      ),
                label: Text(item.label),
                visualDensity: VisualDensity.compact,
                onPressed: () => onSelected(item.replacement),
              ),
            ),
          );
        },
      ),
    );
  }

  List<_Item> _items(WidgetRef ref) {
    final needle = query.query.toLowerCase();

    return switch (query.kind) {
      CompletionKind.emoji => [
        // 外部サーバーの絵文字は自分の投稿には使えない
        for (final name
            in emojis.keys
                .where(
                  (k) => !k.contains('@') && k.toLowerCase().contains(needle),
                )
                .take(_maxItems))
          _Item(label: name, replacement: ':$name:', imageUrl: emojis[name]),
      ],
      CompletionKind.mfmFunction => [
        for (final fn in mfmFunctions.where((f) => f.startsWith(needle)))
          // 装飾は対象の文字が要るので、開いた形で差し込む
          _Item(label: fn, replacement: '\$[$fn '),
      ],
      CompletionKind.mention => [
        for (final user
            in ref.watch(mentionSuggestionsProvider(mentionQuery)).value ??
                const [])
          _Item(
            label: user.host == null
                ? '@${user.username}'
                : '@${user.username}@${user.host}',
            replacement: user.host == null
                ? '@${user.username} '
                : '@${user.username}@${user.host} ',
            imageUrl: user.avatarUrl,
          ),
      ],
    };
  }
}

class _Item {
  const _Item({required this.label, required this.replacement, this.imageUrl});

  final String label;
  final String replacement;
  final String? imageUrl;
}
