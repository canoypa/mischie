import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:mischie/features/timeline/domain/note.dart';
import 'package:mischie/features/timeline/domain/user.dart';

part 'notification_item.freezed.dart';
part 'notification_item.g.dart';

@freezed
sealed class NotificationItem with _$NotificationItem {
  const factory NotificationItem({
    required String id,
    required String createdAt,
    required String type,
    User? user,
    Note? note,
    String? reaction,
  }) = _NotificationItem;

  factory NotificationItem.fromJson(Map<String, dynamic> json) =>
      _$NotificationItemFromJson(json);
}
