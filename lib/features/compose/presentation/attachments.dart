import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mischie/core/image/image_cache_managers.dart';
import 'package:mischie/core/widgets/overlay_tag.dart';
import 'package:mischie/features/timeline/domain/drive_file.dart';

class Attachment {
  Attachment(this.path) : thumbnailUrl = null, alt = '', isSensitive = false;

  /// 下書きから戻したぶんはサムネイルが無い。
  Attachment.uploaded(
    String id, {
    this.thumbnailUrl,
    this.alt = '',
    this.isSensitive = false,
  }) : path = null,
       fileId = id,
       uploading = false;

  factory Attachment.fromDriveFile(DriveFile file) => Attachment.uploaded(
    file.id,
    // 画像以外はサムネイルが無いとき原本を出しても表示できない
    thumbnailUrl:
        file.thumbnailUrl ?? (file.type.startsWith('image/') ? file.url : null),
    alt: file.comment ?? '',
    isSensitive: file.isSensitive,
  );

  final String? path;
  final String? thumbnailUrl;
  String? fileId;
  bool uploading = true;
  Object? error;
  String alt;
  bool isSensitive;
}

class AttachmentStrip extends StatelessWidget {
  const AttachmentStrip({
    super.key,
    required this.attachments,
    required this.onRemove,
    required this.onRetry,
    required this.onEdit,
  });

  final List<Attachment> attachments;
  final ValueChanged<Attachment> onRemove;
  final ValueChanged<Attachment> onRetry;
  final ValueChanged<Attachment> onEdit;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 104,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: attachments.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final attachment = attachments[index];
          return Stack(
            clipBehavior: Clip.none,
            children: [
              GestureDetector(
                onTap: attachment.fileId == null
                    ? null
                    : () => onEdit(attachment),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: _Thumbnail(attachment: attachment),
                ),
              ),
              if (attachment.alt.isNotEmpty || attachment.isSensitive)
                Positioned(
                  left: 4,
                  bottom: 4,
                  child: Row(
                    children: [
                      if (attachment.alt.isNotEmpty)
                        const Padding(
                          padding: EdgeInsets.only(right: 4),
                          child: OverlayTag(label: 'ALT'),
                        ),
                      if (attachment.isSensitive)
                        const Padding(
                          padding: EdgeInsets.only(right: 4),
                          child: OverlayTag(label: 'NSFW'),
                        ),
                    ],
                  ),
                ),
              if (attachment.uploading)
                const Positioned.fill(
                  child: ColoredBox(
                    color: Colors.black38,
                    child: Center(
                      child: SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              if (attachment.error != null)
                Positioned.fill(
                  child: GestureDetector(
                    onTap: () => onRetry(attachment),
                    child: ColoredBox(
                      color: Theme.of(
                        context,
                      ).colorScheme.errorContainer.withValues(alpha: 0.8),
                      child: const Center(child: Icon(Icons.refresh)),
                    ),
                  ),
                ),
              // 押し損ねないよう、タップ領域だけ見た目より広げる。
              Positioned(
                top: 0,
                right: 0,
                child: SizedBox(
                  width: 40,
                  height: 40,
                  child: IconButton(
                    icon: const Icon(Icons.cancel, size: 22),
                    tooltip: '添付を外す',
                    color: Colors.white,
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.black54,
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(28, 28),
                    ),
                    onPressed: () => onRemove(attachment),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _Thumbnail extends StatelessWidget {
  const _Thumbnail({required this.attachment});

  final Attachment attachment;

  static const _size = 88.0;

  static final _videoExtension = RegExp(
    r'\.(mp4|m4v|mov|webm|mkv|3gp)$',
    caseSensitive: false,
  );

  @override
  Widget build(BuildContext context) {
    final path = attachment.path;
    final url = attachment.thumbnailUrl;

    Widget placeholder(IconData icon) => Container(
      width: _size,
      height: _size,
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Icon(icon),
    );

    if (path != null) {
      // 動画は端末内で縮小画像を作る手段が無いので、種類だけを示す
      if (_videoExtension.hasMatch(path)) {
        return placeholder(Icons.videocam_outlined);
      }
      return Image.file(
        File(path),
        width: _size,
        height: _size,
        fit: BoxFit.cover,
        cacheWidth: 264, // 表示は 88dp。原寸をデコードしない
        errorBuilder: (_, _, _) =>
            placeholder(Icons.insert_drive_file_outlined),
      );
    }

    final placeholderImage = placeholder(Icons.image_outlined);
    if (url == null) return placeholderImage;
    return CachedNetworkImage(
      imageUrl: url,
      cacheManager: MediaCacheManager.instance,
      width: _size,
      height: _size,
      fit: BoxFit.cover,
      memCacheWidth: 264,
      placeholder: (_, _) => placeholderImage,
      errorWidget: (_, _, _) => placeholderImage,
    );
  }
}
