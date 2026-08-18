import 'package:mischie/core/api/misskey_api_client.dart';
import 'package:mischie/features/channel/domain/channel.dart';
import 'package:mischie/features/timeline/domain/note.dart';

class ChannelRepository {
  const ChannelRepository(this._client);

  final MisskeyApiClient _client;

  Future<Channel> show(String channelId) async {
    final data = await _client.post(
      'channels/show',
      body: {'channelId': channelId},
    );
    return Channel.fromJson(data);
  }

  Future<List<Note>> timeline(
    String channelId, {
    int limit = 20,
    String? untilId,
  }) async {
    final list = await _client.postList(
      'channels/timeline',
      body: {'channelId': channelId, 'limit': limit, 'untilId': ?untilId},
    );
    return list.map(Note.fromJson).toList();
  }

  Future<void> follow(String channelId) =>
      _client.postVoid('channels/follow', body: {'channelId': channelId});

  Future<void> unfollow(String channelId) =>
      _client.postVoid('channels/unfollow', body: {'channelId': channelId});
}
