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

    /// アイコンのぼかし表現。猫耳の色をここから取る。
    String? avatarBlurhash,
    String? host,
    @Default(false) bool isCat,
    @Default(false) bool isBot,
    @Default([]) List<AvatarDecoration> avatarDecorations,
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}

/// アイコンに重ねる装飾。Misskey 側で位置・角度・反転を指定できる。
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
