import 'package:mischie/core/api/misskey_api_client.dart';
import 'package:mischie/features/notification/domain/notification_item.dart';

class NotificationRepository {
  const NotificationRepository(this._client);

  final MisskeyApiClient _client;

  Future<List<NotificationItem>> fetchNotifications({
    int limit = 20,
    String? untilId,
    String? sinceId,
    bool? markAsRead,
  }) async {
    final body = <String, dynamic>{'limit': limit};
    if (untilId != null) body['untilId'] = untilId;
    if (sinceId != null) body['sinceId'] = sinceId;
    if (markAsRead != null) body['markAsRead'] = markAsRead;

    final list = await _client.postList('i/notifications-grouped', body: body);
    return list.map(NotificationItem.fromJson).toList();
  }

  Future<void> markAllAsRead() =>
      _client.postVoid('notifications/mark-all-as-read');

  Future<void> acceptFollowRequest(String userId) =>
      _client.postVoid('following/requests/accept', body: {'userId': userId});

  Future<void> rejectFollowRequest(String userId) =>
      _client.postVoid('following/requests/reject', body: {'userId': userId});
}
