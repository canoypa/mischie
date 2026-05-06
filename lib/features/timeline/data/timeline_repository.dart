import 'package:mischie/core/api/misskey_api_client.dart';
import 'package:mischie/features/timeline/domain/note.dart';

class TimelineRepository {
  const TimelineRepository(this._client);

  final MisskeyApiClient _client;

  Future<List<Note>> fetchHomeTimeline({
    int limit = 20,
    String? untilId,
  }) async {
    final body = <String, dynamic>{'limit': limit};
    if (untilId != null) body['untilId'] = untilId;

    final list = await _client.postList('notes/timeline', body: body);
    return list.map(Note.fromJson).toList();
  }
}
