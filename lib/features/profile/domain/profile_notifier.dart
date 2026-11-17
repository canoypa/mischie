import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mischie/core/providers/core_providers.dart';
import 'package:mischie/features/auth/domain/auth_notifier.dart';
import 'package:mischie/features/profile/data/profile_repository.dart';
import 'package:mischie/features/profile/domain/user_detailed.dart';
import 'package:mischie/features/timeline/domain/note_store.dart';
import 'package:mischie/features/timeline/domain/user.dart';

final profileRepositoryProvider = Provider<ProfileRepository?>((ref) {
  final client = ref.watch(misskeyApiClientProvider);
  if (client == null) return null;
  return ProfileRepository(client);
});

final userDetailProvider = FutureProvider.autoDispose
    .family<UserDetailed, String>((ref, userId) async {
      final repo = ref.watch(profileRepositoryProvider);
      if (repo == null) throw Exception('未ログイン');
      final detail = await repo.fetchUser(userId);
      // pinnedNotes も NoteCard 経由で resolveNote を通るので対象にする
      ref.read(noteOverridesProvider.notifier).evictFetched(detail.pinnedNotes);
      return detail;
    });

/// 自分のアカウント情報（`i` の応答そのまま）。
final meProvider = FutureProvider<Map<String, dynamic>?>((ref) async {
  final client = ref.watch(misskeyApiClientProvider);
  if (client == null) return null;
  return client.post('i');
});

final profileNotifierProvider = AsyncNotifierProvider<ProfileNotifier, User?>(
  ProfileNotifier.new,
);

class ProfileNotifier extends AsyncNotifier<User?> {
  @override
  Future<User?> build() async {
    final me = await ref.watch(meProvider.future);
    return me == null ? null : User.fromJson(me);
  }

  Future<void> refresh() async {
    ref.invalidate(meProvider);
    await future;
  }
}

/// フォロー状態のローカル上書き。取り直すと画面が崩れ待ちも出るので、
/// 押した瞬間に切り替え、失敗したら戻す。
final followOverridesProvider =
    NotifierProvider<FollowOverrides, Map<String, FollowState>>(
      FollowOverrides.new,
    );

class FollowOverrides extends Notifier<Map<String, FollowState>> {
  @override
  Map<String, FollowState> build() {
    // アカウントが変わったら空に戻す
    ref.watch(currentAccountIdProvider);
    return {};
  }

  void put(String userId, FollowState followState) =>
      state = {...state, userId: followState};
}

final followActionsProvider = Provider<FollowActions>(FollowActions.new);

class FollowActions {
  FollowActions(this._ref);

  final Ref _ref;

  Future<void> follow(String userId, {required bool locked}) => _apply(
    userId,
    next: locked ? FollowState.requested : FollowState.following,
    previous: FollowState.none,
    call: (repo) => repo.follow(userId),
  );

  Future<void> unfollow(String userId) => _apply(
    userId,
    next: FollowState.none,
    previous: FollowState.following,
    call: (repo) => repo.unfollow(userId),
  );

  Future<void> cancelRequest(String userId) => _apply(
    userId,
    next: FollowState.none,
    previous: FollowState.requested,
    call: (repo) => repo.cancelFollowRequest(userId),
  );

  Future<void> _apply(
    String userId, {
    required FollowState next,
    required FollowState previous,
    required Future<void> Function(ProfileRepository repo) call,
  }) async {
    final repo = _ref.read(profileRepositoryProvider);
    if (repo == null) throw Exception('未ログイン');

    final overrides = _ref.read(followOverridesProvider.notifier);
    overrides.put(userId, next);
    try {
      await call(repo);
    } catch (_) {
      overrides.put(userId, previous);
      rethrow;
    }
  }
}

/// 取得済みの [UserDetailed] は操作後も古いままなので、こちらを優先する。
/// null は未操作。
final moderationOverridesProvider =
    NotifierProvider<ModerationOverrides, Map<String, UserModeration>>(
      ModerationOverrides.new,
    );

class UserModeration {
  const UserModeration({this.muted, this.blocking});

  final bool? muted;
  final bool? blocking;
}

class ModerationOverrides extends Notifier<Map<String, UserModeration>> {
  @override
  Map<String, UserModeration> build() {
    // アカウントが変わったら空に戻す
    ref.watch(currentAccountIdProvider);
    return {};
  }

  void setMuted(String userId, {required bool muted}) {
    final current = state[userId];
    state = {
      ...state,
      userId: UserModeration(muted: muted, blocking: current?.blocking),
    };
  }

  void setBlocking(String userId, {required bool blocking}) {
    final current = state[userId];
    state = {
      ...state,
      userId: UserModeration(muted: current?.muted, blocking: blocking),
    };
  }
}

/// すでに画面にあるノートは次の取得まで残るので、描画側でも伏せる。
final hiddenUserIdsProvider = Provider<Set<String>>((ref) {
  final overrides = ref.watch(moderationOverridesProvider);
  return {
    for (final entry in overrides.entries)
      if (entry.value.muted == true || entry.value.blocking == true) entry.key,
  };
});

final moderationActionsProvider = Provider<ModerationActions>(
  ModerationActions.new,
);

class ModerationActions {
  ModerationActions(this._ref);

  final Ref _ref;

  ProfileRepository _repo() {
    final repo = _ref.read(profileRepositoryProvider);
    if (repo == null) throw Exception('未ログイン');
    return repo;
  }

  Future<void> setMuted(String userId, {required bool muted}) async {
    final repo = _repo();
    if (muted) {
      await repo.mute(userId);
    } else {
      await repo.unmute(userId);
    }
    _ref
        .read(moderationOverridesProvider.notifier)
        .setMuted(userId, muted: muted);
  }

  Future<void> setBlocked(String userId, {required bool blocked}) async {
    final repo = _repo();
    if (blocked) {
      await repo.block(userId);
    } else {
      await repo.unblock(userId);
    }
    _ref
        .read(moderationOverridesProvider.notifier)
        .setBlocking(userId, blocking: blocked);
    // ブロックするとフォロー関係も解消される
    if (blocked) {
      _ref.read(followOverridesProvider.notifier).put(userId, FollowState.none);
    }
  }
}
