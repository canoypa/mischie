import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blurhash/flutter_blurhash.dart';
import 'package:mischie/core/image/image_cache_managers.dart';
import 'package:mischie/features/timeline/domain/drive_file.dart';
import 'package:photo_view/photo_view.dart';
import 'package:mischie/features/timeline/presentation/note/video_viewer.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:url_launcher/url_launcher.dart';

class NoteMediaGrid extends StatelessWidget {
  const NoteMediaGrid({super.key, required this.files});

  final List<DriveFile> files;

  @override
  Widget build(BuildContext context) {
    final images = files.where((f) => f.type.startsWith('image/')).toList();
    // 画像以外（動画・音声・その他のファイル）は自前では開けないが、
    // 何も出さないと添付があること自体が伝わらない。行として出して
    // タップで外部へ渡す。
    final others = files.where((f) => !f.type.startsWith('image/')).toList();

    if (images.isEmpty) {
      return others.isEmpty
          ? const SizedBox.shrink()
          : Column(children: [for (final file in others) FileRow(file: file)]);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _imageGrid(context, images),
        for (final file in others) FileRow(file: file),
      ],
    );
  }

  Widget _imageGrid(BuildContext context, List<DriveFile> images) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: images.length == 1
          ? AspectRatio(
              // 縦長の写真を 16:9 に切ると、何が写っているか分からなくなる
              aspectRatio: images.first.displayAspectRatio,
              child: _MediaTile(file: images.first, images: images, index: 0),
            )
          : AspectRatio(
              // 2 cols: 2 images → 1 row (2:1), 3-4 images → 2 rows (1:1)
              aspectRatio: images.length == 2 ? 2.0 : 1.0,
              child: GridView.count(
                crossAxisCount: 2,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 2,
                crossAxisSpacing: 2,
                children: images
                    .take(4)
                    .toList()
                    .asMap()
                    .entries
                    .map(
                      (e) => _MediaTile(
                        file: e.value,
                        images: images,
                        index: e.key,
                      ),
                    )
                    .toList(),
              ),
            ),
    );
  }
}

/// 画像以外の添付。Mischie では再生・表示できないので、外部に渡す。
class FileRow extends StatelessWidget {
  const FileRow({super.key, required this.file});

  final DriveFile file;

