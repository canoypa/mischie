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
    String? host,
    @Default(false) bool isCat,
    @Default(false) bool isBot,
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}
