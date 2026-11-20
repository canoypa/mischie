import 'package:cached_network_image/cached_network_image.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blurhash/flutter_blurhash.dart';
import 'package:mischie/core/error/error_handler.dart';
import 'package:mischie/core/image/image_cache_managers.dart';
import 'package:mischie/core/widgets/overlay_tag.dart';
import 'package:mischie/features/timeline/domain/drive_file.dart';
import 'package:photo_view/photo_view.dart';
import 'package:mischie/features/timeline/presentation/note/video_viewer.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class NoteMediaGrid extends StatelessWidget {
  const NoteMediaGrid({super.key, required this.files});

  final List<DriveFile> files;

  @override
  Widget build(BuildContext context) {
    final images = files.where((f) => f.type.startsWith('image/')).toList();
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
              // 2 枚は 1 行、3〜4 枚は 2 行
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

/// 画像以外の添付。
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

  void _openViewer() =>
      showImageViewer(context, widget.images, initialIndex: widget.index);

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
          Semantics(
            image: true,
            label: alt ?? file.name ?? '画像',
            child: CachedNetworkImage(
              imageUrl: file.thumbnailUrl ?? file.url,
              cacheManager: MediaCacheManager.instance,
              fit: BoxFit.cover,
              // 画面幅より大きく出ないので、その幅でデコードしてメモリを抑える。
              memCacheWidth:
                  (MediaQuery.sizeOf(context).width *
                          MediaQuery.devicePixelRatioOf(context))
                      .round(),
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
            _SensitiveCover(
              blurhash: file.blurhash,
              compact: true,
              onReveal: () => setState(() => _revealed = true),
            ),
        ],
      ),
    );
  }
}

void showImageViewer(
  BuildContext context,
  List<DriveFile> images, {
  int initialIndex = 0,
}) {
  showGeneralDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Close',
    barrierColor: Colors.transparent,
    pageBuilder: (context, anim, _) =>
        _ImageViewer(images: images, initialIndex: initialIndex),
  );
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
  late PageController _pageController;
  double _dragY = 0;
  bool _dragging = false;

  /// 開いた 1 枚はグリッドで見えているので、最初から入れておく。
  late final Set<int> _revealed = {widget.initialIndex};

  static const _bgMaxOpacity = 0.92;
  static const _dismissThreshold = 120.0;

  @override
  void initState() {
    super.initState();
    _current = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
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
    _pageController.dispose();
    super.dispose();
  }

  /// 保存も共有から行う。
  Future<void> _shareCurrent() async {
    final image = widget.images[_current];
    final messenger = ScaffoldMessenger.of(context);
    try {
      final file = await MediaCacheManager.instance.getSingleFile(image.url);
      await SharePlus.instance.share(
        ShareParams(files: [XFile(file.path, mimeType: image.type)]),
      );
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(resolveErrorMessage(e))));
    }
  }

  void _onVerticalStart(DragStartDetails d) {
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
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: AnimatedBuilder(
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
                  pageController: _pageController,
                  onPageChanged: (i) => setState(() => _current = i),
                  builder: (context, index) {
                    final file = widget.images[index];
                    if (file.isSensitive && !_revealed.contains(index)) {
                      return PhotoViewGalleryPageOptions.customChild(
                        // ぼかしの上に自前のタップ判定を置くので、PhotoView
                        // 側のズーム・パンは無効にしておく。
                        disableGestures: true,
                        minScale: PhotoViewComputedScale.contained,
                        maxScale: PhotoViewComputedScale.contained,
                        child: _SensitiveCover(
                          blurhash: file.blurhash,
                          onReveal: () => setState(() => _revealed.add(index)),
                        ),
                      );
                    }
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
                SafeArea(
                  child: Align(
                    alignment: Alignment.topRight,
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.share, color: Colors.white),
                            tooltip: '共有',
                            onPressed: _shareCurrent,
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.white),
                            tooltip: '閉じる',
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                if (widget.images.length > 1)
                  Positioned(
                    bottom: 32 + bottomInset,
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
                    bottom: 8 + bottomInset,
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
      ),
    );
  }
}

class _SensitiveCover extends StatelessWidget {
  const _SensitiveCover({
    required this.blurhash,
    required this.onReveal,
    this.compact = false,
  });

  final String? blurhash;
  final VoidCallback onReveal;

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Semantics(
      button: true,
      label: 'センシティブな内容。タップで表示',
      excludeSemantics: true,
      child: GestureDetector(
        onTap: onReveal,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (blurhash != null)
              BlurHash(hash: blurhash!)
            else
              const ColoredBox(color: Colors.black87),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.white,
                    size: compact ? 28 : 36,
                  ),
                  SizedBox(height: compact ? 4 : 8),
                  Text(
                    'センシティブな内容',
                    style:
                        (compact ? textTheme.labelLarge : textTheme.titleSmall)
                            ?.copyWith(color: Colors.white),
                  ),
                  SizedBox(height: compact ? 2 : 4),
                  Text(
                    'タップで表示',
                    style:
                        (compact ? textTheme.labelSmall : textTheme.bodySmall)
                            ?.copyWith(color: Colors.white70),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 説明が付いていることは画像を見ても分からないので、バッジで示す。
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
        child: const OverlayTag(label: 'ALT'),
      ),
    );
  }
}