  IconData get _icon {
    if (file.type.startsWith('video/')) return Icons.videocam_outlined;
    if (file.type.startsWith('audio/')) return Icons.audiotrack_outlined;
    return Icons.insert_drive_file_outlined;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: InkWell(
        onTap: () => file.type.startsWith('video/')
            ? openVideo(context, file)
            : launchUrl(
                Uri.parse(file.url),
                mode: LaunchMode.externalApplication,
              ),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            border: Border.all(color: colorScheme.outlineVariant),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(_icon, size: 20, color: colorScheme.onSurfaceVariant),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  file.name ?? file.type,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              Icon(
                // 動画はアプリ内で開くので、外部リンクの印は出さない
                file.type.startsWith('video/')
                    ? Icons.play_circle_outline
                    : Icons.open_in_new,
                size: 16,
                color: colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MediaTile extends StatefulWidget {
  const _MediaTile({
    required this.file,
    required this.images,
    required this.index,
  });

  final DriveFile file;
  final List<DriveFile> images;
  final int index;

  @override
  State<_MediaTile> createState() => _MediaTileState();
}

class _MediaTileState extends State<_MediaTile> {
  bool _revealed = false;

  void _openViewer() {
    showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Close',
      barrierColor: Colors.transparent,
      pageBuilder: (context, anim, _) =>
          _ImageViewer(images: widget.images, initialIndex: widget.index),
    );
  }

  @override
  Widget build(BuildContext context) {
    final file = widget.file;
    final showOverlay = file.isSensitive && !_revealed;

    final alt = file.comment;

    return GestureDetector(
      onTap: showOverlay ? null : _openViewer,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // 投稿側で alt を書けるようにしたのに読み上げへ渡していなかった。
          // 説明の無い画像は、読み上げ環境では存在しないのと同じになる。
          Semantics(
            image: true,
            label: alt ?? file.name ?? '画像',
            child: CachedNetworkImage(
              imageUrl: file.thumbnailUrl ?? file.url,
              cacheManager: MediaCacheManager.instance,
              fit: BoxFit.cover,
              placeholder: (context, url) => file.blurhash != null
                  ? BlurHash(hash: file.blurhash!)
                  : Container(
                      color: Theme.of(
                        context,
                      ).colorScheme.surfaceContainerHighest,
                    ),
              errorWidget: (context, url, error) =>
                  const Center(child: Icon(Icons.broken_image)),
            ),
          ),
          if (alt != null && alt.isNotEmpty && !showOverlay)
            Positioned(left: 6, bottom: 6, child: _AltBadge(text: alt)),
          if (showOverlay)
            GestureDetector(
              onTap: () => setState(() => _revealed = true),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (file.blurhash != null)
                    BlurHash(hash: file.blurhash!)
                  else
                    Container(color: Colors.black54),
                  const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.warning_amber_rounded,
                          color: Colors.white,
                          size: 28,
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Sensitive',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Click to show',
                          style: TextStyle(color: Colors.white70, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _ImageViewer extends StatefulWidget {
  const _ImageViewer({required this.images, required this.initialIndex});

  final List<DriveFile> images;
  final int initialIndex;

  @override
  State<_ImageViewer> createState() => _ImageViewerState();
}

class _ImageViewerState extends State<_ImageViewer>
    with SingleTickerProviderStateMixin {
  late int _current;
  late AnimationController _bgController;
  late Animation<double> _bgOpacity;
  double _dragY = 0;
  bool _dragging = false;

  static const _bgMaxOpacity = 0.92;
  static const _dismissThreshold = 120.0;

  @override
  void initState() {
    super.initState();
    _current = widget.initialIndex;
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
      value: 1,
    );
    _bgOpacity = _bgController.drive(
      Tween<double>(begin: 0, end: _bgMaxOpacity),
    );
  }

  @override
  void dispose() {
    _bgController.dispose();
    super.dispose();
  }

  void _onVerticalStart(DragStartDetails d) {
    // ピンチズーム中（scale != 1）は無視するが PhotoView に任せる
    setState(() {
      _dragging = true;
      _dragY = 0;
    });
  }

  void _onVerticalUpdate(DragUpdateDetails d) {
    setState(() => _dragY += d.delta.dy);
    final progress = (_dragY.abs() / _dismissThreshold).clamp(0.0, 1.0);
    _bgController.value = 1 - progress * 0.6;
  }

  void _onVerticalEnd(DragEndDetails d) {
    if (_dragY.abs() >= _dismissThreshold ||
        d.velocity.pixelsPerSecond.dy.abs() > 800) {
      Navigator.of(context).pop();
    } else {
      setState(() {
        _dragging = false;
        _dragY = 0;
      });
      _bgController.animateTo(1);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _bgOpacity,
      builder: (context, child) {
        return Material(
          color: Colors.black.withAlpha((_bgOpacity.value * 255).round()),
          child: child,
        );
      },
      child: GestureDetector(
        onVerticalDragStart: _onVerticalStart,
        onVerticalDragUpdate: _onVerticalUpdate,
        onVerticalDragEnd: _onVerticalEnd,
        child: Transform.translate(
          offset: Offset(0, _dragY),
          child: Stack(
            children: [
              PhotoViewGallery.builder(
                itemCount: widget.images.length,
                pageController: PageController(
                  initialPage: widget.initialIndex,
                ),
                onPageChanged: (i) => setState(() => _current = i),
                builder: (context, index) {
                  final file = widget.images[index];
                  return PhotoViewGalleryPageOptions(
                    imageProvider: CachedNetworkImageProvider(
                      file.url,
                      cacheManager: MediaCacheManager.instance,
                    ),
                    minScale: PhotoViewComputedScale.contained,
                    maxScale: PhotoViewComputedScale.covered * 3,
                  );
                },
                backgroundDecoration: const BoxDecoration(
                  color: Colors.transparent,
                ),
                loadingBuilder: (context, event) =>
                    const Center(child: CircularProgressIndicator()),
              ),
              // 閉じるボタン
              SafeArea(
                child: Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                ),
              ),
              // ページインジケーター
              if (widget.images.length > 1)
                Positioned(
                  bottom: 32,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      widget.images.length,
                      (i) => AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        width: i == _current ? 12 : 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: i == _current
                              ? Colors.white
                              : Colors.white.withAlpha(128),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                  ),
                ),
              // 下スワイプヒント
              if (!_dragging)
                Positioned(
                  bottom: 8,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Icon(
                      Icons.keyboard_arrow_down,
                      color: Colors.white.withAlpha(100),
                      size: 28,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 返信・リノート・リアクション・その他のアクション行。

/// 説明（alt）が付いていることを示すバッジ。押すと本文を読める。
///
/// 画像が見えていても、説明が付いているかどうかは見た目では分からない。
/// 付けた側の意図が届くよう、目でも辿れるようにしておく。
class _AltBadge extends StatelessWidget {
  const _AltBadge({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '画像の説明を読む',
      child: GestureDetector(
        onTap: () => showDialog<void>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('画像の説明'),
            content: SingleChildScrollView(child: Text(text)),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('閉じる'),
              ),
            ],
          ),
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.black54,
            borderRadius: BorderRadius.circular(4),
          ),
          child: const Text(
            'ALT',
            style: TextStyle(color: Colors.white, fontSize: 10),
          ),
        ),
      ),
    );
  }
}
