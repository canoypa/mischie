import 'package:flutter_test/flutter_test.dart';
import 'package:mischie/core/api/misskey_api_client.dart';
import 'package:mischie/features/profile/data/profile_repository.dart';

class _FakeClient extends MisskeyApiClient {
  _FakeClient(this.response)
    : super(host: 'example.test', getToken: () async => null);

  final List<Map<String, dynamic>> response;
  String? lastPath;
  Map<String, dynamic>? lastBody;

  @override
  Future<List<Map<String, dynamic>>> postList(
    String path, {
    Map<String, dynamic>? body,
  }) async {
    lastPath = path;
    lastBody = body;
    return response;
  }
}

Map<String, dynamic> _following(String recordId, String userId) => {
  'id': recordId,
  'followeeId': userId,
  'followee': {'id': userId, 'username': 'user_$userId'},
  'followerId': 'me',
  'follower': {'id': 'me', 'username': 'me'},
};

void main() {
  test('フォロー中の続きはユーザー ID ではなく Following の ID から取る', () async {
    final client = _FakeClient([
      _following('record2', 'userB'),
      _following('record1', 'userA'),
    ]);
    final repo = ProfileRepository(client);

    final page = await repo.fetchFollowing('me');

    expect(page.users.map((u) => u.id), ['userB', 'userA']);
    expect(page.nextUntilId, 'record1');

    await repo.fetchFollowing('me', untilId: page.nextUntilId);
    expect(client.lastPath, 'users/following');
    expect(client.lastBody?['untilId'], 'record1');
  });

  test('フォロワーは follower 側のユーザーを返し、同じく Following の ID を持つ', () async {
    final client = _FakeClient([
      {
        'id': 'record9',
        'followeeId': 'me',
        'followee': {'id': 'me', 'username': 'me'},
        'followerId': 'userC',
        'follower': {'id': 'userC', 'username': 'user_userC'},
      },
    ]);

    final page = await ProfileRepository(client).fetchFollowers('me');

    expect(page.users.single.id, 'userC');
    expect(page.nextUntilId, 'record9');
    expect(client.lastPath, 'users/followers');
  });

  test('空のページは続きを持たない', () async {
    final page = await ProfileRepository(_FakeClient([])).fetchFollowing('me');

    expect(page.users, isEmpty);
    expect(page.nextUntilId, isNull);
  });
}
