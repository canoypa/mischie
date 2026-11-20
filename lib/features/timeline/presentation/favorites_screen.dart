import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mischie/features/timeline/domain/note.dart';
import 'package:mischie/features/timeline/domain/note_actions.dart';
import 'package:mischie/features/timeline/presentation/paged_note_list.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('お気に入り')),
      body: PagedNoteList(
        fetch: ({untilId}) async {
          final repo = ref.read(noteRepositoryProvider);
          if (repo == null) return (notes: const <Note>[], nextUntilId: null);
          return repo.favorites(untilId: untilId);
        },
        emptyText: 'お気に入りはありません',
      ),
    );
  }
}
