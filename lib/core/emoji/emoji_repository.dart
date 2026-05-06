import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:mischie/core/api/misskey_api_client.dart';

class EmojiRepository {
  const EmojiRepository(this._client);

  final MisskeyApiClient _client;

  static const _cacheFileName = 'emoji_cache.json';

  Future<File> _cacheFile() async {
    final dir = await getApplicationCacheDirectory();
    return File('${dir.path}/$_cacheFileName');
  }

  /// ディスクキャッシュを読み込む。失敗時は null を返す。
  Future<({String? updatedAt, Map<String, String> emojis})?> _loadDisk() async {
    try {
      final file = await _cacheFile();
      if (!await file.exists()) return null;
      final json = jsonDecode(await file.readAsString()) as Map<String, dynamic>;
      return (
        updatedAt: json['updatedAt'] as String?,
        emojis: (json['emojis'] as Map<String, dynamic>).cast<String, String>(),
      );
    } catch (_) {
      return null;
    }
  }

  /// ディスクキャッシュに保存する。失敗しても無視。
  Future<void> _saveDisk(String updatedAt, Map<String, String> emojis) async {
    try {
      final file = await _cacheFile();
      await file.writeAsString(jsonEncode({
        'updatedAt': updatedAt,
        'emojis': emojis,
      }));
    } catch (_) {}
  }

  /// /api/meta から emojisUpdatedAt だけ取得する。
  Future<String?> _fetchEmojisUpdatedAt() async {
    try {
      final data = await _client.post('meta');
      return data['emojisUpdatedAt'] as String?;
    } catch (_) {
      return null;
    }
  }

  /// サーバーの全カスタム絵文字を name → url のマップで返す。
  ///
  /// ディスクキャッシュが存在し /api/meta の emojisUpdatedAt と一致する場合は
  /// キャッシュをそのまま返す。更新がある場合のみ /api/emojis を再取得する。
  Future<Map<String, String>> fetchEmojis() async {
    final cache = await _loadDisk();
    final serverUpdatedAt = await _fetchEmojisUpdatedAt();

    // キャッシュが有効なら即返す
    if (cache != null &&
        cache.emojis.isNotEmpty &&
        serverUpdatedAt != null &&
        serverUpdatedAt == cache.updatedAt) {
      return _withFallbacks(cache.emojis);
    }

    // 更新があるか初回: フル取得
    final data = await _client.post('emojis');
    final list = data['emojis'] as List<dynamic>? ?? [];
    final map = <String, String>{
      for (final e in list.cast<Map<String, dynamic>>())
        e['name'] as String: e['url'] as String,
    };

    if (serverUpdatedAt != null) {
      await _saveDisk(serverUpdatedAt, map);
    }

    return _withFallbacks(map);
  }

  /// "name@server.tld" → "name" のフォールバックエントリを追加する。
  Map<String, String> _withFallbacks(Map<String, String> map) {
    final fallbacks = <String, String>{};
    for (final entry in map.entries) {
      final atIndex = entry.key.indexOf('@');
      if (atIndex > 0) {
        fallbacks.putIfAbsent(entry.key.substring(0, atIndex), () => entry.value);
      }
    }
    return {...fallbacks, ...map};
  }
}
