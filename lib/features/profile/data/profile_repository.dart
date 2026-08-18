import 'package:mischie/core/api/misskey_api_client.dart';
import 'package:mischie/features/profile/domain/user_detailed.dart';
import 'package:mischie/features/timeline/domain/note.dart';
import 'package:mischie/features/timeline/domain/user.dart';

class ProfileRepository {
  const ProfileRepository(this._client);

  final MisskeyApiClient _client;

  Future<User> fetchMe() async {
    final data = await _client.post('i');
    return User.fromJson(data);
  }

  Future<UserDetailed> fetchUser(String userId) async {
    final data = await _client.post('users/show', body: {'userId': userId});
    return UserDetailed.fromJson(data);
  }

  /// `@user` / `@user@host` からユーザーを引く。
  Future<UserDetailed> fetchUserByAcct(String username, {String? host}) async {
    final data = await _client.post(
      'users/show',
      body: {'username': username, 'host': ?host},
    );
    return UserDetailed.fromJson(data);
  }

  Future<void> follow(String userId) =>
      _client.postVoid('following/create', body: {'userId': userId});

  Future<void> unfollow(String userId) =>
      _client.postVoid('following/delete', body: {'userId': userId});

  Future<List<Note>> fetchUserNotes(
    String userId, {
    int limit = 20,
    String? untilId,
  }) async {
    final body = <String, dynamic>{
      'userId': userId,
      'limit': limit,
      'withReplies': false,
      'untilId': ?untilId,
    };
    final list = await _client.postList('users/notes', body: body);
    return list.map(Note.fromJson).toList();
  }
}
