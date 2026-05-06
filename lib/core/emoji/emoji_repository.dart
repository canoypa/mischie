import 'package:mischie/core/api/misskey_api_client.dart';

class EmojiRepository {
  const EmojiRepository(this._client);

  final MisskeyApiClient _client;

  /// サーバーの全カスタム絵文字を name → url のマップで返す。
  ///
  /// 外部サーバーの絵文字は "name@server.tld" 形式のキーで登録されているため、
  /// "name" だけでも引けるよう短縮形エントリも追加する（短縮形が衝突する場合は
  /// 既存エントリを優先する）。
  Future<Map<String, String>> fetchEmojis() async {
    final data = await _client.post('emojis');
    final list = data['emojis'] as List<dynamic>? ?? [];
    final map = <String, String>{
      for (final e in list.cast<Map<String, dynamic>>())
        e['name'] as String: e['url'] as String,
    };
    // "name@server.tld" → "name" のフォールバックエントリを追加
    final fallbacks = <String, String>{};
    for (final entry in map.entries) {
      final atIndex = entry.key.indexOf('@');
      if (atIndex > 0) {
        final shortName = entry.key.substring(0, atIndex);
        fallbacks.putIfAbsent(shortName, () => entry.value);
      }
    }
    return {...fallbacks, ...map};
  }
}
