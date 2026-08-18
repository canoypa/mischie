import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mischie/core/providers/core_providers.dart';
import 'package:mischie/features/timeline/data/note_repository.dart';
import 'package:mischie/features/timeline/domain/note.dart';

final noteRepositoryProvider = Provider<NoteRepository?>((ref) {
  final client = ref.watch(misskeyApiClientProvider).value;
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
      if (!isSame) await repo.react(note.id, reaction);
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
