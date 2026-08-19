import 'package:mischie/core/api/misskey_api_client.dart';
import 'package:mischie/features/profile/domain/user_detailed.dart';
import 'package:mischie/features/timeline/domain/note.dart';

class SearchRepository {
  const SearchRepository(this._client);

  final MisskeyApiClient _client;

  Future<List<Note>> searchNotes(
    String query, {
    int limit = 20,
    String? untilId,
  }) async {
    final list = await _client.postList(
      'notes/search',
      body: {'query': query, 'limit': limit, 'untilId': ?untilId},
    );
    return list.map(Note.fromJson).toList();
  }

  Future<List<UserDetailed>> searchUsers(
    String query, {
    int limit = 20,
    int offset = 0,
  }) async {
    final list = await _client.postList(
      'users/search',
      body: {'query': query, 'limit': limit, 'offset': offset},
    );
    return list.map(UserDetailed.fromJson).toList();
  }
}
