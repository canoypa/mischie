import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mischie/features/auth/domain/auth_notifier.dart';
import 'package:mischie/features/timeline/domain/note.dart';

/// 同じノートが複数の画面に出るので、操作結果は各リストを書き換えずに
/// ここへ一本化し、描画時に重ねる。
final noteOverridesProvider =
    NotifierProvider<NoteOverrides, Map<String, Note>>(NoteOverrides.new);

class NoteOverrides extends Notifier<Map<String, Note>> {
  @override
  Map<String, Note> build() {
    // アカウントが変わったら空に戻す
    ref.watch(currentAccountIdProvider);
    return {};
  }

  void put(Note note) => state = {...state, note.id: note};

  void remove(String noteId) => state = {...state}..remove(noteId);

  /// 取得し直したノートの上書きを外す。外さないと件数が古いまま固まる。
  void evictFetched(Iterable<Note> notes) {
    if (state.isEmpty) return;
    final idsToEvict = <String>{};
    for (final note in notes) {
      if (state.containsKey(note.id)) idsToEvict.add(note.id);
      final renoteId = note.renote?.id;
      if (renoteId != null && state.containsKey(renoteId)) {
        idsToEvict.add(renoteId);
      }
    }
    if (idsToEvict.isEmpty) return;
    state = {...state}..removeWhere((id, _) => idsToEvict.contains(id));
  }
}

/// リストからは抜かず、描画側で伏せる。
final deletedNoteIdsProvider = NotifierProvider<DeletedNoteIds, Set<String>>(
  DeletedNoteIds.new,
);

class DeletedNoteIds extends Notifier<Set<String>> {
  @override
  Set<String> build() {
    // アカウントが変わったら空に戻す
    ref.watch(currentAccountIdProvider);
    return {};
  }

  void add(String noteId) => state = {...state, noteId};
}

/// 中で `ref.watch` するので build の中でだけ呼ぶ。
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
