import 'package:mischie/core/api/misskey_api_client.dart';
import 'package:mischie/features/compose/domain/compose_notifier.dart';

class ComposeRepository {
  const ComposeRepository(this._client);

  final MisskeyApiClient _client;

  Future<void> postNote(
    String text, {
    String? cw,
    NoteVisibility visibility = NoteVisibility.public,
    String? replyId,
    String? renoteId,
  }) async {
    final body = <String, dynamic>{
      'visibility': visibility.name,
      // 引用でない純粋なリノート以外は text を必ず送る
      if (text.isNotEmpty) 'text': text,
      if (cw != null && cw.isNotEmpty) 'cw': cw,
      'replyId': ?replyId,
      'renoteId': ?renoteId,
    };

    await _client.post('notes/create', body: body);
  }
}
