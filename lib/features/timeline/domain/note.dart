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
    Note? reply,
    Note? renote,
    String? uri,
    String? url,
    String? channelId,
    NoteChannel? channel,
    Poll? poll,
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

  bool get isPureRenote =>
      renote != null &&
      replyId == null &&
      text == null &&
      cw == null &&
      files.isEmpty &&
      poll == null;
}

/// expiresAt が null なら締め切りなし。
@freezed
sealed class Poll with _$Poll {
  const factory Poll({
    @Default([]) List<PollChoice> choices,
    @Default(false) bool multiple,
    String? expiresAt,
  }) = _Poll;

  const Poll._();

  factory Poll.fromJson(Map<String, dynamic> json) => _$PollFromJson(json);

  int get totalVotes => choices.fold(0, (sum, choice) => sum + choice.votes);

  bool get isExpired {
    final at = expiresAt;
    if (at == null) return false;
    return DateTime.parse(at).isBefore(DateTime.now());
  }

  bool get hasVoted => choices.any((choice) => choice.isVoted);
}

@freezed
sealed class PollChoice with _$PollChoice {
  const factory PollChoice({
    @Default('') String text,
    @Default(0) int votes,
    @Default(false) bool isVoted,
  }) = _PollChoice;

  factory PollChoice.fromJson(Map<String, dynamic> json) =>
      _$PollChoiceFromJson(json);
}

@freezed
sealed class NoteChannel with _$NoteChannel {
  const factory NoteChannel({
    required String id,
    @Default('') String name,
    String? color,
    @Default(false) bool isSensitive,
    @Default(true) bool allowRenoteToExternal,
  }) = _NoteChannel;

  factory NoteChannel.fromJson(Map<String, dynamic> json) =>
      _$NoteChannelFromJson(json);
}
