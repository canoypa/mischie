import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mischie/core/emoji/layered_emojis.dart';
import 'package:mischie/core/error/error_handler.dart';
import 'package:mischie/core/widgets/collapsible_content.dart';
import 'package:mischie/core/widgets/decorated_avatar.dart';
import 'package:mischie/core/widgets/mfm_text.dart';
import 'package:mischie/features/profile/domain/profile_notifier.dart';
import 'package:mischie/features/profile/presentation/user_profile_screen.dart';
import 'package:mischie/features/timeline/domain/note.dart';
import 'package:mischie/features/timeline/domain/note_actions.dart';
import 'package:mischie/features/timeline/domain/note_capture.dart';
import 'package:mischie/features/timeline/domain/note_store.dart';
import 'package:mischie/features/timeline/domain/user.dart';
import 'package:mischie/features/timeline/presentation/note/actions_row.dart';
import 'package:mischie/features/timeline/presentation/note/media.dart';
import 'package:mischie/features/timeline/presentation/note/note_style.dart';
import 'package:mischie/features/timeline/presentation/note/quote.dart';
import 'package:mischie/features/timeline/presentation/note/reactions.dart';
import 'package:mischie/features/timeline/presentation/note_detail_screen.dart';
import 'package:mischie/features/timeline/presentation/poll_view.dart';
import 'package:mischie/features/timeline/presentation/reaction_picker.dart';
import 'package:timeago/timeago.dart' as timeago;

class NoteCard extends ConsumerStatefulWidget {
  const NoteCard({
    super.key,
    required this.note,
    required this.serverEmojis,
    this.onTap,
  });

  final Note note;

  /// サーバー全体の絵文字キャッシュ。TimelineScreen で1回だけ watch して渡す。
  final Map<String, String> serverEmojis;

  /// タップ時の遷移。既定ではノート詳細を開く。
  final VoidCallback? onTap;

  @override
  ConsumerState<NoteCard> createState() => _NoteCardState();
}

// 通り過ぎたカードを keep alive しない。生かし続けると、スクロールした
// ぶんだけウィジェットと画像が残り続け、進むほど重くなる。
class _NoteCardState extends ConsumerState<NoteCard> {
  bool _cwExpanded = false;

  /// 画面に出ている間だけノートの更新を購読する。keep alive していないので、
  /// カードの寿命がそのまま「表示中かどうか」になる。
  late final String _capturedNoteId;

  /// dispose の時点では ref を触れない（BuildContext が無効になっている）ので、
  /// 購読の解除に使うものは initState で捕まえておく。
  late final NoteCapture _capture;

  // 重ねた結果の LayeredEmojis 自体をキャッシュする。ここで毎回新しい
  // インスタンスを返すと、MfmText の identical(oldEmojis, newEmojis) による
  // 再構築の抑制が効かなくなる。
  Note? _lastNote;
  Map<String, String>? _lastServerEmojis;
  LayeredEmojis _emojis = const LayeredEmojis(base: {}, overlay: {});

  @override
  void initState() {
    super.initState();
    final note = widget.note;
    _capturedNoteId = (note.isPureRenote ? note.renote! : note).id;
    _capture = ref.read(noteCaptureProvider)
      ..capture(note.isPureRenote ? note.renote! : note);
  }

  @override
  void dispose() {
    _capture.release(_capturedNoteId);
    super.dispose();
  }

  void _openProfile(User user) {
    openUserProfile(context, user.id, initialUser: user);
  }

  /// サーバー全体の絵文字は共有のまま重ねて引く。ここで
  /// `{...serverEmojis, ...}` と書くと、カスタム絵文字が数千〜1 万件ある
  /// サーバーではノート 1 件ごとにその規模のコピーができてしまう。
  LayeredEmojis _mergeEmojis(Note displayNote) {
    if (!identical(_lastNote, displayNote) ||
        !identical(_lastServerEmojis, widget.serverEmojis)) {
      _lastNote = displayNote;
      _lastServerEmojis = widget.serverEmojis;
      final noteEmojis =
          displayNote.emojis.isEmpty && displayNote.reactionEmojis.isEmpty
          ? const <String, String>{}
          : {...displayNote.emojis, ...displayNote.reactionEmojis};
      _emojis = LayeredEmojis(base: widget.serverEmojis, overlay: noteEmojis);
    }
    return _emojis;
  }

