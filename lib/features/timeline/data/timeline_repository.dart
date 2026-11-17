import 'package:mischie/core/api/misskey_api_client.dart';
import 'package:mischie/features/timeline/domain/note.dart';
import 'package:mischie/features/timeline/domain/timeline_source.dart';
import 'package:mischie/features/timeline/domain/user_list.dart';

class TimelineRepository {
  const TimelineRepository(this._client);

  final MisskeyApiClient _client;

  Future<List<Note>> fetchTimeline(
    TimelineSource source, {
    int limit = 20,
    String? untilId,
    String? sinceId,
  }) async {
    final body = <String, dynamic>{
      'limit': limit,
      'untilId': ?untilId,
      'sinceId': ?sinceId,
      ...source.params,
    };
    final list = await _client.postList(source.endpoint, body: body);
    return list.map(Note.fromJson).toList();
  }

  Future<List<UserList>> fetchLists() async {
    final list = await _client.postList('users/lists/list');
    return list.map(UserList.fromJson).toList();
  }
}
