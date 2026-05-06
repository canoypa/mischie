import 'package:mischie/core/api/misskey_api_client.dart';
import 'package:mischie/features/compose/domain/compose_notifier.dart';

class ComposeRepository {
  const ComposeRepository(this._client);

  final MisskeyApiClient _client;

  Future<void> postNote(
    String text, {
    String? cw,
    NoteVisibility visibility = NoteVisibility.public,
  }) async {
    final body = <String, dynamic>{
      'text': text,
      'visibility': visibility.name,
    };
    if (cw != null && cw.isNotEmpty) body['cw'] = cw;

    await _client.post('notes/create', body: body);
  }
}
