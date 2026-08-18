import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blurhash/flutter_blurhash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mischie/core/error/error_handler.dart';
import 'package:mischie/core/widgets/mfm_text.dart';
import 'package:mischie/features/auth/domain/auth_notifier.dart';
import 'package:mischie/features/compose/presentation/compose_screen.dart';
import 'package:mischie/features/profile/domain/profile_notifier.dart';
import 'package:mischie/features/profile/presentation/user_profile_screen.dart';
import 'package:mischie/features/timeline/domain/drive_file.dart';
import 'package:mischie/features/timeline/domain/note.dart';
import 'package:mischie/features/timeline/domain/note_actions.dart';
import 'package:mischie/features/timeline/domain/user.dart';
import 'package:mischie/features/timeline/presentation/note_detail_screen.dart';
import 'package:mischie/features/timeline/presentation/reaction_picker.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:url_launcher/url_launcher.dart';

class NoteCard extends ConsumerStatefulWidget {
  const NoteCard({
    super.key,
    required this.note,
    required this.serverEmojis,
    this.showActions = true,
    this.onTap,
  });

  final Note note;

  /// サーバー全体の絵文字キャッシュ。TimelineScreen で1回だけ watch して渡す。
  final Map<String, String> serverEmojis;

  /// ノート詳細では返信フォームを別に持つため、アクション行を隠せるようにする。
  final bool showActions;

  /// タップ時の遷移。既定ではノート詳細を開く。
  final VoidCallback? onTap;

  @override
  ConsumerState<NoteCard> createState() => _NoteCardState();
}

