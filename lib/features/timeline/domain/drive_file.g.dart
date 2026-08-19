// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'drive_file.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_DriveFile _$DriveFileFromJson(Map<String, dynamic> json) => _DriveFile(
  id: json['id'] as String,
  type: json['type'] as String,
  url: json['url'] as String,
  thumbnailUrl: json['thumbnailUrl'] as String?,
  name: json['name'] as String?,
  blurhash: json['blurhash'] as String?,
  comment: json['comment'] as String?,
  isSensitive: json['isSensitive'] as bool? ?? false,
);

Map<String, dynamic> _$DriveFileToJson(_DriveFile instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': instance.type,
      'url': instance.url,
      'thumbnailUrl': instance.thumbnailUrl,
      'name': instance.name,
      'blurhash': instance.blurhash,
      'comment': instance.comment,
      'isSensitive': instance.isSensitive,
    };
