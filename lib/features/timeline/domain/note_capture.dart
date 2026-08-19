import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mischie/core/streaming/streaming_service.dart';
import 'package:mischie/features/profile/domain/profile_notifier.dart';
import 'package:mischie/features/timeline/domain/note.dart';
import 'package:mischie/features/timeline/domain/note_store.dart';
import 'package:mischie/features/timeline/domain/timeline_notifier.dart';

/// 表示中のノートを個別購読して、他の人のリアクションを届いた時点で反映する。
///
/// 購読するのは画面に出ているノートだけ。タイムライン全体を購読すると、
/// 読み進めるほど購読が積み上がってサーバーにも端末にも無駄がかかる。
final noteCaptureProvider = Provider<NoteCapture>(NoteCapture.new);

class NoteCapture {
  NoteCapture(this._ref);

  final Ref _ref;

  /// 同じノートが複数の画面に出ることがあるので、参照数で管理する。
  final Map<String, int> _refCounts = {};

  /// 更新を当てる元。上書きが無いノートは元の値が必要になる。
  final Map<String, Note> _known = {};

  StreamingService? get _streaming =>
      _ref.read(timelineNotifierProvider.notifier).streaming;

  void capture(Note note) {
    _known[note.id] = note;
    final count = (_refCounts[note.id] ?? 0) + 1;
    _refCounts[note.id] = count;
    if (count == 1) _streaming?.captureNote(note.id);
  }

  void release(String noteId) {
    final count = (_refCounts[noteId] ?? 0) - 1;
    if (count > 0) {
      _refCounts[noteId] = count;
      return;
    }
    _refCounts.remove(noteId);
    _known.remove(noteId);
    _streaming?.uncaptureNote(noteId);
  }

  Note? baseOf(String noteId) =>
      _ref.read(noteOverridesProvider)[noteId] ?? _known[noteId];
}

/// `noteUpdated` を上書きストアへ反映する。
void applyNoteUpdate(Ref ref, Map<String, dynamic> event) {
  final noteId = event['id'] as String?;
  final type = event['type'] as String?;
  if (noteId == null || type == null) return;

  if (type == 'deleted') {
    ref.read(deletedNoteIdsProvider.notifier).add(noteId);
    return;
  }

  final body = event['body'];
  if (body is! Map<String, dynamic>) return;

  final reaction = body['reaction'] as String?;
  if (reaction == null) return;

  final base = ref.read(noteCaptureProvider).baseOf(noteId);
  if (base == null) return;

  // 自分のリアクションかどうかで扱いが変わる。
  //
  // 同じ端末で押したぶんは既に反映済みなので二重に数えない。一方、
  // 別の端末で押したぶんはここで初めて届くので、件数だけでなく
  // 「自分が付けた」ことも反映しないと他人のリアクションに見える。
  // どちらも同じイベントとして届くため、いま持っている myReaction と
  // 突き合わせて、まだ反映していないものだけを当てる。
  final myId = ref.read(profileNotifierProvider).value?.id;
  final isMine = myId != null && body['userId'] == myId;
  if (isMine) {
    final alreadyApplied = type == 'reacted'
        ? base.myReaction == reaction
        : base.myReaction == null;
    if (alreadyApplied) return;
  }

  final reactions = {...base.reactions};
  if (type == 'reacted') {
    reactions[reaction] = (reactions[reaction] ?? 0) + 1;
  } else if (type == 'unreacted') {
    final next = (reactions[reaction] ?? 1) - 1;
    if (next <= 0) {
      reactions.remove(reaction);
    } else {
      reactions[reaction] = next;
    }
  } else {
    return;
  }

  // カスタム絵文字は URL が付いてくるので、描画できるよう取り込む
  final emoji = body['emoji'];
  final reactionEmojis = {...base.reactionEmojis};
  if (emoji is Map<String, dynamic>) {
    final name = emoji['name'] as String?;
    final url = emoji['url'] as String?;
    if (name != null && url != null) reactionEmojis[name] = url;
  }

  ref
      .read(noteOverridesProvider.notifier)
      .put(base.copyWith(reactions: reactions, reactionEmojis: reactionEmojis));
}
