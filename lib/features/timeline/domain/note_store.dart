import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mischie/features/timeline/domain/note.dart';

/// 操作の結果を持つローカルの状態。取得したノートそのものは書き換えず、
/// ここに重ねることで、どの画面から見ても同じ状態に見えるようにする。

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
