import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mischie/core/providers/core_providers.dart';
import 'package:mischie/features/profile/data/profile_repository.dart';
import 'package:mischie/features/timeline/domain/user.dart';

final profileRepositoryProvider = Provider<ProfileRepository?>((ref) {
  final client = ref.watch(misskeyApiClientProvider).value;
  if (client == null) return null;
  return ProfileRepository(client);
});

final profileNotifierProvider =
    AsyncNotifierProvider<ProfileNotifier, User?>(ProfileNotifier.new);

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
