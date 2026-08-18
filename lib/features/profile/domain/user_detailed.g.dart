// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_detailed.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UserDetailed _$UserDetailedFromJson(Map<String, dynamic> json) =>
    _UserDetailed(
      id: json['id'] as String,
      username: json['username'] as String,
      name: json['name'] as String?,
      host: json['host'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      bannerUrl: json['bannerUrl'] as String?,
      bannerBlurhash: json['bannerBlurhash'] as String?,
      description: json['description'] as String?,
      location: json['location'] as String?,
      birthday: json['birthday'] as String?,
      createdAt: json['createdAt'] as String?,
      isBot: json['isBot'] as bool? ?? false,
      isCat: json['isCat'] as bool? ?? false,
      isFollowing: json['isFollowing'] as bool? ?? false,
      isFollowed: json['isFollowed'] as bool? ?? false,
      isMuted: json['isMuted'] as bool? ?? false,
      isBlocking: json['isBlocking'] as bool? ?? false,
      avatarDecorations:
          (json['avatarDecorations'] as List<dynamic>?)
              ?.map((e) => AvatarDecoration.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      followersCount: (json['followersCount'] as num?)?.toInt(),
      followingCount: (json['followingCount'] as num?)?.toInt(),
      notesCount: (json['notesCount'] as num?)?.toInt(),
      fields:
          (json['fields'] as List<dynamic>?)
              ?.map((e) => ProfileField.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      roles:
          (json['roles'] as List<dynamic>?)
              ?.map((e) => UserRole.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      emojis:
          (json['emojis'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, e as String),
          ) ??
          const {},
    );

Map<String, dynamic> _$UserDetailedToJson(_UserDetailed instance) =>
    <String, dynamic>{
      'id': instance.id,
      'username': instance.username,
      'name': instance.name,
      'host': instance.host,
      'avatarUrl': instance.avatarUrl,
      'bannerUrl': instance.bannerUrl,
      'bannerBlurhash': instance.bannerBlurhash,
      'description': instance.description,
      'location': instance.location,
      'birthday': instance.birthday,
      'createdAt': instance.createdAt,
      'isBot': instance.isBot,
      'isCat': instance.isCat,
      'isFollowing': instance.isFollowing,
      'isFollowed': instance.isFollowed,
      'isMuted': instance.isMuted,
      'isBlocking': instance.isBlocking,
      'avatarDecorations': instance.avatarDecorations,
      'followersCount': instance.followersCount,
      'followingCount': instance.followingCount,
      'notesCount': instance.notesCount,
      'fields': instance.fields,
      'roles': instance.roles,
      'emojis': instance.emojis,
    };

_ProfileField _$ProfileFieldFromJson(Map<String, dynamic> json) =>
    _ProfileField(
      name: json['name'] as String? ?? '',
      value: json['value'] as String? ?? '',
    );

Map<String, dynamic> _$ProfileFieldToJson(_ProfileField instance) =>
    <String, dynamic>{'name': instance.name, 'value': instance.value};

_UserRole _$UserRoleFromJson(Map<String, dynamic> json) => _UserRole(
  id: json['id'] as String,
  name: json['name'] as String? ?? '',
  color: json['color'] as String?,
  iconUrl: json['iconUrl'] as String?,
);

Map<String, dynamic> _$UserRoleToJson(_UserRole instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'color': instance.color,
  'iconUrl': instance.iconUrl,
};
