import 'package:flutter_cache_manager/flutter_cache_manager.dart';

/// 画像キャッシュの上限を用途別に分ける。
///
/// 既定の [DefaultCacheManager] は 200 件までしか保持しない。カスタム絵文字が
/// 1 万件規模あるサーバーではタイムラインを流すだけで溢れ、同じ絵文字を
/// 何度も取り直すことになる。サーバーへの負荷にも表示の速さにも効く。
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
