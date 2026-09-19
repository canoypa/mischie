import 'dart:math' as math;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:mischie/core/image/image_cache_managers.dart';
import 'package:mischie/core/widgets/blurhash_color.dart';
import 'package:mischie/core/widgets/cat_ears.dart';
import 'package:mischie/features/timeline/domain/user.dart';

/// 猫耳とデコレーションを載せたアイコン。
///
/// デコレーションはアイコンからはみ出して描かれるので、置く側では
/// レイアウト上の大きさ（= size）だけを占める。
/// アイコンの下地。読み込み前と透過部分に見える色。
Color _placeholderColor(BuildContext context) =>
    Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.12);

class DecoratedAvatar extends StatelessWidget {
  const DecoratedAvatar({
    super.key,
    required this.avatarUrl,
    this.size = 40,
    this.isCat = false,
    this.avatarBlurhash,
    this.decorations = const [],
    this.borderColor,
  });

  final String? avatarUrl;
  final double size;
  final bool isCat;

  /// 猫耳の色をここから取る。
  final String? avatarBlurhash;
  final List<AvatarDecoration> decorations;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    // 猫耳を箱の中に収めるぶん、アイコンをわずかに小さくする。
    // 箱の大きさは変えないので、並びの高さは猫かどうかで変わらない。
    final diameter = isCat ? size * 0.78 : size;
    final radius = diameter / 2;
    Widget avatar = avatarUrl == null
        // 下地は無彩色にする。既定の primary 系だと、透過部分のある
        // アイコンがテーマ色に染まって本来の見た目にならない。
        ? CircleAvatar(
            radius: radius,
            backgroundColor: _placeholderColor(context),
            foregroundColor: Theme.of(context).colorScheme.surface,
            child: Icon(Icons.person, size: radius),
          )
        : CircleAvatar(
            radius: radius,
            backgroundColor: _placeholderColor(context),
            // 原寸のままデコードすると、一覧に並ぶ小さなアイコンのために
            // 巨大な画像をメモリへ展開することになる。表示に要る分だけに絞る。
            backgroundImage: ResizeImage(
              CachedNetworkImageProvider(
                avatarUrl!,
                cacheManager: MediaCacheManager.instance,
              ),
              width: (diameter * MediaQuery.devicePixelRatioOf(context))
                  .round(),
            ),
          );

    if (borderColor != null) {
      avatar = Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: borderColor!, width: 4),
        ),
        child: avatar,
      );
    }

    if (!isCat && decorations.isEmpty) return avatar;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // 箱の外へはみ出して描くと、親のどこかでクリップされて耳や
          // アイコンが切れる。箱の中に収め、耳はアイコンの後ろから
          // 覗く形にする。
          if (isCat)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: CatEars(
                width: size,
                color: averageColorOfBlurhash(avatarBlurhash),
              ),
            ),
          Align(alignment: Alignment.bottomCenter, child: avatar),
          for (final decoration in decorations)
            Positioned(
              // デコレーション画像はアイコンより一回り大きい枠に描く
              left: -size * 0.25,
              top: -size * 0.25,
              child: _Decoration(decoration: decoration, size: size * 1.5),
            ),
        ],
      ),
    );
  }
}

class _Decoration extends StatelessWidget {
  const _Decoration({required this.decoration, required this.size});

  final AvatarDecoration decoration;
  final double size;

  @override
  Widget build(BuildContext context) {
    // offset は半径を 1 とした比率、angle は回転数（1 = 一周）
    return Transform.translate(
      offset: Offset(
        decoration.offsetX * size / 2,
        decoration.offsetY * size / 2,
      ),
      child: Transform.rotate(
        angle: decoration.angle * 2 * math.pi,
        child: Transform.flip(
          flipX: decoration.flipH,
          child: CachedNetworkImage(
            imageUrl: decoration.url,
            cacheManager: MediaCacheManager.instance,
            width: size,
            height: size,
            fit: BoxFit.contain,
            placeholder: (_, _) => SizedBox(width: size, height: size),
            errorWidget: (_, _, _) => SizedBox(width: size, height: size),
          ),
        ),
      ),
    );
  }
}
