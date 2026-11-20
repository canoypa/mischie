import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mfm/mfm.dart';
import 'package:mfm_parser/mfm_parser.dart';
import 'package:mischie/core/navigation/link_handler.dart';
import 'package:mischie/core/widgets/custom_emoji_image.dart';
import 'package:mischie/features/search/presentation/hashtag_screen.dart';

class MfmText extends ConsumerStatefulWidget {
  const MfmText(
    this.text, {
    super.key,
    this.emojis = const {},
    this.style,
    this.maxLines,
    this.overflow,
    this.host,
  });

  final String text;
  final Map<String, String> emojis;
  final TextStyle? style;

  /// 本文を書いた人のサーバー（ローカルなら null）。ホストの無い `@name` は
  /// そのサーバーのユーザーを指すので、ログイン中のサーバーと取り違えない。
  final String? host;

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
    _hashtagTap = (tag) => openHashtag(context, tag);
    _mentionTap = (userName, host, acct) => openUserByAcct(
      context,
      ref,
      username: userName,
      host: host ?? widget.host,
    );
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
      // これ以上大きくすると、名前や本文が読み取りにくくなる。
      final fontSize = (emojiStyle?.fontSize ?? 14.0) * 1.25;
      return CustomEmojiImage(
        url: url,
        size: fontSize,
        fit: BoxFit.contain,
        errorFallback: Text(':$emojiName:', style: emojiStyle),
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
      // メンションにはウィジェットを差し込めないため、背景色で押せることを示す。
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
