import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mischie/core/emoji/emoji_providers.dart';
import 'package:mischie/core/providers/core_providers.dart';
import 'package:mischie/features/timeline/data/note_repository.dart';
import 'package:mischie/features/timeline/domain/note.dart';
import 'package:mischie/features/timeline/domain/note_store.dart';
import 'package:mischie/features/timeline/domain/reaction_key.dart';

final noteRepositoryProvider = Provider<NoteRepository?>((ref) {
  final client = ref.watch(misskeyApiClientProvider);
  if (client == null) return null;
  return NoteRepository(client);
});

final noteActionsProvider = Provider<NoteActions>(NoteActions.new);

/// リアクション・リノート・投票は先に表示へ反映し、失敗したら戻す。
class NoteActions {
  NoteActions(this._ref);

  final Ref _ref;

  NoteRepository _repo() {
    final repo = _ref.read(noteRepositoryProvider);
    if (repo == null) throw Exception('未ログイン');
    return repo;
  }

  Note _current(Note note) => _ref.read(noteOverridesProvider)[note.id] ?? note;

  Future<void> toggleReaction(Note note, String reaction) async {
    final key = normalizeReactionKey(reaction);
    final repo = _repo();
    final overrides = _ref.read(noteOverridesProvider.notifier);
    final current = _current(note);
    final previous = current;

    final isSame = current.myReaction == key;
    overrides.put(
      isSame
          ? _withReactionRemoved(current)
          : _withReaction(_withReactionRemoved(current), key),
    );

    // 付け替えで unreact だけ成功した場合、サーバーにはもう元のリアクションが
    // 無いので、戻し先を変える。
    var unreacted = false;
    try {
      if (current.myReaction != null) {
        await repo.unreact(note.id);
        unreacted = true;
      }
      if (!isSame) {
        await repo.react(note.id, key);
        await _ref.read(reactionHistoryProvider.notifier).record(key);
      }
    } catch (_) {
      overrides.put(unreacted ? _withReactionRemoved(current) : previous);
      rethrow;
    }
  }

  Future<void> renote(Note note, {bool inChannel = false}) async {
    final repo = _repo();
    final overrides = _ref.read(noteOverridesProvider.notifier);
    final current = _current(note);

    overrides.put(current.copyWith(renoteCount: current.renoteCount + 1));
    try {
      await repo.renote(
        note.id,
        visibility: inChannel ? null : _renoteVisibility(note),
        channelId: inChannel ? note.channelId : null,
      );
    } catch (_) {
      overrides.put(current);
      rethrow;
    }
  }

  /// センシティブなチャンネルのノートを公開タイムラインへ広げない。
  String _renoteVisibility(Note note) =>
      note.visibility == 'public' && note.channel?.isSensitive == true
      ? 'home'
      : note.visibility;

  /// [renoteItem] は元のノートではなく、自分のリノートそのもの。
  Future<void> unrenote(Note renoteItem) async {
    final repo = _repo();
    final overrides = _ref.read(noteOverridesProvider.notifier);
    final original = renoteItem.renote!;
    final current = _current(original);

    overrides.put(
      current.copyWith(
        renoteCount: current.renoteCount > 0 ? current.renoteCount - 1 : 0,
      ),
    );
    try {
      await repo.delete(renoteItem.id);
    } catch (_) {
      overrides.put(current);
      rethrow;
    }
    _ref.read(deletedNoteIdsProvider.notifier).add(renoteItem.id);
  }

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

  Future<NoteState> noteState(Note note) async => _repo().state(note.id);

  Future<bool> isPinned(Note note) async =>
      (await _repo().pinnedNoteIds()).contains(note.id);

  Future<void> setFavorite(Note note, {required bool favorite}) async {
    final repo = _repo();
    await (favorite ? repo.favorite(note.id) : repo.unfavorite(note.id));
  }

  Future<void> setThreadMuted(Note note, {required bool muted}) async {
    final repo = _repo();
    await (muted ? repo.muteThread(note.id) : repo.unmuteThread(note.id));
  }

  Future<void> setPinned(Note note, {required bool pinned}) async {
    final repo = _repo();
    await (pinned ? repo.pin(note.id) : repo.unpin(note.id));
  }

  Future<void> reportAbuse(Note note, String comment) async =>
      _repo().reportAbuse(note.user.id, comment);

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
