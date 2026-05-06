import 'package:mischie/core/api/misskey_api_client.dart';

class EmojiRepository {
  const EmojiRepository(this._client);

  final MisskeyApiClient _client;

  /// サーバーの全カスタム絵文字を name → url のマップで返す
  Future<Map<String, String>> fetchEmojis() async {
    final data = await _client.post('emojis');
    final list = data['emojis'] as List<dynamic>? ?? [];
    return {
      for (final e in list.cast<Map<String, dynamic>>())
        e['name'] as String: e['url'] as String,
    };
  }
}
