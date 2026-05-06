import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:mfm/mfm.dart';
import 'package:mfm_parser/mfm_parser.dart';
import 'package:url_launcher/url_launcher.dart';

// ハッシュタグ・メンション・URL・装飾等インタラクティブ要素を検出するパターン。
// 該当しない場合は軽量の SimpleMfm を使用する。
final _fullMfmRe = RegExp(
  r'#\S|@\S|https?://|\*{2}|~~|\$\[|`|^> |\[|<\w',
  multiLine: true,
);

/// MFM (Misskey Flavored Markdown) テキストを描画するウィジェット。
///
/// インタラクティブ要素を含む場合はフル MFM レンダラー、
/// 含まない場合は軽量の SimpleMfm を使用する。
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
  List<MfmNode>? _fullParsed;
  List<MfmNode>? _simpleParsed;

  void _parse(String text) {
    if (_fullMfmRe.hasMatch(text)) {
      _fullParsed = const MfmParser().parse(text);
      _simpleParsed = null;
    } else {
      _simpleParsed = const MfmParser().parseSimple(text);
      _fullParsed = null;
    }
  }

  @override
  void initState() {
    super.initState();
    _parse(widget.text);
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
    if (oldWidget.text != widget.text) {
      _parse(widget.text);
    }
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
    // シンプルテキスト＋絵文字のみの場合は SimpleMfm（軽量）
    if (_simpleParsed != null) {
      return SimpleMfm(
        widget.text,
        style: widget.style,
        emojiBuilder: _emojiBuilder,
      );
    }

    // リンク・ハッシュタグ等ありの場合はフル Mfm
    final linkColor = Theme.of(context).colorScheme.primary;
    return Mfm(
      mfmNode: _fullParsed,
      style: widget.style,
      isUseAnimation: false,
      linkStyle: TextStyle(
          color: linkColor, decoration: TextDecoration.underline),
      hashtagStyle: TextStyle(color: linkColor),
      emojiBuilder: _emojiBuilder,
      linkTap: _linkTap,
      hashtagTap: _hashtagTap,
      mentionTap: _mentionTap,
    );
  }
}
