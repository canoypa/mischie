import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:mischie/core/image/image_cache_managers.dart';

/// url → 縦横比 (width / height) の LRU キャッシュ。
///
/// カスタム絵文字の横幅は画像を読むまで分からない。ここに残しておけば、
/// スクロールで戻ってきたときや同じ絵文字が別の場所に出てきたときに、
/// 読み込みを待たず最初から正しい幅で確保できる。無制限に増やすと
/// 絵文字が数千〜1万件あるサーバーでは肥大するので、古いものから捨てる。
class _AspectRatioCache {
  _AspectRatioCache(this._capacity);

  final int _capacity;
  // Dart の Map リテラルは LinkedHashMap 実装なので、挿入順が保たれる。
  final _map = <String, double>{};

  double? get(String key) {
    final value = _map.remove(key);
    if (value == null) return null;
    return _map[key] = value; // 直近アクセスとして末尾に戻す
  }

  void put(String key, double value) {
    _map.remove(key);
    _map[key] = value;
    if (_map.length > _capacity) {
      _map.remove(_map.keys.first);
    }
  }
}

final _aspectRatioCache = _AspectRatioCache(4000);

/// カスタム絵文字 1 個ぶんの画像。
///
/// 幅を予約しないと、読み込み前は正方形、読み込み後は実際の縦横比へと
/// 幅が変わってレイアウトがずれる。縦横比が分かるまでは正方形として
/// 確保し、分かった時点でその URL の幅として覚えておく。
class CustomEmojiImage extends StatefulWidget {
  const CustomEmojiImage({
    super.key,
    required this.url,
    required this.size,
    required this.errorFallback,
    this.fit,
    this.maxWidth,
  });

  final String url;

  /// 画像の高さ。
  final double size;

  /// 読み込みに失敗したときに出すもの。絵文字名を出すか無地にするかは
  /// 置かれる場所によって違う。
  final Widget errorFallback;
  final BoxFit? fit;

  /// 横に長い絵文字が周りを占領しないための幅の上限。null なら無制限。
  final double? maxWidth;

  @override
  State<CustomEmojiImage> createState() => _CustomEmojiImageState();
}

class _CustomEmojiImageState extends State<CustomEmojiImage> {
  double? _aspectRatio;
  ImageStream? _stream;
  ImageStreamListener? _listener;

  @override
  void initState() {
    super.initState();
    _aspectRatio = _aspectRatioCache.get(widget.url);
  }

  @override
  void didUpdateWidget(CustomEmojiImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.url != widget.url) {
      _detach();
      _aspectRatio = _aspectRatioCache.get(widget.url);
    }
  }

  @override
  void dispose() {
    _detach();
    super.dispose();
  }

  void _detach() {
    final stream = _stream;
    final listener = _listener;
    if (stream != null && listener != null) {
      stream.removeListener(listener);
    }
    _stream = null;
    _listener = null;
  }

  /// 表示できた画像から縦横比を読み、次回以降のために覚える。
  /// 一度分かったものは測り直さない。
  void _measure(ImageProvider provider, BuildContext context) {
    if (_aspectRatioCache.get(widget.url) != null) return;
    _detach();
    final stream = provider.resolve(createLocalImageConfiguration(context));
    final listener = ImageStreamListener((info, _) {
      final ratio = info.image.width / info.image.height;
      _aspectRatioCache.put(widget.url, ratio);
      // レイアウト中に setState は呼べないので、フレーム後に反映する。
      SchedulerBinding.instance.addPostFrameCallback((_) {
        if (mounted && _aspectRatio != ratio) {
          setState(() => _aspectRatio = ratio);
        }
      });
    });
    stream.addListener(listener);
    _stream = stream;
    _listener = listener;
  }

  double get _width {
    final ratio = _aspectRatio;
    final natural = ratio == null ? widget.size : widget.size * ratio;
    final maxWidth = widget.maxWidth;
    if (maxWidth == null || natural <= maxWidth) return natural;
    return maxWidth;
  }

  @override
  Widget build(BuildContext context) {
    final fit = widget.fit ?? BoxFit.contain;
    final width = _width;

    return CachedNetworkImage(
      imageUrl: widget.url,
      cacheManager: EmojiCacheManager.instance,
      imageBuilder: (context, imageProvider) {
        _measure(imageProvider, context);
        return Image(
          image: imageProvider,
          width: width,
          height: widget.size,
          fit: fit,
        );
      },
      placeholder: (_, _) => SizedBox(width: width, height: widget.size),
      errorWidget: (_, _, _) => widget.errorFallback,
    );
  }
}
