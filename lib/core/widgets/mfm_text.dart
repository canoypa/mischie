import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:mischie/core/image/image_cache_managers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mfm/mfm.dart';
import 'package:mfm_parser/mfm_parser.dart';
import 'package:mischie/core/navigation/link_handler.dart';

class MfmText extends ConsumerStatefulWidget {
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

  /// 名前のように 1 行に収めたい場所で使う。
  final int? maxLines;
  final TextOverflow? overflow;

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
      // 文字より一回り大きい程度に収める。1.8 倍では絵文字が主役になり、
      // 名前や本文が読み取りにくくなる。
      final fontSize = (emojiStyle?.fontSize ?? 14.0) * 1.25;
      return CachedNetworkImage(
        imageUrl: url,
        cacheManager: EmojiCacheManager.instance,
        height: fontSize,
        fit: BoxFit.contain,
        placeholder: (_, _) => SizedBox(height: fontSize, width: fontSize),
        errorWidget: (context, url, error) =>
            Text(':$emojiName:', style: emojiStyle),
      );
    };
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final linkColor = colorScheme.primary;
    return Mfm(
      mfmNode: _parsed,
      style: widget.style,
      maxLines: widget.maxLines,
      overflow: widget.overflow,
      isUseAnimation: false,
      linkStyle: TextStyle(
        color: linkColor,
        decoration: TextDecoration.underline,
      ),
      hashtagStyle: TextStyle(color: linkColor),
      // 本来はアイコン画像付きのバッジにしたいが、mfm パッケージは
      // メンションを素の TextSpan で描くのでウィジェットを差し込めない。
      // 背景色で「押せる名前」だと分かる程度までに留める。
      mentionStyle: TextStyle(
        color: colorScheme.onPrimaryContainer,
        backgroundColor: colorScheme.primaryContainer,
        fontWeight: FontWeight.w600,
      ),
      emojiBuilder: _emojiBuilder,
      linkTap: _linkTap,
      hashtagTap: _hashtagTap,
      mentionTap: _mentionTap,
    );
  }
}
