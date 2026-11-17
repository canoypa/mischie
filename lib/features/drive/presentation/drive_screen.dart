import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mischie/core/error/error_handler.dart';
import 'package:mischie/core/widgets/confirm_dialog.dart';
import 'package:mischie/core/widgets/scrollable_message.dart';
import 'package:mischie/features/drive/domain/drive_folder.dart';
import 'package:mischie/features/drive/domain/drive_page.dart';
import 'package:mischie/features/drive/domain/drive_providers.dart';
import 'package:mischie/features/drive/presentation/drive_selection.dart';
import 'package:mischie/features/drive/presentation/drive_widgets.dart';
import 'package:mischie/features/timeline/domain/drive_file.dart';
import 'package:mischie/features/timeline/presentation/note/media.dart';
import 'package:mischie/features/timeline/presentation/note/video_viewer.dart';
import 'package:url_launcher/url_launcher.dart';

/// 選ばずに戻ったときは null。
Future<List<DriveFile>?> pickDriveFiles(BuildContext context, {int max = 16}) {
  return Navigator.of(context).push<List<DriveFile>>(
    MaterialPageRoute(
      builder: (_) => DriveScreen(selection: DriveSelection(max: max)),
    ),
  );
}

/// [selection] を渡すと選択モードになり、決定したファイルを pop の結果として返す。
class DriveScreen extends ConsumerStatefulWidget {
  const DriveScreen({
    super.key,
    this.folderId,
    this.folderName,
    this.selection,
  });

  /// null はルート。
  final String? folderId;
  final String? folderName;
  final DriveSelection? selection;

  @override
  ConsumerState<DriveScreen> createState() => _DriveScreenState();
}

class _DriveScreenState extends ConsumerState<DriveScreen> {
  final List<DriveFolder> _folders = [];
  final List<DriveFile> _files = [];
  DriveUsage? _usage;
  bool _loading = true;
  bool _loadingMore = false;
  Object? _error;

  /// フォルダを読み切ってからファイルを読むので、続きの起点は別々に持つ。
  String? _foldersNext;
  String? _filesNext;

  bool get _isRoot => widget.folderId == null;

  @override
  void initState() {
    super.initState();
    _load();
    if (_isRoot) _loadUsage();
  }

