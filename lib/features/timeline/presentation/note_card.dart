import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:mischie/features/timeline/domain/drive_file.dart';
import 'package:mischie/features/timeline/domain/note.dart';
import 'package:mischie/features/timeline/domain/user.dart';
import 'package:timeago/timeago.dart' as timeago;

class NoteCard extends StatefulWidget {
  const NoteCard({super.key, required this.note});

  final Note note;

  @override
  State<NoteCard> createState() => _NoteCardState();
}

class _NoteCardState extends State<NoteCard> {
  bool _cwExpanded = false;

  @override
  Widget build(BuildContext context) {
    final note = widget.note;
    final displayNote = note.renote ?? note;
    final isRenote = note.renote != null;
    final hasCw = displayNote.cw != null;

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
                                child: Text(
                                  displayNote.cw!,
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
                        if (displayNote.text != null) Text(displayNote.text!),
                        if (displayNote.files.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          _MediaGrid(files: displayNote.files),
                        ],
                      ],
                      if (displayNote.reactions.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        _Reactions(reactions: displayNote.reactions),
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
  const _Reactions({required this.reactions});

  final Map<String, int> reactions;

  @override
  Widget build(BuildContext context) {
    final sorted = reactions.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: sorted.map((e) {
        // カスタム絵文字 (:name@.:) をスターに置換
        final label = e.key.replaceAll(RegExp(r':[^:]+:'), '⭐');
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            border: Border.all(
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '$label ${e.value}',
            style: Theme.of(context).textTheme.bodySmall,
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
          ? _MediaTile(file: images.first)
          : GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 2,
              crossAxisSpacing: 2,
              children: images.take(4).map((f) => _MediaTile(file: f)).toList(),
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
