import 'package:flutter_cache_manager/flutter_cache_manager.dart';

/// 既定のキャッシュでは絵文字がすぐ溢れて取り直しになるため、用途別に上限を持つ。
class EmojiCacheManager {
  static const key = 'mischie_emoji';

  /// 絵文字は 1 件が小さく、同じものが繰り返し出るので多めに持つ。
  static final instance = CacheManager(
    Config(
      key,
      maxNrOfCacheObjects: 4000,
      stalePeriod: const Duration(days: 30),
    ),
  );
}

/// アイコン・バナー・添付画像。絵文字より大きいので件数は控えめにする。
class MediaCacheManager {
  static const key = 'mischie_media';

  static final instance = CacheManager(
    Config(
      key,
      maxNrOfCacheObjects: 1000,
      stalePeriod: const Duration(days: 14),
    ),
  );
}
