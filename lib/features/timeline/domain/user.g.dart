// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_User _$UserFromJson(Map<String, dynamic> json) => _User(
  id: json['id'] as String,
  username: json['username'] as String,
  name: json['name'] as String?,
  avatarUrl: json['avatarUrl'] as String?,
  host: json['host'] as String?,
  isCat: json['isCat'] as bool? ?? false,
  isBot: json['isBot'] as bool? ?? false,
  avatarDecorations:
      (json['avatarDecorations'] as List<dynamic>?)
          ?.map((e) => AvatarDecoration.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
);

Map<String, dynamic> _$UserToJson(_User instance) => <String, dynamic>{
  'id': instance.id,
  'username': instance.username,
  'name': instance.name,
  'avatarUrl': instance.avatarUrl,
  'host': instance.host,
  'isCat': instance.isCat,
  'isBot': instance.isBot,
  'avatarDecorations': instance.avatarDecorations,
};

_AvatarDecoration _$AvatarDecorationFromJson(Map<String, dynamic> json) =>
    _AvatarDecoration(
      id: json['id'] as String,
      url: json['url'] as String,
      angle: (json['angle'] as num?)?.toDouble() ?? 0,
      flipH: json['flipH'] as bool? ?? false,
      offsetX: (json['offsetX'] as num?)?.toDouble() ?? 0,
      offsetY: (json['offsetY'] as num?)?.toDouble() ?? 0,
    );

Map<String, dynamic> _$AvatarDecorationToJson(_AvatarDecoration instance) =>
    <String, dynamic>{
      'id': instance.id,
      'url': instance.url,
      'angle': instance.angle,
      'flipH': instance.flipH,
      'offsetX': instance.offsetX,
      'offsetY': instance.offsetY,
    };
