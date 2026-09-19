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

  /// 本文も添付もリアクションも持たない、純粋なリノート（引用ではない）。
  bool get isPureRenote =>
      renote != null && (text == null || text!.isEmpty) && files.isEmpty;
}

/// 投票。締め切りが無い（expiresAt が null）ものもある。
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

  /// すでに投票したか。締め切り後と同じく、結果だけを見せる状態になる。
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

/// ノートが投稿されたチャンネル。
@freezed
sealed class NoteChannel with _$NoteChannel {
  const factory NoteChannel({
    required String id,
    @Default('') String name,
    String? color,
  }) = _NoteChannel;

  factory NoteChannel.fromJson(Map<String, dynamic> json) =>
      _$NoteChannelFromJson(json);
}
