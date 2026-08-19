import 'package:mischie/core/api/misskey_api_client.dart';
import 'package:mischie/features/timeline/domain/note.dart';

/// 個々のノートに対する操作（取得・返信ツリー・リアクション・リノート・削除）。
class NoteRepository {
  const NoteRepository(this._client);

  final MisskeyApiClient _client;

  Future<Note> show(String noteId) async {
    final data = await _client.post('notes/show', body: {'noteId': noteId});
    return Note.fromJson(data);
  }

  /// このノートへの直接の返信一覧。
  Future<List<Note>> children(String noteId, {int limit = 30}) async {
    final list = await _client.postList(
      'notes/children',
      body: {'noteId': noteId, 'limit': limit},
    );
    return list.map(Note.fromJson).toList();
  }

  /// このノートより上（返信元をさかのぼった祖先）の一覧。新しい順で返る。
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

  Future<Note> renote(String noteId) async {
    final data = await _client.post('notes/create', body: {'renoteId': noteId});
    return Note.fromJson(data['createdNote'] as Map<String, dynamic>);
  }

  Future<void> unrenote(String noteId) =>
      _client.postVoid('notes/unrenote', body: {'noteId': noteId});

  Future<void> vote(String noteId, int choice) => _client.postVoid(
    'notes/polls/vote',
    body: {'noteId': noteId, 'choice': choice},
  );

  Future<void> delete(String noteId) =>
      _client.postVoid('notes/delete', body: {'noteId': noteId});
}
