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
    final colorScheme = Theme.of(context).colorScheme;
    final emojis = LayeredEmojis(base: serverEmojis, overlay: note.emojis);

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
            // 引用の中でも、名前とアイコンからは相手のプロフィールへ
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => UserProfileScreen(
                    userId: note.user.id,
                    initialUser: note.user,
                  ),
                ),
              ),
              child: Row(
                children: [
                  DecoratedAvatar(
                    avatarUrl: note.user.avatarUrl,
                    size: 20,
                    isCat: note.user.isCat,
                    avatarBlurhash: note.user.avatarBlurhash,
                  ),
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
