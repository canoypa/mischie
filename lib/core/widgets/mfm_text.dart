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
  });

  final String text;
  final Map<String, String> emojis;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return SimpleMfm(
      text,
      style: style,
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