  @override
  Widget build(BuildContext context) {
    final note = resolveNote(ref, widget.note);
    final displayNote = note.isPureRenote ? note.renote! : note;
    final isRenote = note.isPureRenote;

    final isDeleted = ref.watch(
      deletedNoteIdsProvider.select(
        (ids) => ids.contains(note.id) || ids.contains(displayNote.id),
      ),
    );
    if (isDeleted) return const SizedBox.shrink();

    // ミュート／ブロックした相手のノートは、次の取得を待たずその場で消す
    final isHidden = ref.watch(
      hiddenUserIdsProvider.select(
        (ids) =>
            ids.contains(note.user.id) || ids.contains(displayNote.user.id),
      ),
    );
    if (isHidden) return const SizedBox.shrink();
    final hasCw = displayNote.cw != null;

    final emojis = _mergeEmojis(displayNote);

    final channel = displayNote.channel;
    final channelColor = parseChannelColor(channel?.color);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      shape: channelColor == null
          ? null
          : RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: channelColor, width: 3),
            ),
      // カード全体を InkWell で包むと、カードごとに ink レイヤーと
      // クリップ用の saveLayer が増えてスクロールが重くなる。
      // タップ判定だけ取れれば足りるので GestureDetector を使う。
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap ?? () => openNoteDetail(context, displayNote),
        child: Padding(
          // 下だけ詰める。アクション行が 48dp のタップ領域を持つので、
          // ここでも 12 取ると余白が二重になって間延びする。
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 2),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isRenote)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: [
                      Flexible(
                        child: MfmText(
                          note.user.name ?? note.user.username,
                          emojis: emojis,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                        ),
                      ),
                      Text(
                        ' がリノート',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                    ],
                  ),
                ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () => _openProfile(displayNote.user),
                    child: DecoratedAvatar(
                      avatarUrl: displayNote.user.avatarUrl,
                      isCat: displayNote.user.isCat,
                      avatarBlurhash: displayNote.user.avatarBlurhash,
                      decorations: displayNote.user.avatarDecorations,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () => _openProfile(displayNote.user),
                                behavior: HitTestBehavior.opaque,
                                child: _UserName(
                                  user: displayNote.user,
                                  emojis: emojis,
                                ),
                              ),
                            ),
                            if (visibilityIcon(displayNote.visibility)
                                case final icon?) ...[
                              Icon(
                                icon,
                                size: 13,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                              const SizedBox(width: 4),
                            ],
                            Text(
                              timeago.format(
                                DateTime.parse(displayNote.createdAt),
                                locale: 'ja',
                              ),
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        if (hasCw) ...[
                          GestureDetector(
                            onTap: () =>
                                setState(() => _cwExpanded = !_cwExpanded),
                            child: Row(
                              children: [
                                Expanded(
                                  child: MfmText(
                                    displayNote.cw!,
                                    emojis: emojis,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Chip(
                                  label: Text(_cwExpanded ? '隠す' : '続きを見る'),
                                  padding: EdgeInsets.zero,
                                  visualDensity: VisualDensity.compact,
                                ),
                              ],
                            ),
                          ),
                        ],
                        if (!hasCw || _cwExpanded)
                          // 長いノートは文字数ではなく描画後の高さで畳む。
                          // 文字で切ると MFM の途中で切れて表現が壊れるため。
                          CollapsibleContent(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (displayNote.text != null)
                                  MfmText(displayNote.text!, emojis: emojis),
                                if (displayNote.files.isNotEmpty) ...[
                                  const SizedBox(height: 8),
                                  NoteMediaGrid(files: displayNote.files),
                                ],
                              ],
                            ),
                          ),
                        if ((!hasCw || _cwExpanded) &&
                            displayNote.poll != null) ...[
                          const SizedBox(height: 8),
                          PollView(note: displayNote, poll: displayNote.poll!),
                        ],
                        // 引用リノート: 埋め込みも CW で隠す対象に含める。
                        // 判定は表示しているノートで行う。外側で見ると、
                        // 引用ノートをリノートしたときに引用元が消える。
                        if ((!hasCw || _cwExpanded) &&
                            !displayNote.isPureRenote &&
                            displayNote.renote != null) ...[
                          const SizedBox(height: 8),
                          QuotedNote(
                            note: displayNote.renote!,
                            serverEmojis: widget.serverEmojis,
                          ),
                        ],
                        if (channel != null) ...[
                          const SizedBox(height: 6),
                          ChannelBadge(channel: channel, color: channelColor),
                        ],
                        if (displayNote.reactions.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          NoteReactions(
                            note: displayNote,
                            emojis: emojis,
                            onTap: (reaction) => _react(displayNote, reaction),
                          ),
                        ],
                        const SizedBox(height: 4),
                        NoteActionsRow(
                          note: displayNote,
                          onReact: () => _pickReaction(displayNote),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickReaction(Note note) async {
    final reaction = await showReactionPicker(context);
    if (reaction == null) return;
    await _react(note, reaction);
  }

  Future<void> _react(Note note, String reaction) async {
    try {
      await ref.read(noteActionsProvider).toggleReaction(note, reaction);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(resolveErrorMessage(e))));
    }
  }
}

class _UserName extends StatelessWidget {
  const _UserName({required this.user, required this.emojis});

  final User user;
  final Map<String, String> emojis;

  @override
  Widget build(BuildContext context) {
    final displayName = user.name ?? user.username;
    final handle = user.acct;

    // 通知一覧と揃えて横並びにする。縦積みだと同じ情報が画面ごとに
    // 違う形で出てしまう。幅を超えたら名前側を省略する（折り返すと
    // カードの高さが揃わず、一覧が読みにくくなる）。
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Flexible(
          child: MfmText(
            displayName,
            emojis: emojis,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            handle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}
