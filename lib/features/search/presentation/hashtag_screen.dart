import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mischie/features/compose/presentation/compose_screen.dart';
import 'package:mischie/features/search/domain/search_notifier.dart';
import 'package:mischie/features/timeline/presentation/paged_note_list.dart';

void openHashtag(BuildContext context, String tag) {
  Navigator.of(
    context,
  ).push(MaterialPageRoute(builder: (_) => HashtagScreen(tag: tag)));
}

class HashtagScreen extends ConsumerWidget {
  const HashtagScreen({super.key, required this.tag});

  final String tag;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: Text('#$tag')),
      body: PagedNoteList(
        fetch: notePages(({untilId}) async {
          final repo = ref.read(searchRepositoryProvider);
          if (repo == null) return const [];
          return repo.notesByTag(tag, untilId: untilId);
        }),
        emptyText: 'このタグのノートはありません',
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'このタグでノートを書く',
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ComposeScreen(initialText: '#$tag '),
          ),
        ),
        child: const Icon(Icons.edit),
      ),
    );
  }
}
