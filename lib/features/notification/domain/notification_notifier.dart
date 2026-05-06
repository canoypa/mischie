import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mischie/core/providers/core_providers.dart';
import 'package:mischie/features/notification/data/notification_repository.dart';
import 'package:mischie/features/notification/domain/notification_item.dart';

final notificationRepositoryProvider =
    Provider<NotificationRepository?>((ref) {
  final client = ref.watch(misskeyApiClientProvider).value;
  if (client == null) return null;
  return NotificationRepository(client);
});

final notificationNotifierProvider =
    AsyncNotifierProvider<NotificationNotifier, List<NotificationItem>>(
      NotificationNotifier.new,
    );

class NotificationNotifier extends AsyncNotifier<List<NotificationItem>> {
  @override
  Future<List<NotificationItem>> build() => _fetch();

  Future<List<NotificationItem>> _fetch({String? untilId}) async {
    final repo = ref.read(notificationRepositoryProvider);
    if (repo == null) throw Exception('未ログイン');
    return repo.fetchNotifications(untilId: untilId);
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(_fetch);
  }

  Future<void> loadMore() async {
    final current = state.value;
    if (current == null || current.isEmpty) return;
    final more = await _fetch(untilId: current.last.id);
    state = AsyncValue.data([...current, ...more]);
  }
}
