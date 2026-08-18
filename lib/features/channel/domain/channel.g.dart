// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'channel.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Channel _$ChannelFromJson(Map<String, dynamic> json) => _Channel(
  id: json['id'] as String,
  name: json['name'] as String? ?? '',
  description: json['description'] as String?,
  bannerUrl: json['bannerUrl'] as String?,
  color: json['color'] as String?,
  usersCount: (json['usersCount'] as num?)?.toInt() ?? 0,
  notesCount: (json['notesCount'] as num?)?.toInt() ?? 0,
  isFollowing: json['isFollowing'] as bool? ?? false,
  isFavorited: json['isFavorited'] as bool? ?? false,
  isArchived: json['isArchived'] as bool? ?? false,
  isSensitive: json['isSensitive'] as bool? ?? false,
);

Map<String, dynamic> _$ChannelToJson(_Channel instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'description': instance.description,
  'bannerUrl': instance.bannerUrl,
  'color': instance.color,
  'usersCount': instance.usersCount,
  'notesCount': instance.notesCount,
  'isFollowing': instance.isFollowing,
  'isFavorited': instance.isFavorited,
  'isArchived': instance.isArchived,
  'isSensitive': instance.isSensitive,
};
