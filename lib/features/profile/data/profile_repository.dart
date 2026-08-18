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

  /// フォロー中 / フォロワーの一覧。Following は followee / follower を
  /// 内側に持つので、必要な側のユーザーだけ取り出す。
  Future<List<UserDetailed>> fetchFollowing(
    String userId, {
    int limit = 30,
    String? untilId,
  }) => _fetchRelations(
    'users/following',
    userId,
    key: 'followee',
    limit: limit,
    untilId: untilId,
  );

  Future<List<UserDetailed>> fetchFollowers(
    String userId, {
    int limit = 30,
    String? untilId,
  }) => _fetchRelations(
    'users/followers',
    userId,
    key: 'follower',
    limit: limit,
    untilId: untilId,
  );

  Future<List<UserDetailed>> _fetchRelations(
    String endpoint,
    String userId, {
    required String key,
    required int limit,
    String? untilId,
  }) async {
    final list = await _client.postList(
      endpoint,
      body: {'userId': userId, 'limit': limit, 'untilId': ?untilId},
    );
    return list
        .map((e) => e[key])
        .whereType<Map<String, dynamic>>()
        .map(UserDetailed.fromJson)
        .toList();
  }

  Future<void> mute(String userId) =>
      _client.postVoid('mute/create', body: {'userId': userId});

  Future<void> unmute(String userId) =>
      _client.postVoid('mute/delete', body: {'userId': userId});

  Future<void> block(String userId) =>
      _client.postVoid('blocking/create', body: {'userId': userId});

  Future<void> unblock(String userId) =>
      _client.postVoid('blocking/delete', body: {'userId': userId});

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
