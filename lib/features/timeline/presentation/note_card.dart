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
import 'package:mischie/features/timeline/domain/word_mute.dart';
import 'package:mischie/features/timeline/presentation/note/actions_row.dart';
import 'package:mischie/features/timeline/presentation/note/media.dart';
import 'package:mischie/features/timeline/presentation/note/note_style.dart';
import 'package:mischie/features/timeline/presentation/note/quote.dart';
import 'package:mischie/features/timeline/presentation/note/reactions.dart';
import 'package:mischie/features/timeline/presentation/note_detail_screen.dart';
import 'package:mischie/features/timeline/presentation/poll_view.dart';
import 'package:mischie/features/timeline/presentation/reaction_picker.dart';
import 'package:mischie/features/timeline/presentation/reaction_users_sheet.dart';
import 'package:timeago/timeago.dart' as timeago;

class NoteCard extends ConsumerStatefulWidget {
  const NoteCard({
    super.key,
    required this.note,
    required this.serverEmojis,
    this.onTap,
    this.showReplyTarget = true,
  });

  final Note note;

  /// 返信先を 1 行で添える。スレッドとして親を並べて出す画面では切る。
  final bool showReplyTarget;

  /// カードごとに watch させず、一覧の側で 1 回だけ watch して渡す。
  final Map<String, String> serverEmojis;

  /// null ならノート詳細を開く。
  final VoidCallback? onTap;

  @override
  ConsumerState<NoteCard> createState() => _NoteCardState();
}

// keep alive しない。残すとスクロールするほど重くなる。
class _NoteCardState extends ConsumerState<NoteCard> {
  bool _cwExpanded = false;

  bool _muteRevealed = false;

  /// 表示中だけ更新を購読する。keep alive しないことに頼っている。
  late final String _capturedNoteId;

  /// dispose では ref を使えないので、initState で取っておく。
  late final NoteCapture _capture;

  // 毎回作り直すと MfmText の再構築の抑制が効かないので、使い回す。
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

  /// サーバーの絵文字表はコピーせず重ねて引く。絵文字の多いサーバーでは、ノートごとに大きなコピーができる。
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

    final myId = ref.watch(
      profileNotifierProvider.select((me) => me.value?.id),
    );
    final isWordMuted =
        !_muteRevealed &&
        displayNote.user.id != myId &&
        ref.watch(wordMuteProvider).matches(displayNote);
    if (isWordMuted) {
      return _WordMutedNote(
        user: displayNote.user,
        onReveal: () => setState(() => _muteRevealed = true),
      );
    }
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
      // InkWell で包むとスクロールが重くなるので、GestureDetector を使う。
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap ?? () => openNoteDetail(context, displayNote),
        child: Padding(
          // 下はアクション行のタップ領域が余白を兼ねるので詰める。
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
              if (widget.showReplyTarget && displayNote.reply != null)
                _ReplyTarget(reply: displayNote.reply!, emojis: emojis),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () => _openProfile(displayNote.user),
                    child: Semantics(
                      button: true,
                      label: '${displayNote.user.acct} のプロフィール',
                      child: DecoratedAvatar(
                        avatarUrl: displayNote.user.avatarUrl,
                        size: 48,
                        isCat: displayNote.user.isCat,
                        avatarBlurhash: displayNote.user.avatarBlurhash,
                        decorations: displayNote.user.avatarDecorations,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
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
                                    host: displayNote.user.host,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                ActionChip(
                                  label: Text(_cwExpanded ? '隠す' : '続きを見る'),
                                  padding: EdgeInsets.zero,
                                  visualDensity: VisualDensity.compact,
                                  onPressed: () => setState(
                                    () => _cwExpanded = !_cwExpanded,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        if (!hasCw || _cwExpanded) ...[
                          if (displayNote.text != null)
                            // 添付はここに含めない。画像だけで高さを超えると、短い本文まで畳まれる。
                            CollapsibleContent(
                              child: MfmText(
                                displayNote.text!,
                                emojis: emojis,
                                host: displayNote.user.host,
                              ),
                            ),
                          if (displayNote.files.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            NoteMediaGrid(files: displayNote.files),
                          ],
                        ],
                        if ((!hasCw || _cwExpanded) &&
                            displayNote.poll != null) ...[
                          const SizedBox(height: 8),
                          PollView(note: displayNote, poll: displayNote.poll!),
                        ],
                        // 外側のノートで判定すると、引用をリノートしたときに引用元が消える。
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
                            onLongPress: (reaction) => showReactionUsers(
                              context,
                              noteId: displayNote.id,
                              reaction: reaction,
                              title: ReactionGlyph(
                                reaction: reaction,
                                emojis: emojis,
                                size: 32,
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(height: 4),
                        NoteActionsRow(
                          note: displayNote,
                          renoteItem: isRenote ? note : null,
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

    // 通知一覧と揃えて、横並びの 1 行に収める。
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

class _ReplyTarget extends StatelessWidget {
  const _ReplyTarget({required this.reply, required this.emojis});

  final Note reply;
  final Map<String, String> emojis;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.bodySmall?.copyWith(
      color: Theme.of(context).colorScheme.onSurfaceVariant,
    );
    final summary = reply.cw ?? reply.text ?? '';
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => openNoteDetail(context, reply),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Row(
          children: [
            Icon(Icons.reply, size: 14, color: style?.color),
            const SizedBox(width: 4),
            Flexible(
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(text: '${reply.user.acct} への返信'),
                    if (summary.isNotEmpty) TextSpan(text: '  $summary'),
                  ],
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: style,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WordMutedNote extends StatelessWidget {
  const _WordMutedNote({required this.user, required this.onReveal});

  final User user;
  final VoidCallback onReveal;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: InkWell(
        onTap: onReveal,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Text(
            '${user.acct} のノート（ミュートワード）',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}
