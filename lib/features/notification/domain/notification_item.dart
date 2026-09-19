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

    /// `reaction:grouped` の中身。同じノートへの連続したリアクションを
    /// まとめたもので、新しい順に入る。
    List<GroupedReaction>? reactions,

    /// `renote:grouped` の中身。同じノートへの連続したリノートの相手を、
    /// 新しい順にまとめたもの。
    List<User>? users,
  }) = _NotificationItem;

  factory NotificationItem.fromJson(Map<String, dynamic> json) =>
      _$NotificationItemFromJson(json);
}

/// `reaction:grouped` 通知に含まれる、1 件ぶんのリアクション。
@freezed
sealed class GroupedReaction with _$GroupedReaction {
  const factory GroupedReaction({
    required User user,
    required String reaction,
  }) = _GroupedReaction;

  factory GroupedReaction.fromJson(Map<String, dynamic> json) =>
      _$GroupedReactionFromJson(json);
}
