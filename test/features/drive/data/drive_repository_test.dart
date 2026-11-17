import 'package:flutter_test/flutter_test.dart';
import 'package:mischie/core/api/misskey_api_client.dart';
import 'package:mischie/features/drive/data/drive_repository.dart';

class _FakeClient extends MisskeyApiClient {
  _FakeClient({this.object = const {}, this.list = const []})
    : super(host: 'example.test', getToken: () async => null);

  final Map<String, dynamic> object;
  final List<Map<String, dynamic>> list;
  String? lastPath;
  Map<String, dynamic>? lastBody;

  @override
  Future<Map<String, dynamic>> post(
    String path, {
    Map<String, dynamic>? body,
  }) async {
    lastPath = path;
    lastBody = body;
    return object;
  }

  @override
  Future<void> postVoid(String path, {Map<String, dynamic>? body}) async {
    lastPath = path;
    lastBody = body;
  }

  @override
  Future<List<Map<String, dynamic>>> postList(
    String path, {
    Map<String, dynamic>? body,
  }) async {
    lastPath = path;
    lastBody = body;
    return list;
  }
}

Map<String, dynamic> _file(String id, {String? name}) => {
  'id': id,
  'type': 'image/png',
  'url': 'https://example.test/$id.png',
  'name': ?name,
  'size': 2048,
  'folderId': null,
};

void main() {
  test('ルートのファイルは folderId を null で取り、満杯のページには続きがある', () async {
    final client = _FakeClient(list: [_file('f2'), _file('f1')]);

    final page = await DriveRepository(client).fetchFiles(limit: 2);

    expect(client.lastPath, 'drive/files');
    expect(client.lastBody, {'folderId': null, 'limit': 2});
    expect(page.items.map((f) => f.id), ['f2', 'f1']);
    expect(page.items.first.size, 2048);
    expect(page.nextUntilId, 'f1');
  });

  test('ページに満たなければ続きは無く、続きを取るときは untilId を送る', () async {
    final client = _FakeClient(list: [_file('f1')]);
    final repo = DriveRepository(client);

    final page = await repo.fetchFiles(
      folderId: 'dir',
      limit: 2,
      untilId: 'f2',
    );

    expect(client.lastBody, {'folderId': 'dir', 'limit': 2, 'untilId': 'f2'});
    expect(page.nextUntilId, isNull);
  });

  test('フォルダは folderId の直下を取り、名前と親を読む', () async {
    final client = _FakeClient(
      list: [
        {'id': 'd1', 'name': '写真', 'parentId': 'root1'},
      ],
    );

    final page = await DriveRepository(client).fetchFolders(folderId: 'root1');

    expect(client.lastPath, 'drive/folders');
    expect(client.lastBody?['folderId'], 'root1');
    expect(page.items.single.name, '写真');
    expect(page.items.single.parentId, 'root1');
    expect(page.nextUntilId, isNull);
  });

  test('使用量と容量を読む', () async {
    final client = _FakeClient(object: {'usage': 1500, 'capacity': 3000.0});

    final usage = await DriveRepository(client).fetchUsage();

    expect(client.lastPath, 'drive');
    expect(usage.usage, 1500);
    expect(usage.capacity, 3000);
    expect(usage.ratio, 0.5);
  });

  test('ファイルの更新は変えたい項目だけを送る', () async {
    final client = _FakeClient(object: _file('f1', name: 'a.png'));
    final repo = DriveRepository(client);

    await repo.renameFile('f1', 'a.png');
    expect(client.lastPath, 'drive/files/update');
    expect(client.lastBody, {'fileId': 'f1', 'name': 'a.png'});

    await repo.setSensitive('f1', true);
    expect(client.lastBody, {'fileId': 'f1', 'isSensitive': true});
  });

  test('説明を空にすると null を送って消す', () async {
    final client = _FakeClient(object: _file('f1'));
    final repo = DriveRepository(client);

    await repo.setComment('f1', '');
    expect(client.lastBody, {'fileId': 'f1', 'comment': null});

    await repo.setComment('f1', '猫');
    expect(client.lastBody, {'fileId': 'f1', 'comment': '猫'});
  });

  test('フォルダの作成・名前変更・削除', () async {
    final client = _FakeClient(
      object: {'id': 'd1', 'name': '新規', 'parentId': null},
    );
    final repo = DriveRepository(client);

    final created = await repo.createFolder('新規', parentId: 'p1');
    expect(client.lastPath, 'drive/folders/create');
    expect(client.lastBody, {'name': '新規', 'parentId': 'p1'});
    expect(created.id, 'd1');

    await repo.renameFolder('d1', '改名');
    expect(client.lastPath, 'drive/folders/update');
    expect(client.lastBody, {'folderId': 'd1', 'name': '改名'});

    await repo.deleteFolder('d1');
    expect(client.lastPath, 'drive/folders/delete');
    expect(client.lastBody, {'folderId': 'd1'});
  });

  test('ファイルの削除', () async {
    final client = _FakeClient();

    await DriveRepository(client).deleteFile('f1');

    expect(client.lastPath, 'drive/files/delete');
    expect(client.lastBody, {'fileId': 'f1'});
  });
}
