import 'package:mischie/core/api/misskey_api_client.dart';
import 'package:mischie/features/notification/domain/notification_item.dart';

class NotificationRepository {
  const NotificationRepository(this._client);

  final MisskeyApiClient _client;

  Future<List<NotificationItem>> fetchNotifications({
    int limit = 20,
    String? untilId,
  }) async {
    final body = <String, dynamic>{'limit': limit};
    if (untilId != null) body['untilId'] = untilId;

    final list = await _client.postList('i/notifications', body: body);
    return list.map(NotificationItem.fromJson).toList();
  }
}
