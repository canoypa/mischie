import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mischie/core/emoji/emoji_providers.dart';
import 'package:mischie/core/providers/core_providers.dart';
import 'package:mischie/core/streaming/streaming_service.dart';
import 'package:mischie/features/profile/domain/profile_notifier.dart';
import 'package:mischie/features/timeline/domain/timeline_notifier.dart';
import 'package:mischie/features/timeline/data/note_repository.dart';
import 'package:mischie/features/timeline/domain/note.dart';

final noteRepositoryProvider = Provider<NoteRepository?>((ref) {
  final client = ref.watch(misskeyApiClientProvider);
  if (client == null) return null;
  return NoteRepository(client);
});

/// 操作後のノートを ID で保持する上書きストア。
///
/// 同じノートはタイムライン・プロフィール・ノート詳細に同時に存在しうる。
/// 各リストの `List<Note>` を個別に書き換えると表示がずれるため、操作結果は
/// ここに一本化し、`NoteCard` 側が描画時に解決する。
final noteOverridesProvider =
    NotifierProvider<NoteOverrides, Map<String, Note>>(NoteOverrides.new);

class NoteOverrides extends Notifier<Map<String, Note>> {
  @override
  Map<String, Note> build() => {};

  void put(Note note) => state = {...state, note.id: note};

  void remove(String noteId) => state = {...state}..remove(noteId);
}

/// 削除されたノートの ID。リストから抜くのではなく描画側で伏せる。
final deletedNoteIdsProvider = NotifierProvider<DeletedNoteIds, Set<String>>(
  DeletedNoteIds.new,
);

class DeletedNoteIds extends Notifier<Set<String>> {
  @override
  Set<String> build() => {};

  void add(String noteId) => state = {...state, noteId};
}

final noteActionsProvider = Provider<NoteActions>(NoteActions.new);

/// ノート操作。UI を待たせないよう先にローカル状態を更新し、
/// API が失敗したら元に戻す（楽観的更新）。
class NoteActions {
  NoteActions(this._ref);

  final Ref _ref;

  NoteRepository _repo() {
    final repo = _ref.read(noteRepositoryProvider);
    if (repo == null) throw Exception('未ログイン');
    return repo;
  }

  /// 同じリアクションなら取り消し、違うリアクションなら付け替える。
  Future<void> toggleReaction(Note note, String reaction) async {
    final repo = _repo();
    final overrides = _ref.read(noteOverridesProvider.notifier);
    final current = _ref.read(noteOverridesProvider)[note.id] ?? note;
    final previous = current;

    final isSame = current.myReaction == reaction;
    overrides.put(
      isSame
          ? _withReactionRemoved(current)
          : _withReaction(_withReactionRemoved(current), reaction),
    );

    try {
      if (current.myReaction != null) await repo.unreact(note.id);
      if (!isSame) {
        await repo.react(note.id, reaction);
        await _ref.read(reactionHistoryProvider.notifier).record(reaction);
      }
    } catch (_) {
      overrides.put(previous);
      rethrow;
    }
  }

  Future<void> renote(Note note) async {
    final repo = _repo();
    final overrides = _ref.read(noteOverridesProvider.notifier);
    final current = _ref.read(noteOverridesProvider)[note.id] ?? note;

    overrides.put(current.copyWith(renoteCount: current.renoteCount + 1));
    try {
      await repo.renote(note.id);
    } catch (_) {
      overrides.put(current);
      rethrow;
    }
  }

  Future<void> unrenote(Note note) async {
    final repo = _repo();
    final overrides = _ref.read(noteOverridesProvider.notifier);
    final current = _ref.read(noteOverridesProvider)[note.id] ?? note;

    overrides.put(
      current.copyWith(
        renoteCount: current.renoteCount > 0 ? current.renoteCount - 1 : 0,
      ),
    );
    try {
      await repo.unrenote(note.id);
    } catch (_) {
      overrides.put(current);
      rethrow;
    }
  }

  /// 投票する。結果は押した時点で反映し、失敗したら戻す。
  Future<void> vote(Note note, int choice) async {
    final repo = _repo();
    final overrides = _ref.read(noteOverridesProvider.notifier);
    final current = _ref.read(noteOverridesProvider)[note.id] ?? note;
    final poll = current.poll;
    if (poll == null) return;

    final choices = [
      for (var i = 0; i < poll.choices.length; i++)
        if (i == choice)
          poll.choices[i].copyWith(
            votes: poll.choices[i].votes + 1,
            isVoted: true,
          )
        else
          poll.choices[i],
    ];
    overrides.put(current.copyWith(poll: poll.copyWith(choices: choices)));

    try {
      await repo.vote(note.id, choice);
    } catch (_) {
      overrides.put(current);
      rethrow;
    }
  }

  Future<void> delete(Note note) async {
    await _repo().delete(note.id);
    _ref.read(deletedNoteIdsProvider.notifier).add(note.id);
  }

  Note _withReactionRemoved(Note note) {
    final mine = note.myReaction;
    if (mine == null) return note;
    final reactions = {...note.reactions};
    final count = (reactions[mine] ?? 1) - 1;
    if (count <= 0) {
      reactions.remove(mine);
    } else {
      reactions[mine] = count;
    }
    return note.copyWith(reactions: reactions, myReaction: null);
  }

  Note _withReaction(Note note, String reaction) {
    final reactions = {...note.reactions};
    reactions[reaction] = (reactions[reaction] ?? 0) + 1;
    return note.copyWith(reactions: reactions, myReaction: reaction);
  }
}

/// 上書きストアを反映したノートを返す。`ref.watch` 経由で使う。
Note resolveNote(WidgetRef ref, Note note) {
  final override = ref.watch(noteOverridesProvider.select((m) => m[note.id]));
  final resolved = override ?? note;
  final renote = resolved.renote;
  if (renote == null) return resolved;
  final renoteOverride = ref.watch(
    noteOverridesProvider.select((m) => m[renote.id]),
  );
  return renoteOverride == null
      ? resolved
      : resolved.copyWith(renote: renoteOverride);
}

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

  // 自分の操作は押した時点で反映済み。ここで足すと二重に数えてしまう。
  final myId = ref.read(profileNotifierProvider).value?.id;
  if (myId != null && body['userId'] == myId) return;

  final reaction = body['reaction'] as String?;
  if (reaction == null) return;

  final base = ref.read(noteCaptureProvider).baseOf(noteId);
  if (base == null) return;

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
