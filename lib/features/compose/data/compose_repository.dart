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
    List<String> fileIds = const [],
  }) async {
    final body = <String, dynamic>{
      'visibility': visibility.name,
      // 引用でない純粋なリノート以外は text を必ず送る
      if (text.isNotEmpty) 'text': text,
      if (cw != null && cw.isNotEmpty) 'cw': cw,
      'replyId': ?replyId,
      'renoteId': ?renoteId,
      if (fileIds.isNotEmpty) 'fileIds': fileIds,
    };

    await _client.post('notes/create', body: body);
  }

  /// 添付の説明（alt）とセンシティブ指定を更新する。
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

  /// 画像をドライブへ上げて、投稿に添付できる DriveFile を返す。
  Future<DriveFile> uploadFile(String path, {String? name}) async {
    final data = await _client.postMultipart(
      'drive/files/create',
      filePath: path,
      fileName: name,
    );
    return DriveFile.fromJson(data);
  }
}
