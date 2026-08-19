import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:mischie/core/image/image_cache_managers.dart';
import 'package:mischie/features/compose/domain/compose_completion.dart';

/// 入力中の `:` や `$[` に対する候補。本文の直下に横並びで出す。
///
/// 候補はサーバーの絵文字一覧と MFM の装飾名から作るので、打鍵ごとの
/// 通信は起きない。
class CompletionBar extends StatelessWidget {
  const CompletionBar({
    super.key,
    required this.query,
    required this.emojis,
    required this.onSelected,
  });

  final CompletionQuery query;
  final Map<String, String> emojis;

  /// 置き換える文字列（`:name:` や `$[fn ` の形）を返す。
  final ValueChanged<String> onSelected;

  static const _maxItems = 30;

  @override
  Widget build(BuildContext context) {
    final items = _items();
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
                    : CachedNetworkImage(
                        imageUrl: item.imageUrl!,
                        cacheManager: EmojiCacheManager.instance,
                        height: 18,
                        placeholder: (_, _) =>
                            const SizedBox(height: 18, width: 18),
                        errorWidget: (_, _, _) => const SizedBox.shrink(),
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

  List<_Item> _items() {
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
      // メンションは打鍵ごとに検索が要るので、ここでは出さない
      CompletionKind.mention => const [],
    };
  }
}

class _Item {
  const _Item({required this.label, required this.replacement, this.imageUrl});

  final String label;
  final String replacement;
  final String? imageUrl;
}
