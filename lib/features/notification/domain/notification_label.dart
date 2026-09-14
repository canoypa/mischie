import 'package:flutter/material.dart';

/// 通知の種別を、人が読む形に変える。
///
/// 種別は 20 種以上あり、訳を持たないものは識別子がそのまま画面に出ていた。
/// また「自分の投票が終了した」のように相手のいない通知もあるので、
/// 名前を前に付けてよいかどうかも合わせて持つ。
class NotificationLabel {
  const NotificationLabel({
    required this.icon,
    required this.text,
    this.hasActor = true,
    this.role = NotificationRole.neutral,
  });

  final IconData icon;

  /// 相手の名前に続けて読む文。[hasActor] が false ならこれだけで完結する。
  final String text;

  final bool hasActor;
  final NotificationRole role;
}

/// バッジの色。既製の色を直接使わず、テーマのロールから引く。
enum NotificationRole { primary, secondary, tertiary, neutral }

NotificationLabel notificationLabel(String type) => switch (type) {
  'reaction' => const NotificationLabel(
    icon: Icons.add_reaction,
    text: 'がリアクション',
    role: NotificationRole.tertiary,
  ),
  'reply' => const NotificationLabel(
    icon: Icons.reply,
    text: 'が返信',
    role: NotificationRole.primary,
  ),
  'renote' => const NotificationLabel(
    icon: Icons.repeat,
    text: 'がリノート',
    role: NotificationRole.secondary,
  ),
  'quote' => const NotificationLabel(
    icon: Icons.format_quote,
    text: 'が引用',
    role: NotificationRole.secondary,
  ),
  'mention' => const NotificationLabel(
    icon: Icons.alternate_email,
    text: 'がメンション',
    role: NotificationRole.primary,
  ),
  'follow' => const NotificationLabel(
    icon: Icons.person_add,
    text: 'にフォローされました',
    role: NotificationRole.tertiary,
  ),
  'followRequestAccepted' => const NotificationLabel(
    icon: Icons.how_to_reg,
    text: 'がフォローを承認しました',
    role: NotificationRole.tertiary,
  ),
  'receiveFollowRequest' => const NotificationLabel(
    icon: Icons.person_add_alt,
    text: 'からフォローリクエスト',
    role: NotificationRole.tertiary,
  ),
  'note' => const NotificationLabel(
    icon: Icons.edit_note,
    text: 'が投稿しました',
    role: NotificationRole.primary,
  ),
  'chatRoomInvitationReceived' => const NotificationLabel(
    icon: Icons.chat_bubble_outline,
    text: 'からチャットの招待',
    role: NotificationRole.primary,
  ),
  // ここから下は相手がいない（自分に起きたこと）
  'pollEnded' => const NotificationLabel(
    icon: Icons.poll_outlined,
    text: '投票が終了しました',
    hasActor: false,
  ),
  'achievementEarned' => const NotificationLabel(
    icon: Icons.emoji_events_outlined,
    text: '実績を獲得しました',
    hasActor: false,
    role: NotificationRole.tertiary,
  ),
  'roleAssigned' => const NotificationLabel(
    icon: Icons.badge_outlined,
    text: 'ロールが付与されました',
    hasActor: false,
  ),
  'exportCompleted' => const NotificationLabel(
    icon: Icons.download_done,
    text: 'エクスポートが完了しました',
    hasActor: false,
  ),
  'scheduledNotePosted' => const NotificationLabel(
    icon: Icons.schedule_send,
    text: '予約投稿が投稿されました',
    hasActor: false,
  ),
  'scheduledNotePostFailed' => const NotificationLabel(
    icon: Icons.error_outline,
    text: '予約投稿に失敗しました',
    hasActor: false,
  ),
  'app' => const NotificationLabel(
    icon: Icons.apps,
    text: 'アプリからの通知',
    hasActor: false,
  ),
  'test' => const NotificationLabel(
    icon: Icons.bug_report_outlined,
    text: 'テスト通知',
    hasActor: false,
  ),
  // 知らない種別は識別子を出さない。読めない英語より「通知」のほうがまし。
  _ => const NotificationLabel(
    icon: Icons.notifications,
    text: '通知',
    hasActor: false,
  ),
};
