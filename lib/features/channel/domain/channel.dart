import 'package:freezed_annotation/freezed_annotation.dart';

part 'channel.freezed.dart';
part 'channel.g.dart';

@freezed
sealed class Channel with _$Channel {
  const factory Channel({
    required String id,
    @Default('') String name,
    String? description,
    String? bannerUrl,
    String? color,
    @Default(0) int usersCount,
    @Default(0) int notesCount,
    @Default(false) bool isFollowing,
    @Default(false) bool isFavorited,
    @Default(false) bool isArchived,
    @Default(false) bool isSensitive,
  }) = _Channel;

  factory Channel.fromJson(Map<String, dynamic> json) =>
      _$ChannelFromJson(json);
}
