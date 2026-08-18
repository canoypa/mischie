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
