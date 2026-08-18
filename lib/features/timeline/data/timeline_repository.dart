import 'package:mischie/core/api/misskey_api_client.dart';
import 'package:mischie/features/timeline/domain/note.dart';
import 'package:mischie/features/timeline/domain/timeline_kind.dart';

class TimelineRepository {
  const TimelineRepository(this._client);

  final MisskeyApiClient _client;

  Future<List<Note>> fetchTimeline(
    TimelineKind kind, {
    int limit = 20,
    String? untilId,
  }) async {
    final body = <String, dynamic>{'limit': limit, 'untilId': ?untilId};
    final list = await _client.postList(kind.endpoint, body: body);
    return list.map(Note.fromJson).toList();
  }
}
