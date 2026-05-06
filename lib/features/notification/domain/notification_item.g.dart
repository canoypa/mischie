// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_NotificationItem _$NotificationItemFromJson(Map<String, dynamic> json) =>
    _NotificationItem(
      id: json['id'] as String,
      createdAt: json['createdAt'] as String,
      type: json['type'] as String,
      user: json['user'] == null
          ? null
          : User.fromJson(json['user'] as Map<String, dynamic>),
      note: json['note'] == null
          ? null
          : Note.fromJson(json['note'] as Map<String, dynamic>),
      reaction: json['reaction'] as String?,
    );

Map<String, dynamic> _$NotificationItemToJson(_NotificationItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'createdAt': instance.createdAt,
      'type': instance.type,
      'user': instance.user,
      'note': instance.note,
      'reaction': instance.reaction,
    };
