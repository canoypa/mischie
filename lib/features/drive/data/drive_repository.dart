import 'package:mischie/core/api/misskey_api_client.dart';
import 'package:mischie/features/drive/domain/drive_folder.dart';
import 'package:mischie/features/drive/domain/drive_page.dart';
import 'package:mischie/features/timeline/domain/drive_file.dart';

class DriveRepository {
  const DriveRepository(this._client);

  final MisskeyApiClient _client;

  Future<DriveUsage> fetchUsage() async {
    final data = await _client.post('drive');
    return DriveUsage(
      usage: (data['usage'] as num).toInt(),
      capacity: (data['capacity'] as num).toInt(),
    );
  }

  /// [folderId] が null のときはルート。
  Future<DrivePage<DriveFolder>> fetchFolders({
    String? folderId,
    int limit = 100,
    String? untilId,
  }) async {
    final list = await _client.postList(
      'drive/folders',
      body: {'folderId': folderId, 'limit': limit, 'untilId': ?untilId},
    );
    return _page(list.map(DriveFolder.fromJson).toList(), limit, (f) => f.id);
  }

  Future<DrivePage<DriveFile>> fetchFiles({
    String? folderId,
    int limit = 30,
    String? untilId,
  }) async {
    final list = await _client.postList(
      'drive/files',
      body: {'folderId': folderId, 'limit': limit, 'untilId': ?untilId},
    );
    return _page(list.map(DriveFile.fromJson).toList(), limit, (f) => f.id);
  }

  Future<DriveFolder> createFolder(String name, {String? parentId}) async {
    final data = await _client.post(
      'drive/folders/create',
      body: {'name': name, 'parentId': parentId},
    );
    return DriveFolder.fromJson(data);
  }

  Future<DriveFolder> renameFolder(String folderId, String name) async {
    final data = await _client.post(
      'drive/folders/update',
      body: {'folderId': folderId, 'name': name},
    );
    return DriveFolder.fromJson(data);
  }

  Future<void> deleteFolder(String folderId) =>
      _client.postVoid('drive/folders/delete', body: {'folderId': folderId});

  Future<DriveFile> renameFile(String fileId, String name) =>
      _updateFile({'fileId': fileId, 'name': name});

  Future<DriveFile> setSensitive(String fileId, bool isSensitive) =>
      _updateFile({'fileId': fileId, 'isSensitive': isSensitive});

  /// 空文字は説明を消す扱いで、サーバーには null を送る。
  Future<DriveFile> setComment(String fileId, String comment) => _updateFile({
    'fileId': fileId,
    'comment': comment.isEmpty ? null : comment,
  });

  Future<void> deleteFile(String fileId) =>
      _client.postVoid('drive/files/delete', body: {'fileId': fileId});

  Future<DriveFile> _updateFile(Map<String, dynamic> body) async =>
      DriveFile.fromJson(await _client.post('drive/files/update', body: body));

  /// 件数がページの大きさに満たなければ、そこが末尾。
  DrivePage<T> _page<T>(List<T> items, int limit, String Function(T) idOf) =>
      DrivePage(
        items,
        nextUntilId: items.length < limit ? null : idOf(items.last),
      );
}
