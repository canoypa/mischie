import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mfm/mfm.dart';
import 'package:mfm_parser/mfm_parser.dart';
import 'package:mischie/core/navigation/link_handler.dart';

class MfmText extends ConsumerStatefulWidget {
  const MfmText(this.text, {super.key, this.emojis = const {}, this.style});

  final String text;
  final Map<String, String> emojis;
  final TextStyle? style;

  @override
  ConsumerState<MfmText> createState() => _MfmTextState();
}

class _MfmTextState extends ConsumerState<MfmText> {
  late EmojiBuilder _emojiBuilder;
  late LinkTapCallback _linkTap;
  late HashtagCallback _hashtagTap;
  late MentionTapCallBack _mentionTap;
  late List<MfmNode> _parsed;

  @override
  void initState() {
    super.initState();
    _parsed = const MfmParser().parse(widget.text);
    _linkTap = (url) => openLink(context, ref, url);
    // タグ別タイムラインは未実装なので Web に流す
    _hashtagTap = (tag) => openOnServer(ref, '/tags/$tag');
    _mentionTap = (userName, host, acct) =>
        openUserByAcct(context, ref, username: userName, host: host);
    _emojiBuilder = _buildEmojiBuilder(widget.emojis);
  }

  @override
  void didUpdateWidget(MfmText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text) {
      _parsed = const MfmParser().parse(widget.text);
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
        fit: BoxFit.contain,
        placeholder: (_, _) =>
            SizedBox(height: fontSize * 1.8, width: fontSize * 1.8),
        errorWidget: (context, url, error) =>
            Text(':$emojiName:', style: emojiStyle),
      );
    };
  }

  @override
  Widget build(BuildContext context) {
    final linkColor = Theme.of(context).colorScheme.primary;
    return Mfm(
      mfmNode: _parsed,
      style: widget.style,
      isUseAnimation: false,
      linkStyle: TextStyle(
        color: linkColor,
        decoration: TextDecoration.underline,
      ),
      hashtagStyle: TextStyle(color: linkColor),
      mentionStyle: TextStyle(color: linkColor),
      emojiBuilder: _emojiBuilder,
      linkTap: _linkTap,
      hashtagTap: _hashtagTap,
      mentionTap: _mentionTap,
    );
  }
}