class _NoteCardState extends ConsumerState<NoteCard>
    with AutomaticKeepAliveClientMixin {
  bool _cwExpanded = false;

  @override
  bool get wantKeepAlive => true;

  // note.emojis / reactionEmojis とのマージ結果をキャッシュ。
  Note? _lastNote;
  Map<String, String>? _lastServerEmojis;
  Map<String, String> _emojis = const {};

  void _openProfile(User user) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => UserProfileScreen(userId: user.id, initialUser: user),
      ),
    );
  }

  Map<String, String> _mergeEmojis(Note displayNote) {
    if (identical(_lastServerEmojis, widget.serverEmojis) &&
        identical(_lastNote, displayNote)) {
      return _emojis;
    }
    _lastServerEmojis = widget.serverEmojis;
    _lastNote = displayNote;
    _emojis = {
      ...widget.serverEmojis,
      ...displayNote.emojis,
      ...displayNote.reactionEmojis,
    };
    return _emojis;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // AutomaticKeepAliveClientMixin required
    final note = resolveNote(ref, widget.note);
    final displayNote = note.isPureRenote ? note.renote! : note;
    final isRenote = note.isPureRenote;

    final isDeleted = ref.watch(
      deletedNoteIdsProvider.select(
        (ids) => ids.contains(note.id) || ids.contains(displayNote.id),
      ),
    );
    if (isDeleted) return const SizedBox.shrink();
    final hasCw = displayNote.cw != null;

    final emojis = _mergeEmojis(displayNote);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      // カード全体を InkWell で包むと、カードごとに ink レイヤーと
      // クリップ用の saveLayer が増えてスクロールが重くなる。
      // タップ判定だけ取れれば足りるので GestureDetector を使う。
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap ?? () => openNoteDetail(context, displayNote),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isRenote)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: [
                      Flexible(
                        child: MfmText(
                          note.user.name ?? note.user.username,
                          emojis: emojis,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                        ),
                      ),
                      Text(
                        ' がリノート',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                    ],
                  ),
                ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () => _openProfile(displayNote.user),
                    child: _Avatar(avatarUrl: displayNote.user.avatarUrl),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () => _openProfile(displayNote.user),
                                behavior: HitTestBehavior.opaque,
                                child: _UserName(
                                  user: displayNote.user,
                                  emojis: emojis,
                                ),
                              ),
                            ),
                            Text(
                              timeago.format(
                                DateTime.parse(displayNote.createdAt),
                                locale: 'ja',
                              ),
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        if (hasCw) ...[
                          GestureDetector(
                            onTap: () =>
                                setState(() => _cwExpanded = !_cwExpanded),
                            child: Row(
                              children: [
                                Expanded(
                                  child: MfmText(
                                    displayNote.cw!,
                                    emojis: emojis,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Chip(
                                  label: Text(_cwExpanded ? '隠す' : '続きを見る'),
                                  padding: EdgeInsets.zero,
                                  visualDensity: VisualDensity.compact,
                                ),
                              ],
                            ),
                          ),
                        ],
                        if (!hasCw || _cwExpanded) ...[
                          if (displayNote.text != null)
                            MfmText(displayNote.text!, emojis: emojis),
                          if (displayNote.files.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            _MediaGrid(files: displayNote.files),
                          ],
                        ],
                        // 引用リノート: 埋め込みも CW で隠す対象に含める
                        if ((!hasCw || _cwExpanded) &&
                            !isRenote &&
                            note.renote != null) ...[
                          const SizedBox(height: 8),
                          _QuotedNote(
                            note: note.renote!,
                            serverEmojis: widget.serverEmojis,
                          ),
                        ],
                        if (displayNote.reactions.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          _Reactions(
                            note: displayNote,
                            emojis: emojis,
                            onTap: (reaction) => _react(displayNote, reaction),
                          ),
                        ],
                        if (widget.showActions) ...[
                          const SizedBox(height: 4),
                          _NoteActions(
                            note: displayNote,
                            onReact: () => _pickReaction(displayNote),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickReaction(Note note) async {
    final reaction = await showReactionPicker(context);
    if (reaction == null) return;
    await _react(note, reaction);
  }

  Future<void> _react(Note note, String reaction) async {
    try {
      await ref.read(noteActionsProvider).toggleReaction(note, reaction);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(resolveErrorMessage(e))));
    }
  }
}

class _UserName extends StatelessWidget {
  const _UserName({required this.user, required this.emojis});

  final User user;
  final Map<String, String> emojis;

  @override
  Widget build(BuildContext context) {
    final displayName = user.name ?? user.username;
    final handle = user.host != null
        ? '@${user.username}@${user.host}'
        : '@${user.username}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MfmText(
          displayName,
          emojis: emojis,
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        Text(
          handle,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.avatarUrl, this.size = 40});

  final String? avatarUrl;
  final double size;

  @override
  Widget build(BuildContext context) {
    final radius = size / 2;
    if (avatarUrl == null) {
      return CircleAvatar(
        radius: radius,
        child: Icon(Icons.person, size: radius),
      );
    }
    return CircleAvatar(
      radius: radius,
      backgroundImage: CachedNetworkImageProvider(avatarUrl!),
    );
  }
}

class _Reactions extends StatelessWidget {
  const _Reactions({
    required this.note,
    required this.emojis,
    required this.onTap,
  });

  final Note note;
  final Map<String, String> emojis;
  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) {
    final sorted = note.reactions.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: sorted.map((e) {
        // `:name:` または `:name@server.tld:` 形式からキーを抽出
        final match = RegExp(r'^:([^:]+):$').firstMatch(e.key);
        final identifier = match?.group(1) ?? e.key;
        // フルキー (name@server.tld) でまず検索し、なければ短縮名 (name) で検索
        var emojiUrl = emojis[identifier];
        if (emojiUrl == null) {
          final atIndex = identifier.indexOf('@');
          if (atIndex > 0) {
            emojiUrl = emojis[identifier.substring(0, atIndex)];
          }
        }
        final displayName = identifier.contains('@')
            ? identifier.substring(0, identifier.indexOf('@'))
            : identifier;
        // match != null → カスタム絵文字 (:name:)、null → Unicode 絵文字
        final isCustomEmoji = match != null;
        // 外部サーバーの絵文字（name@host 形式）はリアクション不可
        final isExternal = identifier.contains('@');

        final emojiWidget = Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (emojiUrl != null)
              CachedNetworkImage(
                imageUrl: emojiUrl,
                height: 22,
                errorWidget: (context, url, error) => Text(e.key),
              )
            else
              Text(
                isCustomEmoji ? ':$displayName:' : displayName,
                style: const TextStyle(fontSize: 16),
              ),
            const SizedBox(width: 6),
            Text('${e.value}', style: Theme.of(context).textTheme.bodySmall),
          ],
        );

        if (isExternal) {
          // 外部サーバーの絵文字: 絵文字は通常表示、ボタンとして無効（タップ不可・枠線を薄く）
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              border: Border.all(
                color: Theme.of(context).colorScheme.outlineVariant,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: emojiWidget,
          );
        }

        // 現在のサーバーの絵文字: タップ可能なアクティブボタン
        final isMine = note.myReaction == e.key;
        final colorScheme = Theme.of(context).colorScheme;
        return InkWell(
          onTap: () => onTap(e.key),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isMine ? colorScheme.primaryContainer : null,
              border: Border.all(color: colorScheme.primary),
              borderRadius: BorderRadius.circular(16),
            ),
            child: emojiWidget,
          ),
        );
      }).toList(),
    );
  }
}

