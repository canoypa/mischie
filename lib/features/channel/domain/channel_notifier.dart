import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mischie/core/providers/core_providers.dart';
import 'package:mischie/features/auth/domain/auth_notifier.dart';
import 'package:mischie/features/channel/data/channel_repository.dart';
import 'package:mischie/features/channel/domain/channel.dart';

final channelRepositoryProvider = Provider<ChannelRepository?>((ref) {
  final client = ref.watch(misskeyApiClientProvider);
  if (client == null) return null;
  return ChannelRepository(client);
});

final channelProvider = FutureProvider.autoDispose.family<Channel, String>((
  ref,
  channelId,
) async {
  final repo = ref.watch(channelRepositoryProvider);
  if (repo == null) throw Exception('未ログイン');
  return repo.show(channelId);
});

final followedChannelsProvider = FutureProvider<List<Channel>>((ref) async {
  final repo = ref.watch(channelRepositoryProvider);
  if (repo == null) return const [];
  return repo.followed();
});

final featuredChannelsProvider = FutureProvider<List<Channel>>((ref) async {
  final repo = ref.watch(channelRepositoryProvider);
  if (repo == null) return const [];
  return repo.featured();
});

final channelSearchProvider = FutureProvider.autoDispose
    .family<List<Channel>, String>((ref, query) async {
      if (query.isEmpty) return const [];
      final repo = ref.watch(channelRepositoryProvider);
      if (repo == null) return const [];
      return repo.search(query);
    });

/// フォロー状態のローカル上書き。押した瞬間に切り替え、失敗したら戻す。
final channelFollowOverridesProvider =
    NotifierProvider<ChannelFollowOverrides, Map<String, bool>>(
      ChannelFollowOverrides.new,
    );

class ChannelFollowOverrides extends Notifier<Map<String, bool>> {
  @override
  Map<String, bool> build() {
    // アカウントが変わったら空に戻す
    ref.watch(currentAccountIdProvider);
    return {};
  }

  void put(String channelId, {required bool following}) =>
      state = {...state, channelId: following};
}

final channelFollowActionsProvider = Provider<ChannelFollowActions>(
  ChannelFollowActions.new,
);

class ChannelFollowActions {
  ChannelFollowActions(this._ref);

  final Ref _ref;

  Future<void> setFollowing(String channelId, {required bool following}) async {
    final repo = _ref.read(channelRepositoryProvider);
    if (repo == null) throw Exception('未ログイン');

    final overrides = _ref.read(channelFollowOverridesProvider.notifier);
    overrides.put(channelId, following: following);
    try {
      if (following) {
        await repo.follow(channelId);
      } else {
        await repo.unfollow(channelId);
      }
    } catch (_) {
      overrides.put(channelId, following: !following);
      rethrow;
    }
  }
}
