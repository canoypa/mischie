import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mischie/core/emoji/emoji_providers.dart';
import 'package:mischie/core/error/error_handler.dart';
import 'package:mischie/core/widgets/decorated_avatar.dart';
import 'package:mischie/core/widgets/mfm_text.dart';
import 'package:mischie/features/profile/presentation/user_profile_screen.dart';
import 'package:mischie/features/timeline/domain/note_actions.dart';
import 'package:mischie/features/timeline/domain/user.dart';

final _reactionUsersProvider = FutureProvider.autoDispose
    .family<List<User>, ({String noteId, String reaction})>((ref, key) async {
      final repo = ref.watch(noteRepositoryProvider);
      if (repo == null) return const [];
      return repo.reactionUsers(key.noteId, type: key.reaction);
    });

void showReactionUsers(
  BuildContext context, {
  required String noteId,
  required String reaction,
  required Widget title,
}) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => DraggableScrollableSheet(
      initialChildSize: 0.5,
      maxChildSize: 0.9,
      expand: false,
      builder: (_, controller) => _ReactionUsers(
        hostContext: context,
        noteId: noteId,
        reaction: reaction,
        title: title,
        controller: controller,
      ),
    ),
  );
}

class _ReactionUsers extends ConsumerWidget {
  const _ReactionUsers({
    required this.hostContext,
    required this.noteId,
    required this.reaction,
    required this.title,
    required this.controller,
  });

  /// シートを開いた画面。シートを閉じた後のプロフィールはこちらから開く。
  final BuildContext hostContext;
  final String noteId;
  final String reaction;
  final Widget title;
  final ScrollController controller;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final emojis = ref.watch(emojiCacheProvider).value ?? const {};
    final users = ref.watch(
      _reactionUsersProvider((noteId: noteId, reaction: reaction)),
    );
    return Column(
      children: [
        Padding(padding: const EdgeInsets.only(bottom: 8), child: title),
        const Divider(height: 1),
        Expanded(
          child: users.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text(resolveErrorMessage(e))),
            data: (users) => ListView.builder(
              controller: controller,
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];
                return ListTile(
                  leading: DecoratedAvatar(
                    avatarUrl: user.avatarUrl,
                    size: 40,
                    isCat: user.isCat,
                    avatarBlurhash: user.avatarBlurhash,
                    decorations: user.avatarDecorations,
                  ),
                  title: MfmText(
                    user.name ?? user.username,
                    emojis: emojis,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(user.acct),
                  onTap: () {
                    Navigator.of(context).pop();
                    openUserProfile(hostContext, user.id, initialUser: user);
                  },
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