class _MediaGrid extends StatelessWidget {
  const _MediaGrid({required this.files});

  final List<DriveFile> files;

  @override
  Widget build(BuildContext context) {
    final images = files.where((f) => f.type.startsWith('image/')).toList();
    if (images.isEmpty) return const SizedBox.shrink();

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: images.length == 1
          ? AspectRatio(
              aspectRatio: 16 / 9,
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

    return GestureDetector(
      onTap: showOverlay ? null : _openViewer,
      child: Stack(
        fit: StackFit.expand,
        children: [
          CachedNetworkImage(
            imageUrl: file.thumbnailUrl ?? file.url,
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
                    imageProvider: CachedNetworkImageProvider(file.url),
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
class _NoteActions extends ConsumerWidget {
  const _NoteActions({required this.note, required this.onReact});

  final Note note;
  final VoidCallback onReact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final myId = ref.watch(profileNotifierProvider).value?.id;
    final isMine = myId != null && myId == (note.userId ?? note.user.id);
    // ダイレクト/フォロワー限定はリノートできない
    final canRenote =
        note.visibility != 'specified' && note.visibility != 'followers';

    return Row(
      children: [
        _ActionButton(
          icon: Icons.reply,
          count: note.repliesCount,
          tooltip: '返信',
          onPressed: () => _openReply(context),
        ),
        _ActionButton(
          icon: Icons.repeat,
          count: note.renoteCount,
          tooltip: 'リノート',
          color: canRenote ? null : colorScheme.outlineVariant,
          onPressed: canRenote ? () => _showRenoteMenu(context, ref) : null,
        ),
        _ActionButton(
          icon: note.myReaction != null
              ? Icons.emoji_emotions
              : Icons.add_reaction_outlined,
          tooltip: 'リアクション',
          color: note.myReaction != null ? colorScheme.primary : null,
          onPressed: onReact,
        ),
        const Spacer(),
        _ActionButton(
          icon: Icons.more_horiz,
          tooltip: 'その他',
          onPressed: () => _showMoreMenu(context, ref, isMine: isMine),
        ),
      ],
    );
  }

  void _openReply(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => ComposeScreen(replyTo: note)));
  }

  Future<void> _showRenoteMenu(BuildContext context, WidgetRef ref) async {
    final action = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.repeat),
              title: const Text('リノート'),
              onTap: () => Navigator.of(context).pop('renote'),
            ),
            ListTile(
              leading: const Icon(Icons.format_quote),
              title: const Text('引用'),
              onTap: () => Navigator.of(context).pop('quote'),
            ),
            ListTile(
              leading: const Icon(Icons.repeat_on_outlined),
              title: const Text('リノート解除'),
              onTap: () => Navigator.of(context).pop('unrenote'),
            ),
          ],
        ),
      ),
    );
    if (action == null || !context.mounted) return;

    switch (action) {
      case 'quote':
        await Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => ComposeScreen(quoteOf: note)));
      case 'renote':
        await _run(context, () => ref.read(noteActionsProvider).renote(note));
        if (context.mounted) _toast(context, 'リノートしました');
      case 'unrenote':
        await _run(context, () => ref.read(noteActionsProvider).unrenote(note));
        if (context.mounted) _toast(context, 'リノートを解除しました');
    }
  }

  Future<void> _showMoreMenu(
    BuildContext context,
    WidgetRef ref, {
    required bool isMine,
  }) async {
    final action = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.link),
              title: const Text('リンクをコピー'),
              onTap: () => Navigator.of(context).pop('copy'),
            ),
            ListTile(
              leading: const Icon(Icons.content_copy),
              title: const Text('本文をコピー'),
              onTap: () => Navigator.of(context).pop('copyText'),
            ),
            ListTile(
              leading: const Icon(Icons.open_in_browser),
              title: const Text('ブラウザで開く'),
              onTap: () => Navigator.of(context).pop('browser'),
            ),
            if (isMine)
              ListTile(
                leading: Icon(
                  Icons.delete_outline,
                  color: Theme.of(context).colorScheme.error,
                ),
                title: Text(
                  '削除',
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
                onTap: () => Navigator.of(context).pop('delete'),
              ),
          ],
        ),
      ),
    );
    if (action == null || !context.mounted) return;

    switch (action) {
      case 'copy':
        final link = _noteUrl(ref, note);
        if (link == null) return;
        await Clipboard.setData(ClipboardData(text: link));
        if (context.mounted) _toast(context, 'リンクをコピーしました');
      case 'copyText':
        await Clipboard.setData(ClipboardData(text: note.text ?? ''));
        if (context.mounted) _toast(context, 'コピーしました');
      case 'browser':
        final url = _noteUrl(ref, note);
        if (url != null) {
          await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
        }
      case 'delete':
        final ok = await _confirmDelete(context);
        if (ok != true || !context.mounted) return;
        await _run(context, () => ref.read(noteActionsProvider).delete(note));
        if (context.mounted) _toast(context, '削除しました');
    }
  }

  Future<bool?> _confirmDelete(BuildContext context) => showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('ノートを削除'),
      content: const Text('この操作は取り消せません。削除しますか？'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('キャンセル'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('削除'),
        ),
      ],
    ),
  );

  /// リモートのノートは元サーバーの URL。ローカルのノートは API が url を
  /// 返さないので、ログイン中のホストから組み立てる。
  String? _noteUrl(WidgetRef ref, Note note) {
    final remote = note.url ?? note.uri;
    if (remote != null) return remote;
    final host = ref.read(currentHostProvider);
    return host == null ? null : 'https://$host/notes/${note.id}';
  }

  Future<void> _run(
    BuildContext context,
    Future<void> Function() action,
  ) async {
    try {
      await action();
    } catch (e) {
      if (!context.mounted) return;
      _toast(context, resolveErrorMessage(e));
    }
  }

  void _toast(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.count,
    this.color,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;
  final int? count;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final effectiveColor =
        color ?? Theme.of(context).colorScheme.onSurfaceVariant;

    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: effectiveColor),
              if (count != null && count! > 0) ...[
                const SizedBox(width: 4),
                Text(
                  '$count',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: effectiveColor),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// 引用リノートの中に埋め込まれる、枠付きの小さなノート。
class _QuotedNote extends StatelessWidget {
  const _QuotedNote({required this.note, required this.serverEmojis});

  final Note note;
  final Map<String, String> serverEmojis;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final emojis = {...serverEmojis, ...note.emojis};

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => openNoteDetail(context, note),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          border: Border.all(color: colorScheme.outlineVariant),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _Avatar(avatarUrl: note.user.avatarUrl, size: 20),
                const SizedBox(width: 6),
                Flexible(
                  child: MfmText(
                    note.user.name ?? note.user.username,
                    emojis: emojis,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ],
            ),
            if (note.text != null) ...[
              const SizedBox(height: 6),
              MfmText(
                note.text!,
                emojis: emojis,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
