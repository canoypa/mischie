import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mischie/core/api/misskey_api_client.dart';
import 'package:mischie/features/drive/data/drive_repository.dart';
import 'package:mischie/features/drive/domain/drive_providers.dart';
import 'package:mischie/features/drive/presentation/drive_screen.dart';
import 'package:mischie/features/timeline/domain/drive_file.dart';

class _FakeClient extends MisskeyApiClient {
  _FakeClient() : super(host: 'example.test', getToken: () async => null);

  final calls = <String>[];

  @override
  Future<Map<String, dynamic>> post(
    String path, {
    Map<String, dynamic>? body,
  }) async {
    calls.add(path);
    return {'usage': 512 * 1024 * 1024, 'capacity': 1024 * 1024 * 1024};
  }

  @override
  Future<List<Map<String, dynamic>>> postList(
    String path, {
    Map<String, dynamic>? body,
  }) async {
    calls.add(path);
    return switch (path) {
      'drive/folders' => [
        {'id': 'd1', 'name': '写真'},
      ],
      'drive/files' => [
        {
          'id': 'f1',
          'type': 'application/pdf',
          'url': 'https://example.test/f1.pdf',
          'name': '請求書.pdf',
        },
        {
          'id': 'f2',
          'type': 'audio/mpeg',
          'url': 'https://example.test/f2.mp3',
          'name': '曲.mp3',
        },
      ],
      _ => [],
    };
  }
}

Widget _app(Widget home, _FakeClient client) => ProviderScope(
  overrides: [
    driveRepositoryProvider.overrideWithValue(DriveRepository(client)),
  ],
  child: MaterialApp(home: home),
);

void main() {
  testWidgets('フォルダとファイルと使用量を並べる', (tester) async {
    await tester.pumpWidget(_app(const DriveScreen(), _FakeClient()));
    await tester.pumpAndSettle();

    expect(find.text('ドライブ'), findsOneWidget);
    expect(find.text('写真'), findsOneWidget);
    expect(find.text('請求書.pdf'), findsOneWidget);
    expect(find.text('曲.mp3'), findsOneWidget);
    expect(find.text('512 MB / 1.0 GB'), findsOneWidget);
    expect(find.byType(LinearProgressIndicator), findsOneWidget);
  });

  testWidgets('空のドライブには案内を出す', (tester) async {
    final client = _EmptyClient();
    await tester.pumpWidget(_app(const DriveScreen(), client));
    await tester.pumpAndSettle();

    expect(find.text('ファイルはありません'), findsOneWidget);
  });

  testWidgets('ファイルを押すと操作のシートが開く', (tester) async {
    // 全項目が画面に収まる高さにする
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(800, 1600);
    addTearDown(tester.view.reset);
    await tester.pumpWidget(_app(const DriveScreen(), _FakeClient()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('請求書.pdf'));
    await tester.pumpAndSettle();

    for (final label in ['開く', 'センシティブにする', '名前を変更', '説明を編集', '削除']) {
      expect(find.text(label), findsOneWidget);
    }
  });

  testWidgets('選択モードでは押したファイルを選び、決定で返す', (tester) async {
    List<DriveFile>? picked;
    await tester.pumpWidget(
      _app(
        Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () async => picked = await pickDriveFiles(context),
              child: const Text('選ぶ'),
            ),
          ),
        ),
        _FakeClient(),
      ),
    );
    await tester.tap(find.text('選ぶ'));
    await tester.pumpAndSettle();

    expect(find.text('決定 (0)'), findsOneWidget);
    await tester.tap(find.text('請求書.pdf'));
    await tester.pump();
    expect(find.text('決定 (1)'), findsOneWidget);
    expect(find.byIcon(Icons.check_circle), findsOneWidget);

    await tester.tap(find.text('決定 (1)'));
    await tester.pumpAndSettle();

    expect(picked?.map((f) => f.id), ['f1']);
  });
}

class _EmptyClient extends _FakeClient {
  @override
  Future<List<Map<String, dynamic>>> postList(
    String path, {
    Map<String, dynamic>? body,
  }) async => [];
}
