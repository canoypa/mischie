import 'package:cached_network_image/cached_network_image.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mischie/core/image/image_cache_managers.dart';
import 'package:mischie/features/drive/domain/drive_page.dart';
import 'package:mischie/features/timeline/domain/drive_file.dart';

String formatBytes(int bytes) {
  if (bytes < 1024) return '$bytes B';
  const units = ['KB', 'MB', 'GB', 'TB'];
  var value = bytes / 1024;
  var unit = 0;
  while (value >= 1024 && unit < units.length - 1) {
    value /= 1024;
    unit++;
  }
  return '${value.toStringAsFixed(value >= 100 ? 0 : 1)} ${units[unit]}';
}

class DriveUsageHeader extends StatelessWidget {
  const DriveUsageHeader({super.key, required this.usage});

  final DriveUsage usage;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LinearProgressIndicator(value: usage.ratio),
          const SizedBox(height: 6),
          Text(
            '${formatBytes(usage.usage)} / ${formatBytes(usage.capacity)}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

IconData driveFileIcon(String type) {
  if (type.startsWith('image/')) return Icons.image_outlined;
  if (type.startsWith('video/')) return Icons.videocam_outlined;
  if (type.startsWith('audio/')) return Icons.audiotrack_outlined;
  return Icons.insert_drive_file_outlined;
}

class DriveFileTile extends StatelessWidget {
  const DriveFileTile({
    super.key,
    required this.file,
    required this.onTap,
    this.selected,
  });

  final DriveFile file;
  final VoidCallback onTap;

  /// 選択モードのときだけ非 null。
  final bool? selected;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isImage = file.type.startsWith('image/');
    final isSelected = selected ?? false;

    return Semantics(
      button: true,
      selected: selected == null ? null : isSelected,
      label: file.comment ?? file.name ?? file.type,
      child: ExcludeSemantics(
        child: InkWell(
          onTap: onTap,
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (isImage)
                CachedNetworkImage(
                  imageUrl: file.thumbnailUrl ?? file.url,
                  cacheManager: MediaCacheManager.instance,
                  fit: BoxFit.cover,
                  // 3 列のマスより大きくは出ないので、その大きさでデコードする
                  memCacheWidth:
                      (MediaQuery.sizeOf(context).width /
                              3 *
                              MediaQuery.devicePixelRatioOf(context))
                          .round(),
                  placeholder: (context, url) =>
                      ColoredBox(color: colorScheme.surfaceContainerHighest),
                  errorWidget: (context, url, error) =>
                      const Center(child: Icon(Icons.broken_image_outlined)),
                )
              else
                ColoredBox(
                  color: colorScheme.surfaceContainerHighest,
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          driveFileIcon(file.type),
                          size: 32,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          file.name ?? file.type,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                      ],
                    ),
                  ),
                ),
              if (file.isSensitive)
                Positioned(
                  left: 4,
                  bottom: 4,
                  child: Icon(
                    Icons.visibility_off,
                    size: 16,
                    color: colorScheme.onInverseSurface,
                    shadows: const [Shadow(blurRadius: 4)],
                  ),
                ),
              if (isSelected)
                ColoredBox(color: colorScheme.primary.withValues(alpha: 0.3)),
              if (selected != null)
                Positioned(
                  top: 4,
                  right: 4,
                  child: Icon(
                    isSelected ? Icons.check_circle : Icons.circle_outlined,
                    color: isSelected
                        ? colorScheme.primary
                        : colorScheme.onInverseSurface,
                    shadows: const [Shadow(blurRadius: 4)],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

enum DriveFileAction { open, toggleSensitive, rename, editComment, delete }

Future<DriveFileAction?> showDriveFileSheet(
  BuildContext context,
  DriveFile file,
) {
  final size = file.size;
  return showModalBottomSheet<DriveFileAction>(
    context: context,
    showDragHandle: true,
    // 横向きなど低い画面では項目が収まらないので、スクロールできるようにする
    builder: (context) => SafeArea(
      child: ListView(
        shrinkWrap: true,
        children: [
          ListTile(
            leading: Icon(driveFileIcon(file.type)),
            title: Text(file.name ?? file.type, maxLines: 2),
            subtitle: Text(
              size == null ? file.type : '${file.type} ・ ${formatBytes(size)}',
            ),
          ),
          const Divider(height: 1),
          _SheetAction(
            icon: Icons.open_in_new,
            label: '開く',
            action: DriveFileAction.open,
          ),
          _SheetAction(
            icon: file.isSensitive
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
            label: file.isSensitive ? 'センシティブを解除' : 'センシティブにする',
            action: DriveFileAction.toggleSensitive,
          ),
          _SheetAction(
            icon: Icons.drive_file_rename_outline,
            label: '名前を変更',
            action: DriveFileAction.rename,
          ),
          _SheetAction(
            icon: Icons.notes,
            label: '説明を編集',
            action: DriveFileAction.editComment,
          ),
          _SheetAction(
            icon: Icons.delete_outline,
            label: '削除',
            action: DriveFileAction.delete,
            destructive: true,
          ),
        ],
      ),
    ),
  );
}

enum DriveFolderAction { rename, delete }

Future<DriveFolderAction?> showDriveFolderSheet(
  BuildContext context,
  String folderName,
) {
  return showModalBottomSheet<DriveFolderAction>(
    context: context,
    showDragHandle: true,
    // 横向きなど低い画面では項目が収まらないので、スクロールできるようにする
    builder: (context) => SafeArea(
      child: ListView(
        shrinkWrap: true,
        children: [
          ListTile(
            leading: const Icon(Icons.folder_outlined),
            title: Text(folderName, maxLines: 2),
          ),
          const Divider(height: 1),
          const _SheetAction(
            icon: Icons.drive_file_rename_outline,
            label: '名前を変更',
            action: DriveFolderAction.rename,
          ),
          const _SheetAction(
            icon: Icons.delete_outline,
            label: '削除',
            action: DriveFolderAction.delete,
            destructive: true,
          ),
        ],
      ),
    ),
  );
}

class _SheetAction<T> extends StatelessWidget {
  const _SheetAction({
    required this.icon,
    required this.label,
    required this.action,
    this.destructive = false,
  });

  final IconData icon;
  final String label;
  final T action;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final color = destructive ? Theme.of(context).colorScheme.error : null;
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(label, style: TextStyle(color: color)),
      onTap: () => Navigator.of(context).pop(action),
    );
  }
}

/// キャンセルは null。
Future<String?> showTextInputDialog(
  BuildContext context, {
  required String title,
  String initialValue = '',
  required int maxLength,
  bool multiline = false,
  bool allowEmpty = false,
}) {
  return showDialog<String>(
    context: context,
    builder: (context) => _TextInputDialog(
      title: title,
      initialValue: initialValue,
      maxLength: maxLength,
      multiline: multiline,
      allowEmpty: allowEmpty,
    ),
  );
}

class _TextInputDialog extends StatefulWidget {
  const _TextInputDialog({
    required this.title,
    required this.initialValue,
    required this.maxLength,
    required this.multiline,
    required this.allowEmpty,
  });

  final String title;
  final String initialValue;
  final int maxLength;
  final bool multiline;
  final bool allowEmpty;

  @override
  State<_TextInputDialog> createState() => _TextInputDialogState();
}

class _TextInputDialogState extends State<_TextInputDialog> {
  late final _controller = TextEditingController(text: widget.initialValue);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final text = _controller.text.trim();
    if (text.isEmpty && !widget.allowEmpty) return;
    Navigator.of(context).pop(text);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: TextField(
        controller: _controller,
        autofocus: true,
        maxLength: widget.maxLength,
        minLines: 1,
        maxLines: widget.multiline ? 5 : 1,
        textInputAction: widget.multiline ? null : TextInputAction.done,
        onSubmitted: widget.multiline ? null : (_) => _submit(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('キャンセル'),
        ),
        ValueListenableBuilder(
          valueListenable: _controller,
          builder: (context, value, _) => FilledButton(
            onPressed: widget.allowEmpty || value.text.trim().isNotEmpty
                ? _submit
                : null,
            child: const Text('決定'),
          ),
        ),
      ],
    );
  }
}
