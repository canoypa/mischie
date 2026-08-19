import 'dart:io';

import 'package:flutter/material.dart';

/// 投稿画面の添付まわり。本文の入力と混ざると、どちらも追いにくくなる。

/// 添付画像 1 枚ぶんの状態。選択した直後にアップロードを開始し、
/// 完了すると fileId が入る。
class Attachment {
  Attachment(this.path);

  /// 下書きから戻したぶん。アップロードは済んでいるのでローカルパスを持たない。
  Attachment.uploaded(String id) : path = null, fileId = id, uploading = false;

  final String? path;
  String? fileId;
  bool uploading = true;
  Object? error;
  String alt = '';
  bool isSensitive = false;
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
              // タップで説明とセンシティブ指定を編集する
              GestureDetector(
                onTap: attachment.fileId == null
                    ? null
                    : () => onEdit(attachment),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: attachment.path == null
                      ? Container(
                          width: 88,
                          height: 88,
                          color: Theme.of(
                            context,
                          ).colorScheme.surfaceContainerHighest,
                          child: const Icon(Icons.image_outlined),
                        )
                      : Image.file(
                          File(attachment.path!),
                          width: 88,
                          height: 88,
                          fit: BoxFit.cover,
                          cacheWidth: 264, // 表示は 88dp。原寸をデコードしない
                        ),
                ),
              ),
              if (attachment.alt.isNotEmpty || attachment.isSensitive)
                Positioned(
                  left: 4,
                  bottom: 4,
                  child: Row(
                    children: [
                      if (attachment.alt.isNotEmpty) const Tag(label: 'ALT'),
                      if (attachment.isSensitive) const Tag(label: 'NSFW'),
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
              // 24dp では小さすぎて押し損ねる。見た目は 28dp のままで、
              // タップ領域だけ 40dp に広げる（はみ出しもやめる）。
              Positioned(
                top: 0,
                right: 0,
                child: SizedBox(
                  width: 40,
                  height: 40,
                  child: IconButton(
                    icon: const Icon(Icons.cancel, size: 22),
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

/// サムネイルに重ねる小さなラベル（ALT / NSFW）。
class Tag extends StatelessWidget {
  const Tag({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 4),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: const TextStyle(color: Colors.white, fontSize: 10),
      ),
    );
  }
}
