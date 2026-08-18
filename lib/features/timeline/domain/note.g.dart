// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'note.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Note _$NoteFromJson(Map<String, dynamic> json) => _Note(
  id: json['id'] as String,
  createdAt: json['createdAt'] as String,
  user: User.fromJson(json['user'] as Map<String, dynamic>),
  userId: json['userId'] as String?,
  text: json['text'] as String?,
  cw: json['cw'] as String?,
  replyId: json['replyId'] as String?,
  renoteId: json['renoteId'] as String?,
  reply: json['reply'] == null
      ? null
      : Note.fromJson(json['reply'] as Map<String, dynamic>),
  renote: json['renote'] == null
      ? null
      : Note.fromJson(json['renote'] as Map<String, dynamic>),
  replies: (json['replies'] as List<dynamic>?)
      ?.map((e) => Note.fromJson(e as Map<String, dynamic>))
      .toList(),
  uri: json['uri'] as String?,
  url: json['url'] as String?,
  visibility: json['visibility'] as String? ?? 'public',
  localOnly: json['localOnly'] as bool? ?? false,
  repliesCount: (json['repliesCount'] as num?)?.toInt() ?? 0,
  renoteCount: (json['renoteCount'] as num?)?.toInt() ?? 0,
  myReaction: json['myReaction'] as String?,
  files:
      (json['files'] as List<dynamic>?)
          ?.map((e) => DriveFile.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  reactions:
      (json['reactions'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, (e as num).toInt()),
      ) ??
      const {},
  emojis:
      (json['emojis'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String),
      ) ??
      const {},
  reactionEmojis:
      (json['reactionEmojis'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String),
      ) ??
      const {},
);

Map<String, dynamic> _$NoteToJson(_Note instance) => <String, dynamic>{
  'id': instance.id,
  'createdAt': instance.createdAt,
  'user': instance.user,
  'userId': instance.userId,
  'text': instance.text,
  'cw': instance.cw,
  'replyId': instance.replyId,
  'renoteId': instance.renoteId,
  'reply': instance.reply,
  'renote': instance.renote,
  'replies': instance.replies,
  'uri': instance.uri,
  'url': instance.url,
  'visibility': instance.visibility,
  'localOnly': instance.localOnly,
  'repliesCount': instance.repliesCount,
  'renoteCount': instance.renoteCount,
  'myReaction': instance.myReaction,
  'files': instance.files,
  'reactions': instance.reactions,
  'emojis': instance.emojis,
  'reactionEmojis': instance.reactionEmojis,
};
