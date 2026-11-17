import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:mischie/core/image/image_cache_managers.dart';

/// url → 縦横比の LRU キャッシュ。再表示のとき、読み込みを待たずに正しい幅を確保するため。
class _AspectRatioCache {
  _AspectRatioCache(this._capacity);

  final int _capacity;
  // 挿入順を LRU の順として使う。
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

/// カスタム絵文字 1 個ぶんの画像。縦横比が分かるまでは正方形の幅で確保する。
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

  void _measure(ImageProvider provider, BuildContext context) {
    if (_aspectRatioCache.get(widget.url) != null) return;
    _detach();
    final stream = provider.resolve(createLocalImageConfiguration(context));
    final listener = ImageStreamListener((info, _) {
      final ratio = info.image.width / info.image.height;
      _aspectRatioCache.put(widget.url, ratio);
      // キャッシュ済みの画像だとビルド中に同期で呼ばれるため、フレーム後に反映する。
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
