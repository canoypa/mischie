import 'package:flutter_test/flutter_test.dart';
import 'package:mischie/core/api/misskey_api_client.dart';
import 'package:mischie/features/timeline/data/note_repository.dart';

class _RecordingClient extends MisskeyApiClient {
  _RecordingClient({this.response = const {}})
    : super(host: 'example.test', getToken: () async => null);

  final Map<String, dynamic> response;
  final List<(String, Map<String, dynamic>?)> requests = [];

  @override
  Future<Map<String, dynamic>> post(
    String path, {
    Map<String, dynamic>? body,
  }) async {
    requests.add((path, body));
    return response;
  }

  @override
  Future<void> postVoid(String path, {Map<String, dynamic>? body}) async {
    requests.add((path, body));
  }
}

const _createdNote = {
  'createdNote': {
    'id': 'renote1',
    'createdAt': '2026-08-18T00:00:00.000Z',
    'user': {'id': 'me', 'username': 'me'},
  },
};

void main() {
  group('NoteRepository.renote', () {
    test('公開範囲もチャンネルも渡さなければ renoteId だけ送る', () async {
      final client = _RecordingClient(response: _createdNote);

      await NoteRepository(client).renote('note1');

      expect(client.requests.single.$1, 'notes/create');
      expect(client.requests.single.$2, {'renoteId': 'note1'});
    });

    test('公開範囲を渡すと visibility を送る', () async {
      final client = _RecordingClient(response: _createdNote);

      await NoteRepository(client).renote('note1', visibility: 'home');

      expect(client.requests.single.$2, {
        'renoteId': 'note1',
        'visibility': 'home',
      });
    });

    test('チャンネルを渡すと channelId を送る', () async {
      final client = _RecordingClient(response: _createdNote);

      await NoteRepository(client).renote('note1', channelId: 'ch1');

      expect(client.requests.single.$2, {
        'renoteId': 'note1',
        'channelId': 'ch1',
      });
    });
  });

  group('NoteRepository', () {
    test('お気に入り・スレッドミュート・ピン留めの宛先と引数', () async {
      final client = _RecordingClient();
      final repo = NoteRepository(client);

      await repo.favorite('n');
      await repo.unfavorite('n');
      await repo.muteThread('n');
      await repo.unmuteThread('n');
      await repo.pin('n');
      await repo.unpin('n');

      expect(client.requests.map((r) => r.$1), [
        'notes/favorites/create',
        'notes/favorites/delete',
        'notes/thread-muting/create',
        'notes/thread-muting/delete',
        'i/pin',
        'i/unpin',
      ]);
      expect(client.requests.every((r) => r.$2!['noteId'] == 'n'), isTrue);
    });

    test('通報は userId と comment を送る', () async {
      final client = _RecordingClient();

      await NoteRepository(client).reportAbuse('user1', '迷惑');

      expect(client.requests.single.$1, 'users/report-abuse');
      expect(client.requests.single.$2, {'userId': 'user1', 'comment': '迷惑'});
    });

    test('notes/state の応答を読む', () async {
      final client = _RecordingClient(
        response: {'isFavorited': true, 'isMutedThread': false},
      );

      final state = await NoteRepository(client).state('n');

      expect(client.requests.single.$1, 'notes/state');
      expect(client.requests.single.$2, {'noteId': 'n'});
      expect(state.isFavorited, isTrue);
      expect(state.isMutedThread, isFalse);
    });

    test('ピン留めの一覧はログイン中のユーザー情報から取る', () async {
      final client = _RecordingClient(
        response: {
          'pinnedNoteIds': ['a', 'b'],
        },
      );

      final ids = await NoteRepository(client).pinnedNoteIds();

      expect(client.requests.single.$1, 'i');
      expect(ids, ['a', 'b']);
    });
  });
}
