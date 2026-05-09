import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blurhash/flutter_blurhash.dart';
import 'package:mischie/core/widgets/mfm_text.dart';
import 'package:mischie/features/timeline/domain/drive_file.dart';
import 'package:mischie/features/timeline/domain/note.dart';
import 'package:mischie/features/timeline/domain/user.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:timeago/timeago.dart' as timeago;

class NoteCard extends StatefulWidget {
  const NoteCard({super.key, required this.note, required this.serverEmojis});

  final Note note;

  /// サーバー全体の絵文字キャッシュ。TimelineScreen で1回だけ watch して渡す。
  final Map<String, String> serverEmojis;

  @override
  State<NoteCard> createState() => _NoteCardState();
}

class _NoteCardState extends State<NoteCard>
    with AutomaticKeepAliveClientMixin {
  bool _cwExpanded = false;

  @override
  bool get wantKeepAlive => true;

  // note.emojis / reactionEmojis とのマージ結果をキャッシュ。
  Note? _lastNote;
  Map<String, String>? _lastServerEmojis;
  Map<String, String> _emojis = const {};

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
    final note = widget.note;
    final displayNote = note.renote ?? note;
    final isRenote = note.renote != null;
    final hasCw = displayNote.cw != null;

    final emojis = _mergeEmojis(displayNote);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
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
                _Avatar(avatarUrl: displayNote.user.avatarUrl),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _UserName(
                              user: displayNote.user,
                              emojis: emojis,
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
                                  style: Theme.of(context).textTheme.bodyMedium
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
                      if (displayNote.reactions.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        _Reactions(
                          reactions: displayNote.reactions,
                          emojis: emojis,
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
    );
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
  const _Avatar({required this.avatarUrl});

  final String? avatarUrl;

  @override
  Widget build(BuildContext context) {
    if (avatarUrl == null) {
      return const CircleAvatar(radius: 20, child: Icon(Icons.person));
    }
    return CircleAvatar(
      radius: 20,
      backgroundImage: CachedNetworkImageProvider(avatarUrl!),
    );
  }
}

class _Reactions extends StatelessWidget {
  const _Reactions({required this.reactions, required this.emojis});

  final Map<String, int> reactions;
  final Map<String, String> emojis;

  @override
  Widget build(BuildContext context) {
    final sorted = reactions.entries.toList()
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
        return InkWell(
          onTap: () {
            /* TODO: リアクション送信 */
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              border: Border.all(
                color: Theme.of(context).colorScheme.primary,
              ),
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
    showDialog<void>(
      context: context,
      barrierColor: Colors.black87,
      builder: (_) =>
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

class _ImageViewerState extends State<_ImageViewer> {
  late int _current;

  @override
  void initState() {
    super.initState();
    _current = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        PhotoViewGallery.builder(
          itemCount: widget.images.length,
          pageController: PageController(initialPage: widget.initialIndex),
          onPageChanged: (i) => setState(() => _current = i),
          builder: (context, index) {
            final file = widget.images[index];
            return PhotoViewGalleryPageOptions(
              imageProvider: CachedNetworkImageProvider(file.url),
              minScale: PhotoViewComputedScale.contained,
              maxScale: PhotoViewComputedScale.covered * 3,
            );
          },
          backgroundDecoration: const BoxDecoration(color: Colors.transparent),
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
            bottom: 16,
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
      ],
    );
  }
}
