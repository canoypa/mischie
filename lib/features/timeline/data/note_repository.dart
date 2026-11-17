import 'package:mischie/core/api/misskey_api_client.dart';
import 'package:mischie/features/timeline/domain/note.dart';
import 'package:mischie/features/timeline/domain/user.dart';

class NoteState {
  const NoteState({required this.isFavorited, required this.isMutedThread});

  final bool isFavorited;
  final bool isMutedThread;
}

class NoteRepository {
  const NoteRepository(this._client);

  final MisskeyApiClient _client;

  Future<Note> show(String noteId) async {
    final data = await _client.post('notes/show', body: {'noteId': noteId});
    return Note.fromJson(data);
  }

  /// 直接の返信だけ。新しい順。
  Future<List<Note>> children(
    String noteId, {
    int limit = 30,
    String? untilId,
  }) async {
    final list = await _client.postList(
      'notes/children',
      body: {'noteId': noteId, 'limit': limit, 'untilId': ?untilId},
    );
    return list.map(Note.fromJson).toList();
  }

  /// 返信元をさかのぼった祖先。新しい順。
  Future<List<Note>> conversation(String noteId, {int limit = 30}) async {
    final list = await _client.postList(
      'notes/conversation',
      body: {'noteId': noteId, 'limit': limit},
    );
    return list.map(Note.fromJson).toList();
  }

  Future<void> react(String noteId, String reaction) => _client.postVoid(
    'notes/reactions/create',
    body: {'noteId': noteId, 'reaction': reaction},
  );

  Future<void> unreact(String noteId) =>
      _client.postVoid('notes/reactions/delete', body: {'noteId': noteId});

  Future<Note> renote(
    String noteId, {
    String? visibility,
    String? channelId,
  }) async {
    final data = await _client.post(
      'notes/create',
      body: {
        'renoteId': noteId,
        'visibility': ?visibility,
        'channelId': ?channelId,
      },
    );
    return Note.fromJson(data['createdNote'] as Map<String, dynamic>);
  }

  /// 引用も含む。
  Future<List<Note>> renotes(
    String noteId, {
    int limit = 30,
    String? untilId,
  }) async {
    final list = await _client.postList(
      'notes/renotes',
      body: {'noteId': noteId, 'limit': limit, 'untilId': ?untilId},
    );
    return list.map(Note.fromJson).toList();
  }

  /// [type] はリアクションのキー。100 件は 1 回で取れる上限。
  Future<List<User>> reactionUsers(String noteId, {String? type}) async {
    final list = await _client.postList(
      'notes/reactions',
      body: {'noteId': noteId, 'type': ?type, 'limit': 100},
    );
    return list
        .map((e) => e['user'])
        .whereType<Map<String, dynamic>>()
        .map(User.fromJson)
        .toList();
  }

  /// 続きの起点はノートではなく、お気に入りのレコードの ID。
  Future<({List<Note> notes, String? nextUntilId})> favorites({
    String? untilId,
  }) async {
    final list = await _client.postList(
      'i/favorites',
      body: {'limit': 20, 'untilId': ?untilId},
    );
    return (
      notes: list
          .map((e) => e['note'])
          .whereType<Map<String, dynamic>>()
          .map(Note.fromJson)
          .toList(),
      nextUntilId: list.isEmpty ? null : list.last['id'] as String?,
    );
  }

  Future<void> vote(String noteId, int choice) => _client.postVoid(
    'notes/polls/vote',
    body: {'noteId': noteId, 'choice': choice},
  );

  Future<void> delete(String noteId) =>
      _client.postVoid('notes/delete', body: {'noteId': noteId});

  Future<NoteState> state(String noteId) async {
    final data = await _client.post('notes/state', body: {'noteId': noteId});
    return NoteState(
      isFavorited: data['isFavorited'] as bool? ?? false,
      isMutedThread: data['isMutedThread'] as bool? ?? false,
    );
  }

  Future<void> favorite(String noteId) =>
      _client.postVoid('notes/favorites/create', body: {'noteId': noteId});

  Future<void> unfavorite(String noteId) =>
      _client.postVoid('notes/favorites/delete', body: {'noteId': noteId});

  Future<void> muteThread(String noteId) =>
      _client.postVoid('notes/thread-muting/create', body: {'noteId': noteId});

  Future<void> unmuteThread(String noteId) =>
      _client.postVoid('notes/thread-muting/delete', body: {'noteId': noteId});

  /// ピン留め状態は自分のユーザー情報にしか載っていない。
  Future<List<String>> pinnedNoteIds() async {
    final data = await _client.post('i');
    return (data['pinnedNoteIds'] as List<dynamic>? ?? const []).cast<String>();
  }

  Future<void> pin(String noteId) =>
      _client.postVoid('i/pin', body: {'noteId': noteId});

  Future<void> unpin(String noteId) =>
      _client.postVoid('i/unpin', body: {'noteId': noteId});

  Future<void> reportAbuse(String userId, String comment) => _client.postVoid(
    'users/report-abuse',
    body: {'userId': userId, 'comment': comment},
  );
}
