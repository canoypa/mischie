import 'package:mischie/features/profile/domain/user_detailed.dart';

class UserRelationPage {
  const UserRelationPage({required this.users, required this.nextUntilId});

  final List<UserDetailed> users;

  /// ユーザーの ID ではなく、フォロー関係の ID。
  final String? nextUntilId;
}
