import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:mischie/features/timeline/domain/user.dart';

part 'user_detailed.freezed.dart';
part 'user_detailed.g.dart';

@freezed
sealed class UserDetailed with _$UserDetailed {
  const factory UserDetailed({
    required String id,
    required String username,
    String? name,
    String? host,
    String? avatarUrl,
    String? bannerUrl,
    String? bannerBlurhash,
    String? description,
    String? location,
    String? birthday,
    String? createdAt,
    @Default(false) bool isBot,
    @Default(false) bool isCat,
    @Default(false) bool isFollowing,
    @Default(false) bool isFollowed,
    @Default(false) bool isMuted,
    @Default(false) bool isBlocking,
    @Default([]) List<AvatarDecoration> avatarDecorations,
    int? followersCount,
    int? followingCount,
    int? notesCount,
    @Default([]) List<ProfileField> fields,
    @Default([]) List<UserRole> roles,
    @Default({}) Map<String, String> emojis,
  }) = _UserDetailed;

  factory UserDetailed.fromJson(Map<String, dynamic> json) =>
      _$UserDetailedFromJson(json);
}

@freezed
sealed class ProfileField with _$ProfileField {
  const factory ProfileField({
    @Default('') String name,
    @Default('') String value,
  }) = _ProfileField;

  factory ProfileField.fromJson(Map<String, dynamic> json) =>
      _$ProfileFieldFromJson(json);
}

@freezed
sealed class UserRole with _$UserRole {
  const factory UserRole({
    required String id,
    @Default('') String name,
    String? color,
    String? iconUrl,
  }) = _UserRole;

  factory UserRole.fromJson(Map<String, dynamic> json) =>
      _$UserRoleFromJson(json);
}
