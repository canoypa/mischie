import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';
part 'user.g.dart';

@freezed
sealed class User with _$User {
  const factory User({
    required String id,
    required String username,
    String? name,
    String? avatarUrl,

    String? avatarBlurhash,
    String? host,
    @Default(false) bool isCat,
    @Default(false) bool isBot,
    @Default([]) List<AvatarDecoration> avatarDecorations,
  }) = _User;

  const User._();

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  String get acct => host != null ? '@$username@$host' : '@$username';
}

@freezed
sealed class AvatarDecoration with _$AvatarDecoration {
  const factory AvatarDecoration({
    required String id,
    required String url,
    @Default(0) double angle,
    @Default(false) bool flipH,
    @Default(0) double offsetX,
    @Default(0) double offsetY,
  }) = _AvatarDecoration;

  factory AvatarDecoration.fromJson(Map<String, dynamic> json) =>
      _$AvatarDecorationFromJson(json);
}
