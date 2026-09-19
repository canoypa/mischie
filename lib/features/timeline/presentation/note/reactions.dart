import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mischie/core/widgets/custom_emoji_image.dart';
import 'package:mischie/features/timeline/domain/note.dart';

/// `:name:` / `:name@server.tld:` 形式のリアクションキー。
/// リアクションごとに組み直すと、その回数だけ正規表現の構築コストがかかる。
final customEmojiPattern = RegExp(r'^:([^:]+):$');

/// 他サーバーの絵文字によるリアクションか。自サーバーへは付け直せない。
///
/// Misskey はリアクションのキーにホストを付ける。ローカルの絵文字は
/// `name@.` の形（`.` がローカルホストを指す）で返るため、`@` の有無だけで
/// 判定するとローカルの絵文字まで「押せない」ことになる。
bool isRemoteReaction(String identifier) {
  final atIndex = identifier.indexOf('@');
  if (atIndex < 0) return false;
  final host = identifier.substring(atIndex + 1);
  return host.isNotEmpty && host != '.';
}

/// 絵文字の URL を引く。フルキー (name@server.tld) でまず検索し、
/// なければホストを落とした短縮名 (name) で引き直す。
String? lookupEmojiUrl(Map<String, String> emojis, String identifier) {
  final url = emojis[identifier];
  if (url != null) return url;
  final atIndex = identifier.indexOf('@');
  if (atIndex <= 0) return null;
  return emojis[identifier.substring(0, atIndex)];
}

class NoteReactions extends StatelessWidget {
  const NoteReactions({
    super.key,
    required this.note,
    required this.emojis,
    required this.onTap,
  });

  final Note note;
  final Map<String, String> emojis;
  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) {
    final sorted = note.reactions.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Wrap(
      // 隣のリアクションを押してしまわないよう、間隔は 8 取る。
      // 高さは Material 3 のチップに合わせて詰めたままにする。
      spacing: 8,
      runSpacing: 8,
      children: sorted.map((e) {
        // `:name:` または `:name@server.tld:` 形式からキーを抽出
        final match = customEmojiPattern.firstMatch(e.key);
        final identifier = match?.group(1) ?? e.key;
        final emojiUrl = lookupEmojiUrl(emojis, identifier);
        final atIndex = identifier.indexOf('@');
        final displayName = atIndex > 0
            ? identifier.substring(0, atIndex)
            : identifier;
        // match != null → カスタム絵文字 (:name:)、null → Unicode 絵文字
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
        );
      }).toList(),
    );
  }
}

/// リアクション 1 つぶん。
///
/// 箱を自前で描くと InkWell の上に不透明な面が乗り、Material 3 の状態
/// レイヤー（ホバー・押下・フォーカス）が見えなくなる。標準のチップに
/// 任せることで、状態表現も 48dp のタップ領域も付いてくる。
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
  });

  final int count;
  final bool isMine;
  final bool isRemote;
  final bool isCustomEmoji;
  final String? emojiUrl;
  final String fallbackLabel;
  final VoidCallback onTap;

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
    // 押した手応えを返す。見た目の変化はサーバー応答を待たない。
    HapticFeedback.selectionClick();
    _controller.forward(from: 0);
    widget.onTap();
  }

  // Misskey Web と同じく、絵文字は 1.5em (≈24px) 相当の高さで出す。幅は
  // 縦横比まかせ（横に長い絵文字を正方形へ押し込むと潰れる）で、代わりに
  // 70px 前後で上限を切る。
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

    // avatar 枠は正方形固定で、横に長い絵文字を入れると潰れる。ラベル側に
    // 絵文字とカウントを並べて置き、実際の縦横比のまま出す。
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
                // カスタム絵文字名の ":name:" 表記は本文サイズのまま。
                // Unicode 絵文字だけ Misskey Web と揃えて大きく出す。
                style: widget.isCustomEmoji ? null : _unicodeStyle,
              ),
              const SizedBox(width: 4),
              Text('${widget.count}', style: _countStyle),
            ],
          );

    return ScaleTransition(
      scale: _pop,
      child: FilterChip(
        label: label,
        selected: widget.isMine,
        showCheckmark: false,
        visualDensity: VisualDensity.compact,
        labelPadding: const EdgeInsets.symmetric(horizontal: 6),
        onSelected: (_) => _handleTap(),
      ),
    );
  }
}
