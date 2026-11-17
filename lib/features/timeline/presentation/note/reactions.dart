import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mischie/core/widgets/custom_emoji_image.dart';
import 'package:mischie/features/timeline/domain/note.dart';

/// カスタム絵文字のリアクション（`:name:` / `:name@host:`）。
final customEmojiPattern = RegExp(r'^:([^:]+):$');

/// 他サーバーの絵文字か（自サーバーからは付けられない）。ローカルも `name@.` の形で来るので、`@` の有無だけでは判定できない。
bool isRemoteReaction(String identifier) {
  final atIndex = identifier.indexOf('@');
  if (atIndex < 0) return false;
  final host = identifier.substring(atIndex + 1);
  return host.isNotEmpty && host != '.';
}

String? lookupEmojiUrl(Map<String, String> emojis, String identifier) {
  final url = emojis[identifier];
  if (url != null) return url;
  final atIndex = identifier.indexOf('@');
  if (atIndex <= 0) return null;
  return emojis[identifier.substring(0, atIndex)];
}

class ReactionGlyph extends StatelessWidget {
  const ReactionGlyph({
    super.key,
    required this.reaction,
    required this.emojis,
    this.size = 24,
  });

  final String reaction;
  final Map<String, String> emojis;
  final double size;

  @override
  Widget build(BuildContext context) {
    final match = customEmojiPattern.firstMatch(reaction);
    if (match == null) {
      return Text(reaction, style: TextStyle(fontSize: size * 0.875));
    }
    final identifier = match.group(1)!;
    final atIndex = identifier.indexOf('@');
    final name = atIndex > 0 ? identifier.substring(0, atIndex) : identifier;
    final url = lookupEmojiUrl(emojis, identifier);
    if (url == null) return Text(':$name:');
    return CustomEmojiImage(
      url: url,
      size: size,
      maxWidth: size * 3,
      errorFallback: Text(':$name:'),
    );
  }
}

class NoteReactions extends StatelessWidget {
  const NoteReactions({
    super.key,
    required this.note,
    required this.emojis,
    required this.onTap,
    this.onLongPress,
  });

  final Note note;
  final Map<String, String> emojis;
  final ValueChanged<String> onTap;

  final ValueChanged<String>? onLongPress;

  @override
  Widget build(BuildContext context) {
    final sorted = note.reactions.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Wrap(
      // 押し間違いを防ぐため、間隔は 8 取る。
      spacing: 8,
      runSpacing: 8,
      children: sorted.map((e) {
        final match = customEmojiPattern.firstMatch(e.key);
        final identifier = match?.group(1) ?? e.key;
        final emojiUrl = lookupEmojiUrl(emojis, identifier);
        final atIndex = identifier.indexOf('@');
        final displayName = atIndex > 0
            ? identifier.substring(0, atIndex)
            : identifier;
        final isCustomEmoji = match != null;
        final isExternal = isRemoteReaction(identifier);

        return _ReactionChip(
          key: ValueKey(e.key),
          count: e.value,
          isMine: note.myReaction == e.key,
          isRemote: isExternal,
          isCustomEmoji: isCustomEmoji,
          emojiUrl: emojiUrl,
          fallbackLabel: isCustomEmoji ? ':$displayName:' : displayName,
          onTap: () => onTap(e.key),
          onLongPress: onLongPress == null ? null : () => onLongPress!(e.key),
        );
      }).toList(),
    );
  }
}

/// 自前の箱にすると押下などの状態表示が隠れるので、標準のチップを使う。
class _ReactionChip extends StatefulWidget {
  const _ReactionChip({
    super.key,
    required this.count,
    required this.isMine,
    required this.isRemote,
    required this.isCustomEmoji,
    required this.emojiUrl,
    required this.fallbackLabel,
    required this.onTap,
    this.onLongPress,
  });

  final int count;
  final bool isMine;
  final bool isRemote;
  final bool isCustomEmoji;
  final String? emojiUrl;
  final String fallbackLabel;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  @override
  State<_ReactionChip> createState() => _ReactionChipState();
}

class _ReactionChipState extends State<_ReactionChip>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 260),
  );

  late final Animation<double> _pop = TweenSequence<double>([
    TweenSequenceItem(tween: Tween(begin: 1, end: 1.22), weight: 1),
    TweenSequenceItem(tween: Tween(begin: 1.22, end: 1), weight: 2),
  ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

  @override
  void didUpdateWidget(_ReactionChip oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 増えた瞬間に跳ねる。数字が差し替わるだけだと気づけない。
    if (widget.count > oldWidget.count) _controller.forward(from: 0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    if (widget.isRemote) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('リモートサーバーの絵文字にはリアクションできません')),
      );
      return;
    }
    HapticFeedback.selectionClick();
    _controller.forward(from: 0);
    widget.onTap();
  }

  // 横長の絵文字が潰れないよう、幅は縦横比のまま出して上限だけ切る。
  static const _emojiSize = 24.0;
  static const _emojiMaxWidth = 72.0;
  static const _unicodeStyle = TextStyle(fontSize: 21);
  static const _countStyle = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w600,
  );

  @override
  Widget build(BuildContext context) {
    final emojiUrl = widget.emojiUrl;

    // avatar に入れると正方形に潰れるので、ラベルに並べる。
    final Widget label = emojiUrl != null
        ? Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomEmojiImage(
                url: emojiUrl,
                size: _emojiSize,
                maxWidth: _emojiMaxWidth,
                errorFallback: Text(widget.fallbackLabel),
              ),
              const SizedBox(width: 6),
              Text('${widget.count}', style: _countStyle),
            ],
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.fallbackLabel,
                // Unicode 絵文字だけ、画像の絵文字と大きさを揃える。
                style: widget.isCustomEmoji ? null : _unicodeStyle,
              ),
              const SizedBox(width: 4),
              Text('${widget.count}', style: _countStyle),
            ],
          );

    return GestureDetector(
      onLongPress: widget.onLongPress,
      child: ScaleTransition(
        scale: _pop,
        child: FilterChip(
          label: label,
          selected: widget.isMine,
          showCheckmark: false,
          visualDensity: VisualDensity.compact,
          labelPadding: const EdgeInsets.symmetric(horizontal: 6),
          onSelected: (_) => _handleTap(),
        ),
      ),
    );
  }
}
