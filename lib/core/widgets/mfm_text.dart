import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:mfm/mfm.dart';
import 'package:url_launcher/url_launcher.dart';

/// MFM (Misskey Flavored Markdown) テキストを描画するウィジェット。
///
/// [emojis] にノートが持つカスタム絵文字マップ (shortcode → URL) を渡すと
/// `:emoji_name:` を画像として描画する。
/// リンク・URL・ハッシュタグ・メンションはタップ可能なリンクとして描画する。
class MfmText extends StatefulWidget {
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
  State<MfmText> createState() => _MfmTextState();
}

class _MfmTextState extends State<MfmText> {
  late EmojiBuilder _emojiBuilder;
  late LinkTapCallback _linkTap;
  late HashtagCallback _hashtagTap;
  late MentionTapCallBack _mentionTap;

  @override
  void initState() {
    super.initState();
    _linkTap = _launch;
    _hashtagTap = (tag) => _launch('https://misskey.io/tags/$tag');
    _mentionTap = (userName, host, acct) {
      final base = host ?? 'misskey.io';
      _launch('https://$base/@$userName');
    };
    _emojiBuilder = _buildEmojiBuilder(widget.emojis);
  }

  @override
  void didUpdateWidget(MfmText oldWidget) {
    super.didUpdateWidget(oldWidget);
    // emojis の参照が変わったときのみクロージャを再生成する。
    // 参照が同じなら Mfm.updateShouldNotify が false になり MFM の再パースを省略できる。
    if (!identical(oldWidget.emojis, widget.emojis)) {
      _emojiBuilder = _buildEmojiBuilder(widget.emojis);
    }
  }

  EmojiBuilder _buildEmojiBuilder(Map<String, String> emojis) {
    return (context, emojiName, emojiStyle) {
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
    };
  }

  Future<void> _launch(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final linkColor = Theme.of(context).colorScheme.primary;

    return Mfm(
      mfmText: widget.text,
      style: widget.style,
      isUseAnimation: false,
      linkStyle: TextStyle(color: linkColor, decoration: TextDecoration.underline),
      hashtagStyle: TextStyle(color: linkColor),
      emojiBuilder: _emojiBuilder,
      linkTap: _linkTap,
      hashtagTap: _hashtagTap,
      mentionTap: _mentionTap,
    );
  }
}
