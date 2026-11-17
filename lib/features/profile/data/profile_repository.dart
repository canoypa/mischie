import 'package:mischie/core/api/misskey_api_client.dart';
import 'package:mischie/features/profile/domain/user_detailed.dart';
import 'package:mischie/features/profile/domain/user_relation_page.dart';
import 'package:mischie/features/timeline/domain/note.dart';

class ProfileRepository {
  const ProfileRepository(this._client);

  final MisskeyApiClient _client;

  Future<UserDetailed> fetchUser(String userId) async {
    final data = await _client.post('users/show', body: {'userId': userId});
    return UserDetailed.fromJson(data);
  }

  Future<UserDetailed> fetchUserByAcct(String username, {String? host}) async {
    final data = await _client.post(
      'users/show',
      body: {'username': username, 'host': ?host},
    );
    return UserDetailed.fromJson(data);
  }

  Future<UserRelationPage> fetchFollowing(
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

  Future<UserRelationPage> fetchFollowers(
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

  Future<UserRelationPage> _fetchRelations(
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
    return UserRelationPage(
      users: list
          .map((e) => e[key])
          .whereType<Map<String, dynamic>>()
          .map(UserDetailed.fromJson)
          .toList(),
      nextUntilId: list.isEmpty ? null : list.last['id'] as String?,
    );
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

  Future<void> cancelFollowRequest(String userId) =>
      _client.postVoid('following/requests/cancel', body: {'userId': userId});

  Future<List<Note>> fetchUserNotes(
    String userId, {
    int limit = 20,
    String? untilId,
    UserNotesFilter filter = UserNotesFilter.notes,
  }) async {
    final body = <String, dynamic>{
      'userId': userId,
      'limit': limit,
      'withReplies': filter == UserNotesFilter.withReplies,
      'withFiles': filter == UserNotesFilter.files,
      'untilId': ?untilId,
    };
    final list = await _client.postList('users/notes', body: body);
    return list.map(Note.fromJson).toList();
  }
}

/// 返信とファイルは同時に指定できない。
enum UserNotesFilter {
  notes('ノート'),
  withReplies('返信を含む'),
  files('ファイル');

  const UserNotesFilter(this.label);

  final String label;
}
