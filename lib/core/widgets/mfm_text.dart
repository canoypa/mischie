import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:mfm/mfm.dart';

/// MFM (Misskey Flavored Markdown) テキストを描画するウィジェット。
///
/// [emojis] にノートが持つカスタム絵文字マップ (shortcode → URL) を渡すと
/// `:emoji_name:` を画像として描画する。
class MfmText extends StatelessWidget {
  const MfmText(
    this.text, {
    super.key,
    this.emojis = const {},
    this.style,
    this.maxLines,
    this.overflow,
  });

  final String text;
  final Map<String, String> emojis;
  final TextStyle? style;
  final int? maxLines;
  final TextOverflow? overflow;

  @override
  Widget build(BuildContext context) {
    return Mfm(
      mfmText: text,
      style: style,
      maxLines: maxLines,
      overflow: overflow,
      emojiBuilder: (context, emojiName, emojiStyle) {
        final url = emojis[emojiName];
        if (url == null) {
          return Text(':$emojiName:', style: emojiStyle);
        }
        final fontSize = emojiStyle?.fontSize ?? 14.0;
        return CachedNetworkImage(
          imageUrl: url,
          height: fontSize * 1.8,
          errorWidget: (context, url, error) =>
              Text(':$emojiName:', style: emojiStyle),
        );
      },
    );
  }
}
