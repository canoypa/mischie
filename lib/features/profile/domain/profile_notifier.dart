import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mischie/core/providers/core_providers.dart';
import 'package:mischie/features/profile/data/profile_repository.dart';
import 'package:mischie/features/profile/domain/user_detailed.dart';
import 'package:mischie/features/timeline/domain/user.dart';

final profileRepositoryProvider = Provider<ProfileRepository?>((ref) {
  final client = ref.watch(misskeyApiClientProvider).value;
  if (client == null) return null;
  return ProfileRepository(client);
});

final userDetailProvider = FutureProvider.family<UserDetailed, String>((
  ref,
  userId,
) async {
  final repo = ref.watch(profileRepositoryProvider);
  if (repo == null) throw Exception('未ログイン');
  return repo.fetchUser(userId);
});

final profileNotifierProvider = AsyncNotifierProvider<ProfileNotifier, User?>(
  ProfileNotifier.new,
);

class ProfileNotifier extends AsyncNotifier<User?> {
  @override
  Future<User?> build() async {
    final repo = ref.watch(profileRepositoryProvider);
    if (repo == null) return null;
    return repo.fetchMe();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(profileRepositoryProvider);
      if (repo == null) return null;
      return repo.fetchMe();
    });
  }
}

/// フォロー状態のローカル上書き（userId → フォロー中か）。
///
/// 押した瞬間にボタンを切り替え、API 失敗時だけ戻す。プロフィール全体を
/// 取り直すと画面が一瞬崩れるうえ、往復の待ちが体感速度を落とすため。
final followOverridesProvider =
    NotifierProvider<FollowOverrides, Map<String, bool>>(FollowOverrides.new);

class FollowOverrides extends Notifier<Map<String, bool>> {
  @override
  Map<String, bool> build() => {};

  void put(String userId, {required bool following}) =>
      state = {...state, userId: following};
}

final followActionsProvider = Provider<FollowActions>(FollowActions.new);

class FollowActions {
  FollowActions(this._ref);

  final Ref _ref;

  Future<void> setFollowing(String userId, {required bool following}) async {
    final repo = _ref.read(profileRepositoryProvider);
    if (repo == null) throw Exception('未ログイン');

    final overrides = _ref.read(followOverridesProvider.notifier);
    overrides.put(userId, following: following);
    try {
      if (following) {
        await repo.follow(userId);
      } else {
        await repo.unfollow(userId);
      }
    } catch (_) {
      overrides.put(userId, following: !following);
      rethrow;
    }
  }
}

/// この端末でミュート／ブロックしたユーザー。
///
/// サーバー側の絞り込みは次回の取得から効くので、すでに画面にあるノートは
/// 残ってしまう。押した直後から消えるように、描画側でも伏せる。
final hiddenUserIdsProvider = NotifierProvider<HiddenUserIds, Set<String>>(
  HiddenUserIds.new,
);

class HiddenUserIds extends Notifier<Set<String>> {
  @override
  Set<String> build() => {};

  void add(String userId) => state = {...state, userId};

  void remove(String userId) => state = {...state}..remove(userId);
}

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
    final hidden = _ref.read(hiddenUserIdsProvider.notifier);
    if (muted) {
      await repo.mute(userId);
      hidden.add(userId);
    } else {
      await repo.unmute(userId);
      hidden.remove(userId);
    }
  }

  Future<void> setBlocked(String userId, {required bool blocked}) async {
    final repo = _repo();
    final hidden = _ref.read(hiddenUserIdsProvider.notifier);
    if (blocked) {
      await repo.block(userId);
      hidden.add(userId);
    } else {
      await repo.unblock(userId);
      hidden.remove(userId);
    }
  }
}
