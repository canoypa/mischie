import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:mischie/features/timeline/domain/drive_file.dart';
import 'package:mischie/features/timeline/domain/user.dart';

part 'note.freezed.dart';
part 'note.g.dart';

@freezed
sealed class Note with _$Note {
  const factory Note({
    required String id,
    required String createdAt,
    required User user,
    String? userId,
    String? text,
    String? cw,
    String? replyId,
    String? renoteId,
    Note? reply,
    Note? renote,
    List<Note>? replies,
    String? uri,
    String? url,
    String? channelId,
    NoteChannel? channel,
    @Default('public') String visibility,
    @Default(false) bool localOnly,
    @Default(0) int repliesCount,
    @Default(0) int renoteCount,
    String? myReaction,
    @Default([]) List<DriveFile> files,
    @Default({}) Map<String, int> reactions,
    @Default({}) Map<String, String> emojis,
    @Default({}) Map<String, String> reactionEmojis,
  }) = _Note;

  const Note._();

  factory Note.fromJson(Map<String, dynamic> json) => _$NoteFromJson(json);

  /// 本文も添付もリアクションも持たない、純粋なリノート（引用ではない）。
  bool get isPureRenote =>
      renote != null && (text == null || text!.isEmpty) && files.isEmpty;
}

/// ノートが投稿されたチャンネル。
@freezed
sealed class NoteChannel with _$NoteChannel {
  const factory NoteChannel({
    required String id,
    @Default('') String name,
    String? color,
    @Default(false) bool isSensitive,
  }) = _NoteChannel;

  factory NoteChannel.fromJson(Map<String, dynamic> json) =>
      _$NoteChannelFromJson(json);
}
