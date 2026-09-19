import 'package:mischie/features/notification/domain/notification_item.dart';

/// ストリーミングで届く通知は 1 件ずつの `reaction` / `renote` で、
/// サーバーがまとめるのは REST 取得時（`i/notifications-grouped`）だけ。
/// 先頭がすでに同じノートへの `reaction`（または `reaction:grouped`）なら
/// 行を増やさずそこへ束ね、Web 版と同じ「積まれない」体験にする。
List<NotificationItem> mergeIncomingNotification(
  NotificationItem incoming,
  List<NotificationItem> current,
) {
  if (current.isEmpty) return [incoming, ...current];

  final top = current.first;
  final noteId = incoming.note?.id;
  if (noteId == null || top.note?.id != noteId) {
    return [incoming, ...current];
  }

  if (incoming.type == 'reaction' &&
      (top.type == 'reaction' || top.type == 'reaction:grouped') &&
      incoming.user != null &&
      incoming.reaction != null) {
    return [_mergeReaction(incoming, top), ...current.skip(1)];
  }

  if (incoming.type == 'renote' &&
      (top.type == 'renote' || top.type == 'renote:grouped') &&
      incoming.user != null) {
    return [_mergeRenote(incoming, top), ...current.skip(1)];
  }

  return [incoming, ...current];
}

NotificationItem _mergeReaction(
  NotificationItem incoming,
  NotificationItem top,
) {
  final existing = top.type == 'reaction:grouped'
      ? top.reactions ?? const []
      : [GroupedReaction(user: top.user!, reaction: top.reaction!)];
  return NotificationItem(
    // グループの id はサーバーの規約と同じく最古（= 束ねられる前から
    // あった）メンバーの id を保つ。untilId のページングがこの id に
    // 依存する。
    id: top.id,
    createdAt: incoming.createdAt,
    type: 'reaction:grouped',
    note: top.note,
    reactions: [
      GroupedReaction(user: incoming.user!, reaction: incoming.reaction!),
      ...existing,
    ],
  );
}

NotificationItem _mergeRenote(NotificationItem incoming, NotificationItem top) {
  final existing = top.type == 'renote:grouped'
      ? top.users ?? const []
      : [top.user!];
  return NotificationItem(
    id: top.id,
    createdAt: incoming.createdAt,
    type: 'renote:grouped',
    note: top.note,
    users: [incoming.user!, ...existing],
  );
}
