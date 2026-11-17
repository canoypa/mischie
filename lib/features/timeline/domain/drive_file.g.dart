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
  size: (json['size'] as num?)?.toInt(),
  folderId: json['folderId'] as String?,
  comment: json['comment'] as String?,
  properties: json['properties'] == null
      ? null
      : DriveFileProperties.fromJson(
          json['properties'] as Map<String, dynamic>,
        ),
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
      'size': instance.size,
      'folderId': instance.folderId,
      'comment': instance.comment,
      'properties': instance.properties,
      'isSensitive': instance.isSensitive,
    };

_DriveFileProperties _$DriveFilePropertiesFromJson(Map<String, dynamic> json) =>
    _DriveFileProperties(
      width: (json['width'] as num?)?.toDouble(),
      height: (json['height'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$DriveFilePropertiesToJson(
  _DriveFileProperties instance,
) => <String, dynamic>{'width': instance.width, 'height': instance.height};