  Future<void> _load({bool silent = false}) async {
    final repo = ref.read(driveRepositoryProvider);
    if (repo == null) return;
    if (!silent) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }
    try {
      final (folders, files) = await (
        repo.fetchFolders(folderId: widget.folderId),
        repo.fetchFiles(folderId: widget.folderId),
      ).wait;
      if (!mounted) return;
      setState(() {
        _folders
          ..clear()
          ..addAll(folders.items);
        _files
          ..clear()
          ..addAll(files.items);
        _foldersNext = folders.nextUntilId;
        _filesNext = files.nextUntilId;
        _loading = false;
        _error = null;
      });
    } catch (e) {
      if (!mounted) return;
      if (silent) {
        _showMessage(resolveErrorMessage(e));
      } else {
        setState(() {
          _error = e;
          _loading = false;
        });
      }
    }
  }

  Future<void> _refresh() async {
    if (_isRoot) _loadUsage();
    await _load(silent: true);
  }

  /// 使用量は付け足しの情報なので、取れなくても画面は出す。
  Future<void> _loadUsage() async {
    try {
      final usage = await ref.read(driveRepositoryProvider)?.fetchUsage();
      if (mounted && usage != null) setState(() => _usage = usage);
    } catch (_) {}
  }

  Future<void> _loadMore() async {
    final repo = ref.read(driveRepositoryProvider);
    if (repo == null || _loadingMore) return;
    if (_foldersNext == null && _filesNext == null) return;
    setState(() => _loadingMore = true);
    try {
      if (_foldersNext != null) {
        final page = await repo.fetchFolders(
          folderId: widget.folderId,
          untilId: _foldersNext,
        );
        if (!mounted) return;
        setState(() {
          _folders.addAll(page.items);
          _foldersNext = page.nextUntilId;
        });
      } else {
        final page = await repo.fetchFiles(
          folderId: widget.folderId,
          untilId: _filesNext,
        );
        if (!mounted) return;
        setState(() {
          _files.addAll(page.items);
          _filesNext = page.nextUntilId;
        });
      }
    } catch (_) {
      // 追加読み込みの失敗は黙って諦める（先頭は読めている）
    } finally {
      if (mounted) setState(() => _loadingMore = false);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _showError(Object error) {
    final message = error is DioException
        ? switch (misskeyErrorCode(error)) {
            'HAS_CHILD_FILES_OR_FOLDERS' =>
              'フォルダが空ではありません。中のファイルとフォルダを片付けてください',
            'RESTRICTED_BY_ROLE' => 'ロールの制限により、この操作はできません',
            'INVALID_FILE_NAME' => '使えないファイル名です',
            _ => resolveErrorMessage(error),
          }
        : resolveErrorMessage(error);
    _showMessage(message);
  }

  void _replaceFile(DriveFile updated) {
    final index = _files.indexWhere((f) => f.id == updated.id);
    if (index >= 0) setState(() => _files[index] = updated);
  }

  void _replaceFolder(DriveFolder updated) {
    final index = _folders.indexWhere((f) => f.id == updated.id);
    if (index >= 0) setState(() => _folders[index] = updated);
  }

  Future<void> _openFolder(DriveFolder folder) async {
    final result = await Navigator.of(context).push<List<DriveFile>>(
      MaterialPageRoute(
        builder: (_) => DriveScreen(
          folderId: folder.id,
          folderName: folder.name,
          selection: widget.selection,
        ),
      ),
    );
    if (!mounted) return;
    // 選択を決定したのは奥の画面。結果を持ち帰るために、ここも閉じる。
    if (result != null) {
      Navigator.of(context).pop(result);
    } else if (_isRoot) {
      _loadUsage();
    }
  }

  Future<void> _onFileTap(DriveFile file) async {
    final selection = widget.selection;
    if (selection != null) {
      if (!selection.toggle(file)) {
        _showMessage('選べるのは ${selection.max} 件までです');
      }
      return;
    }

    final action = await showDriveFileSheet(context, file);
    if (action == null || !mounted) return;
    switch (action) {
      case DriveFileAction.open:
        _open(file);
      case DriveFileAction.toggleSensitive:
        await _toggleSensitive(file);
      case DriveFileAction.rename:
        await _renameFile(file);
      case DriveFileAction.editComment:
        await _editComment(file);
      case DriveFileAction.delete:
        await _deleteFile(file);
    }
  }

  void _open(DriveFile file) {
    if (file.type.startsWith('image/')) {
      final images = _files.where((f) => f.type.startsWith('image/')).toList();
      showImageViewer(
        context,
        images,
        initialIndex: images.indexWhere((f) => f.id == file.id),
      );
    } else if (file.type.startsWith('video/')) {
      openVideo(context, file);
    } else {
      launchUrl(Uri.parse(file.url), mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _toggleSensitive(DriveFile file) async {
    final repo = ref.read(driveRepositoryProvider);
    if (repo == null) return;
    _replaceFile(file.copyWith(isSensitive: !file.isSensitive));
    try {
      await repo.setSensitive(file.id, !file.isSensitive);
    } catch (e) {
      if (!mounted) return;
      _replaceFile(file);
      _showError(e);
    }
  }

  Future<void> _renameFile(DriveFile file) async {
    final name = await showTextInputDialog(
      context,
      title: '名前を変更',
      initialValue: file.name ?? '',
      maxLength: 255,
    );
    final repo = ref.read(driveRepositoryProvider);
    if (name == null || name == file.name || repo == null) return;
    try {
      final updated = await repo.renameFile(file.id, name);
      if (mounted) _replaceFile(updated);
    } catch (e) {
      if (mounted) _showError(e);
    }
  }

  Future<void> _editComment(DriveFile file) async {
    final comment = await showTextInputDialog(
      context,
      title: '説明を編集',
      initialValue: file.comment ?? '',
      maxLength: 512,
      multiline: true,
      allowEmpty: true,
    );
    final repo = ref.read(driveRepositoryProvider);
    if (comment == null || comment == (file.comment ?? '') || repo == null) {
      return;
    }
    try {
      final updated = await repo.setComment(file.id, comment);
      if (mounted) _replaceFile(updated);
    } catch (e) {
      if (mounted) _showError(e);
    }
  }

  Future<void> _deleteFile(DriveFile file) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'ファイルを削除',
      message:
          'ファイル「${file.name ?? file.type}」を削除しますか？このファイルを使用した一部のコンテンツも削除されます。',
      action: '削除',
    );
    final repo = ref.read(driveRepositoryProvider);
    if (!confirmed || !mounted || repo == null) return;

    final index = _files.indexWhere((f) => f.id == file.id);
    if (index < 0) return;
    setState(() => _files.removeAt(index));
    try {
      await repo.deleteFile(file.id);
      if (_isRoot) _loadUsage();
    } catch (e) {
      if (!mounted) return;
      setState(() => _files.insert(index.clamp(0, _files.length), file));
      _showError(e);
    }
  }

  Future<void> _createFolder() async {
    final name = await showTextInputDialog(
      context,
      title: 'フォルダを作成',
      maxLength: 200,
    );
    final repo = ref.read(driveRepositoryProvider);
    if (name == null || repo == null) return;
    try {
      final folder = await repo.createFolder(name, parentId: widget.folderId);
      if (mounted) setState(() => _folders.insert(0, folder));
    } catch (e) {
      if (mounted) _showError(e);
    }
  }

  Future<void> _onFolderMenu(DriveFolder folder) async {
    final action = await showDriveFolderSheet(context, folder.name);
    if (action == null || !mounted) return;
    switch (action) {
      case DriveFolderAction.rename:
        await _renameFolder(folder);
      case DriveFolderAction.delete:
        await _deleteFolder(folder);
    }
  }

  Future<void> _renameFolder(DriveFolder folder) async {
    final name = await showTextInputDialog(
      context,
      title: '名前を変更',
      initialValue: folder.name,
      maxLength: 200,
    );
    final repo = ref.read(driveRepositoryProvider);
    if (name == null || name == folder.name || repo == null) return;
    try {
      final updated = await repo.renameFolder(folder.id, name);
      if (mounted) _replaceFolder(updated);
    } catch (e) {
      if (mounted) _showError(e);
    }
  }

  Future<void> _deleteFolder(DriveFolder folder) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'フォルダを削除',
      message: 'フォルダ「${folder.name}」を削除しますか？空でないフォルダは削除できません。',
      action: '削除',
    );
    final repo = ref.read(driveRepositoryProvider);
    if (!confirmed || !mounted || repo == null) return;
    try {
      await repo.deleteFolder(folder.id);
      if (!mounted) return;
      setState(() => _folders.removeWhere((f) => f.id == folder.id));
    } catch (e) {
      if (mounted) _showError(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final selection = widget.selection;
    final usage = _usage;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.folderName ?? 'ドライブ'),
        actions: [
          if (selection == null)
            IconButton(
              icon: const Icon(Icons.create_new_folder_outlined),
              tooltip: 'フォルダを作成',
              onPressed: _createFolder,
            )
          else
            ListenableBuilder(
              listenable: selection,
              builder: (context, _) => TextButton(
                onPressed: selection.count == 0
                    ? null
                    : () => Navigator.of(context).pop(selection.files),
                child: Text('決定 (${selection.count})'),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          if (_isRoot && usage != null) DriveUsageHeader(usage: usage),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) return const Center(child: CircularProgressIndicator());

    final error = _error;
    if (error != null) {
      return ScrollableMessage(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(resolveErrorMessage(error)),
            const SizedBox(height: 8),
            FilledButton(onPressed: _load, child: const Text('再試行')),
          ],
        ),
      );
    }

    final selection = widget.selection;

    return RefreshIndicator(
      onRefresh: _refresh,
      child: _folders.isEmpty && _files.isEmpty
          ? const ScrollableMessage(child: Text('ファイルはありません'))
          : NotificationListener<ScrollUpdateNotification>(
              onNotification: (n) {
                final pos = n.metrics;
                if (pos.pixels >= pos.maxScrollExtent - 200) _loadMore();
                return false;
              },
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverList.builder(
                    itemCount: _folders.length,
                    itemBuilder: (context, index) {
                      final folder = _folders[index];
                      return ListTile(
                        key: ValueKey(folder.id),
                        leading: const Icon(Icons.folder_outlined),
                        title: Text(folder.name),
                        trailing: selection == null
                            ? IconButton(
                                icon: const Icon(Icons.more_vert),
                                tooltip: 'フォルダの操作',
                                onPressed: () => _onFolderMenu(folder),
                              )
                            : null,
                        onTap: () => _openFolder(folder),
                        onLongPress: selection == null
                            ? () => _onFolderMenu(folder)
                            : null,
                      );
                    },
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    sliver: SliverGrid.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            mainAxisSpacing: 2,
                            crossAxisSpacing: 2,
                          ),
                      itemCount: _files.length,
                      itemBuilder: (context, index) {
                        final file = _files[index];
                        if (selection == null) {
                          return DriveFileTile(
                            key: ValueKey(file.id),
                            file: file,
                            onTap: () => _onFileTap(file),
                          );
                        }
                        return ListenableBuilder(
                          key: ValueKey(file.id),
                          listenable: selection,
                          builder: (context, _) => DriveFileTile(
                            file: file,
                            selected: selection.contains(file),
                            onTap: () => _onFileTap(file),
                          ),
                        );
                      },
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: _loadingMore
                        ? const Padding(
                            padding: EdgeInsets.all(16),
                            child: Center(child: CircularProgressIndicator()),
                          )
                        : const SizedBox(height: 40),
                  ),
                ],
              ),
            ),
    );
  }
}
