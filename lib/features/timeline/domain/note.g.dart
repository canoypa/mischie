// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'note.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Note _$NoteFromJson(Map<String, dynamic> json) => _Note(
  id: json['id'] as String,
  createdAt: json['createdAt'] as String,
  user: User.fromJson(json['user'] as Map<String, dynamic>),
  text: json['text'] as String?,
  renote: json['renote'] == null
      ? null
      : Note.fromJson(json['renote'] as Map<String, dynamic>),
  replies: (json['replies'] as List<dynamic>?)
      ?.map((e) => Note.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$NoteToJson(_Note instance) => <String, dynamic>{
  'id': instance.id,
  'createdAt': instance.createdAt,
  'user': instance.user,
  'text': instance.text,
  'renote': instance.renote,
  'replies': instance.replies,
};
