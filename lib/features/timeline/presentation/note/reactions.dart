import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mischie/core/image/image_cache_managers.dart';
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
        // フルキー (name@server.tld) でまず検索し、なければ短縮名 (name) で検索
        var emojiUrl = emojis[identifier];
        if (emojiUrl == null) {
          final atIndex = identifier.indexOf('@');
          if (atIndex > 0) {
            emojiUrl = emojis[identifier.substring(0, atIndex)];
          }
        }
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
    required this.emojiUrl,
    required this.fallbackLabel,
    required this.onTap,
  });

  final int count;
  final bool isMine;
  final bool isRemote;
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

  @override
  Widget build(BuildContext context) {
    final emojiUrl = widget.emojiUrl;

    return ScaleTransition(
      scale: _pop,
      child: FilterChip(
        // 画像が無いとき（Unicode 絵文字や読み込み失敗）はラベル側に出す。
        // avatar は小さな正方形なので、文字を入れると切り詰められる。
        avatar: emojiUrl == null
            ? null
            : CachedNetworkImage(
                imageUrl: emojiUrl,
                cacheManager: EmojiCacheManager.instance,
                height: 18,
                // 幅を予約しないと、読み込み前は 0 幅で描かれてから
                // 画像の到着で広がり、ノート全体がずれる
                placeholder: (_, _) => const SizedBox(height: 18, width: 18),
                errorWidget: (_, _, _) => Text(widget.fallbackLabel),
              ),
        label: Text(
          emojiUrl == null
              ? '${widget.fallbackLabel} ${widget.count}'
              : '${widget.count}',
        ),
        selected: widget.isMine,
        showCheckmark: false,
        visualDensity: VisualDensity.compact,
        labelPadding: const EdgeInsets.only(left: 4, right: 2),
        onSelected: (_) => _handleTap(),
      ),
    );
  }
}
