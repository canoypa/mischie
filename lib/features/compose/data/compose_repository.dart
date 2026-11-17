import 'package:mischie/core/api/misskey_api_client.dart';
import 'package:mischie/features/timeline/domain/drive_file.dart';
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
    String? channelId,
    List<String> fileIds = const [],
    List<String> pollChoices = const [],
    bool pollMultiple = false,
    Duration? pollDuration,
  }) async {
    final body = <String, dynamic>{
      'visibility': visibility.name,
      if (text.isNotEmpty) 'text': text,
      if (cw != null && cw.isNotEmpty) 'cw': cw,
      'replyId': ?replyId,
      'renoteId': ?renoteId,
      'channelId': ?channelId,
      if (fileIds.isNotEmpty) 'fileIds': fileIds,
      // 選択肢は 2 つ以上でないとサーバーが受け取らない
      if (pollChoices.length >= 2)
        'poll': {
          'choices': pollChoices,
          'multiple': pollMultiple,
          'expiredAfter': ?pollDuration?.inMilliseconds,
        },
    };

    await _client.post('notes/create', body: body);
  }

  Future<void> updateFile(
    String fileId, {
    String? comment,
    bool? isSensitive,
  }) => _client.postVoid(
    'drive/files/update',
    body: {
      'fileId': fileId,
      'comment': comment ?? '',
      'isSensitive': ?isSensitive,
    },
  );

  Future<DriveFile> uploadFile(String path, {String? name}) async {
    final data = await _client.postMultipart(
      'drive/files/create',
      filePath: path,
      fileName: name,
    );
    return DriveFile.fromJson(data);
  }
}
