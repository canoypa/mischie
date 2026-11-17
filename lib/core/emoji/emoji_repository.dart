import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:mischie/core/api/misskey_api_client.dart';

class EmojiCatalog {
  const EmojiCatalog({required this.urls, required this.categories});

  static const empty = EmojiCatalog(urls: {}, categories: {});

  /// name → URL。他サーバーの `name@host` からホストを落とした名前でも引ける。
  final Map<String, String> urls;

  /// name → カテゴリ。カテゴリの無い絵文字は入らない。
  final Map<String, String> categories;
}

class EmojiRepository {
  const EmojiRepository(this._client);

  final MisskeyApiClient _client;

  /// アカウントを切り替えたとき前のサーバーの絵文字が出ないよう、ホスト別に持つ。
  Future<File> _cacheFile() async {
    final dir = await getApplicationCacheDirectory();
    final safeHost = _client.host.replaceAll(RegExp(r'[^a-zA-Z0-9.-]'), '_');
    return File('${dir.path}/emoji_cache_$safeHost.json');
  }

  Future<
    ({
      String? updatedAt,
      Map<String, String> emojis,
      Map<String, String>? categories,
    })?
  >
  _loadDisk() async {
    try {
      final file = await _cacheFile();
      if (!await file.exists()) return null;
      final json =
          jsonDecode(await file.readAsString()) as Map<String, dynamic>;
      return (
        updatedAt: json['updatedAt'] as String?,
        emojis: (json['emojis'] as Map<String, dynamic>).cast<String, String>(),
        categories: (json['categories'] as Map<String, dynamic>?)
            ?.cast<String, String>(),
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> _saveDisk(
    String updatedAt,
    Map<String, String> emojis,
    Map<String, String> categories,
  ) async {
    try {
      final file = await _cacheFile();
      await file.writeAsString(
        jsonEncode({
          'updatedAt': updatedAt,
          'emojis': emojis,
          'categories': categories,
        }),
      );
    } catch (_) {}
  }

  Future<String?> _fetchEmojisUpdatedAt() async {
    try {
      final data = await _client.post('meta');
      return data['emojisUpdatedAt'] as String?;
    } catch (_) {
      return null;
    }
  }

  /// カテゴリの無い旧形式のキャッシュは取り直す。
  Future<EmojiCatalog> fetchCatalog() async {
    final cache = await _loadDisk();
    final serverUpdatedAt = await _fetchEmojisUpdatedAt();

    if (cache != null &&
        cache.emojis.isNotEmpty &&
        cache.categories != null &&
        serverUpdatedAt != null &&
        serverUpdatedAt == cache.updatedAt) {
      return EmojiCatalog(
        urls: _withFallbacks(cache.emojis),
        categories: cache.categories!,
      );
    }

    final data = await _client.post('emojis');
    final list = (data['emojis'] as List<dynamic>? ?? [])
        .cast<Map<String, dynamic>>();
    final map = <String, String>{
      for (final e in list) e['name'] as String: e['url'] as String,
    };
    final categories = <String, String>{
      for (final e in list)
        if (e['category'] case final String category when category.isNotEmpty)
          e['name'] as String: category,
    };

    if (serverUpdatedAt != null) {
      await _saveDisk(serverUpdatedAt, map, categories);
    }

    return EmojiCatalog(urls: _withFallbacks(map), categories: categories);
  }

  Map<String, String> _withFallbacks(Map<String, String> map) {
    final fallbacks = <String, String>{};
    for (final entry in map.entries) {
      final atIndex = entry.key.indexOf('@');
      if (atIndex > 0) {
        fallbacks.putIfAbsent(
          entry.key.substring(0, atIndex),
          () => entry.value,
        );
      }
    }
    return {...fallbacks, ...map};
  }
}
