import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mischie/core/emoji/emoji_providers.dart';
import 'package:mischie/core/widgets/mfm_text.dart';
import 'package:mischie/features/timeline/domain/drive_file.dart';
import 'package:mischie/features/timeline/domain/note.dart';
import 'package:mischie/features/timeline/domain/user.dart';
import 'package:timeago/timeago.dart' as timeago;

class NoteCard extends ConsumerStatefulWidget {
  const NoteCard({super.key, required this.note});

  final Note note;

  @override
  ConsumerState<NoteCard> createState() => _NoteCardState();
}

class _NoteCardState extends ConsumerState<NoteCard> {
  bool _cwExpanded = false;

  @override
  Widget build(BuildContext context) {
    final note = widget.note;
    final displayNote = note.renote ?? note;
    final isRenote = note.renote != null;
    final hasCw = displayNote.cw != null;

    // ローカルサーバー絵文字キャッシュ + ノートに紐づくリモート絵文字をマージ
    final serverEmojis = ref.watch(emojiCacheProvider).value ?? {};
    final emojis = {...serverEmojis, ...displayNote.emojis, ...displayNote.reactionEmojis};

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
                child: Text(
                  '${note.user.name ?? note.user.username} がリノート',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.secondary,
                  ),
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
                            child: _UserName(user: displayNote.user),
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
                          MfmText(
                            displayNote.text!,
                            emojis: emojis,
                          ),
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
  const _UserName({required this.user});

  final User user;

  @override
  Widget build(BuildContext context) {
    final displayName = user.name ?? user.username;
    final remoteHandle =
        user.host != null ? '@${user.username}@${user.host}' : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          displayName,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        if (remoteHandle != null)
          Text(
            remoteHandle,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.outline,
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

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            border: Border.all(
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (emojiUrl != null)
                CachedNetworkImage(
                  imageUrl: emojiUrl,
                  height: 18,
                  errorWidget: (context, url, error) => Text(e.key),
                )
              else
                Text(':$displayName:'),
              const SizedBox(width: 4),
              Text(
                '${e.value}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
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
              child: _MediaTile(file: images.first),
            )
          : AspectRatio(
              // 2 cols: 2 images → 1 row (2:1), 3-4 images → 2 rows (1:1)
              aspectRatio: images.length == 2 ? 2.0 : 1.0,
              child: GridView.count(
                crossAxisCount: 2,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 2,
                crossAxisSpacing: 2,
                children:
                    images.take(4).map((f) => _MediaTile(file: f)).toList(),
              ),
            ),
    );
  }
}

class _MediaTile extends StatelessWidget {
  const _MediaTile({required this.file});

  final DriveFile file;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        CachedNetworkImage(
          imageUrl: file.thumbnailUrl ?? file.url,
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
          ),
          errorWidget: (context, url, error) =>
              const Center(child: Icon(Icons.broken_image)),
        ),
        if (file.isSensitive)
          Container(
            color: Colors.black54,
            child: const Center(
              child: Text(
                'NSFW',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
