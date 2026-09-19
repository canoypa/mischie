import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mischie/core/emoji/layered_emojis.dart';
import 'package:mischie/core/widgets/decorated_avatar.dart';
import 'package:mischie/core/widgets/mfm_text.dart';
import 'package:mischie/features/profile/presentation/user_profile_screen.dart';
import 'package:mischie/features/timeline/domain/note.dart';
import 'package:mischie/features/channel/presentation/channel_screen.dart';
import 'package:mischie/features/timeline/presentation/note_detail_screen.dart';

class QuotedNote extends StatelessWidget {
  const QuotedNote({super.key, required this.note, required this.serverEmojis});

  final Note note;
  final Map<String, String> serverEmojis;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final emojis = LayeredEmojis(base: serverEmojis, overlay: note.emojis);
    final user = note.user;
    final handle = user.host != null
        ? '@${user.username}@${user.host}'
        : '@${user.username}';
    final files = note.files;
    final isImageOnly =
        files.isNotEmpty && files.every((f) => f.type.startsWith('image/'));

    return Card.outlined(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => openNoteDetail(context, note),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 引用の中でも、名前とアイコンからは相手のプロフィールへ
              InkWell(
                borderRadius: BorderRadius.circular(4),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) =>
                        UserProfileScreen(userId: user.id, initialUser: user),
                  ),
                ),
                child: Row(
                  children: [
                    DecoratedAvatar(
                      avatarUrl: user.avatarUrl,
                      size: 20,
                      isCat: user.isCat,
                      avatarBlurhash: user.avatarBlurhash,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Flexible(
                            child: MfmText(
                              user.name ?? user.username,
                              emojis: emojis,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              handle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (note.cw != null) ...[
                const SizedBox(height: 6),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.visibility_off_outlined,
                      size: 14,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: MfmText(
                        note.cw!,
                        emojis: emojis,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ] else if (note.text != null && note.text!.isNotEmpty) ...[
                const SizedBox(height: 6),
                MfmText(
                  note.text!,
                  emojis: emojis,
                  maxLines: 6,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium,
                ),
              ],
              if (files.isNotEmpty || note.poll != null) ...[
                const SizedBox(height: 6),
                Wrap(
                  spacing: 12,
                  children: [
                    if (files.isNotEmpty)
                      _SummaryItem(
                        icon: isImageOnly
                            ? Icons.image_outlined
                            : Icons.attach_file,
                        label: isImageOnly
                            ? '画像 ${files.length} 枚'
                            : 'ファイル ${files.length} 件',
                      ),
                    if (note.poll != null)
                      const _SummaryItem(
                        icon: Icons.poll_outlined,
                        label: '投票',
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// 引用の中に出す、添付や投票の有無だけを伝える補助行。
class _SummaryItem extends StatelessWidget {
  const _SummaryItem({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.onSurfaceVariant;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: color),
        ),
      ],
    );
  }
}

/// チャンネル投稿であることを示すバッジ。タップでチャンネル画面を開く。
class ChannelBadge extends ConsumerWidget {
  const ChannelBadge({super.key, required this.channel, required this.color});

  final NoteChannel channel;
  final Color? color;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final effectiveColor = color ?? Theme.of(context).colorScheme.primary;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => openChannel(context, channel.id, name: channel.name),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.tv, size: 14, color: effectiveColor),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              channel.name,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: effectiveColor),
            ),
          ),
        ],
      ),
    );
  }
}
