import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mischie/core/emoji/emoji_providers.dart';
import 'package:mischie/core/providers/core_providers.dart';
import 'package:mischie/features/timeline/data/note_repository.dart';
import 'package:mischie/features/timeline/domain/note.dart';
import 'package:mischie/features/timeline/domain/note_store.dart';

final noteRepositoryProvider = Provider<NoteRepository?>((ref) {
  final client = ref.watch(misskeyApiClientProvider);
  if (client == null) return null;
  return NoteRepository(client);
});

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

  /// 楽観的更新の重ね掛け（override）があればそれを、無ければ渡されたノートを返す。
  Note _current(Note note) => _ref.read(noteOverridesProvider)[note.id] ?? note;

  /// 同じリアクションなら取り消し、違うリアクションなら付け替える。
  Future<void> toggleReaction(Note note, String reaction) async {
    final repo = _repo();
    final overrides = _ref.read(noteOverridesProvider.notifier);
    final current = _current(note);
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
    final current = _current(note);

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
    final current = _current(note);

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
    final current = _current(note);
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
