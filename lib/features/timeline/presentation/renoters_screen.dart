import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mischie/core/emoji/emoji_providers.dart';
import 'package:mischie/core/error/error_handler.dart';
import 'package:mischie/core/widgets/decorated_avatar.dart';
import 'package:mischie/core/widgets/mfm_text.dart';
import 'package:mischie/features/profile/presentation/user_profile_screen.dart';
import 'package:mischie/features/timeline/domain/note.dart';
import 'package:mischie/features/timeline/domain/note_actions.dart';
import 'package:mischie/features/timeline/domain/note_store.dart';
import 'package:mischie/features/timeline/presentation/note_detail_screen.dart';

/// 引用も含むので、本文があれば出す。
final renotersProvider = FutureProvider.autoDispose.family<List<Note>, String>((
  ref,
  noteId,
) async {
  final repo = ref.watch(noteRepositoryProvider);
  if (repo == null) return const [];
  final notes = await repo.renotes(noteId);
  ref.read(noteOverridesProvider.notifier).evictFetched(notes);
  return notes;
});

void openRenoters(BuildContext context, String noteId) {
  Navigator.of(
    context,
  ).push(MaterialPageRoute(builder: (_) => RenotersScreen(noteId: noteId)));
}

class RenotersScreen extends ConsumerWidget {
  const RenotersScreen({super.key, required this.noteId});

  final String noteId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final serverEmojis = ref.watch(emojiCacheProvider).value ?? const {};

    return Scaffold(
      appBar: AppBar(title: const Text('リノートした人')),
      body: ref
          .watch(renotersProvider(noteId))
          .when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(resolveErrorMessage(e)),
                  const SizedBox(height: 8),
                  FilledButton(
                    onPressed: () => ref.invalidate(renotersProvider(noteId)),
                    child: const Text('再試行'),
                  ),
                ],
              ),
            ),
            data: (notes) => notes.isEmpty
                ? const Center(child: Text('まだ誰もリノートしていません'))
                : ListView.builder(
                    itemCount: notes.length,
                    itemBuilder: (context, index) =>
                        _RenoterTile(note: notes[index], emojis: serverEmojis),
                  ),
          ),
    );
  }
}

class _RenoterTile extends StatelessWidget {
  const _RenoterTile({required this.note, required this.emojis});

  final Note note;
  final Map<String, String> emojis;

  @override
  Widget build(BuildContext context) {
    final user = note.user;
    final handle = user.acct;
    // 本文があれば引用。無ければそのままのリノート。
    final comment = note.text;

    return ListTile(
      leading: DecoratedAvatar(
        avatarUrl: user.avatarUrl,
        isCat: user.isCat,
        avatarBlurhash: user.avatarBlurhash,
        decorations: user.avatarDecorations,
      ),
      title: MfmText(user.name ?? user.username, emojis: emojis),
      subtitle: comment == null || comment.isEmpty
          ? Text(handle)
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(handle),
                const SizedBox(height: 2),
                MfmText(
                  comment,
                  emojis: emojis,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
      isThreeLine: comment != null && comment.isNotEmpty,
      onTap: comment == null || comment.isEmpty
          // そのままのリノートは中身が無いので、その人のところへ
          ? () => openUserProfile(context, user.id, initialUser: user)
          : () => openNoteDetail(context, note),
    );
  }
}
