import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_list.freezed.dart';
part 'user_list.g.dart';

@freezed
sealed class UserList with _$UserList {
  const factory UserList({required String id, @Default('無題') String name}) =
      _UserList;

  factory UserList.fromJson(Map<String, dynamic> json) =>
      _$UserListFromJson(json);
}
