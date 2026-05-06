import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mischie/core/providers/core_providers.dart';
import 'package:mischie/features/notification/domain/notification_item.dart';

final notificationNotifierProvider =
    AsyncNotifierProvider<NotificationNotifier, List<NotificationItem>>(
      NotificationNotifier.new,
    );

class NotificationNotifier extends AsyncNotifier<List<NotificationItem>> {
  @override
  Future<List<NotificationItem>> build() => _fetch();

  Future<List<NotificationItem>> _fetch({String? untilId}) async {
    final client = ref.read(misskeyApiClientProvider).value;
    if (client == null) throw Exception('未ログイン');
    final body = <String, dynamic>{'limit': 20};
    if (untilId != null) body['untilId'] = untilId;
    final data = await client.postList('i/notifications', body: body);
    return [for (final d in data) NotificationItem.fromJson(d)];
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
