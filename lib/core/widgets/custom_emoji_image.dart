import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:mischie/core/image/image_cache_managers.dart';

/// カスタム絵文字 1 個ぶんの画像。
///
/// 幅を予約しないと、読み込み前は 0 幅で描かれてから画像の到着で
/// 広がり、周りのレイアウトがずれる。
class CustomEmojiImage extends StatelessWidget {
  const CustomEmojiImage({
    super.key,
    required this.url,
    required this.size,
    required this.errorFallback,
    this.fit,
  });

  final String url;
  final double size;

  /// 読み込みに失敗したときに出すもの。絵文字名を出すか無地にするかは
  /// 置かれる場所によって違う。
  final Widget errorFallback;
  final BoxFit? fit;

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: url,
      cacheManager: EmojiCacheManager.instance,
      height: size,
      fit: fit,
      placeholder: (_, _) => SizedBox(height: size, width: size),
      errorWidget: (_, _, _) => errorFallback,
    );
  }
}
