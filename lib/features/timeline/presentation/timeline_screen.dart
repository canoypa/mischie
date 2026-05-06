import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mischie/core/error/error_handler.dart';
import 'package:mischie/features/timeline/domain/timeline_notifier.dart';
import 'package:mischie/features/timeline/presentation/note_card.dart';

class TimelineScreen extends ConsumerWidget {
  const TimelineScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timelineAsync = ref.watch(timelineNotifierProvider);

    return timelineAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(resolveErrorMessage(e)),
            const SizedBox(height: 8),
            FilledButton(
              onPressed: () => ref.invalidate(timelineNotifierProvider),
              child: const Text('再試行'),
            ),
          ],
        ),
      ),
      data: (notes) => RefreshIndicator(
        onRefresh: () => ref.read(timelineNotifierProvider.notifier).refresh(),
        child: notes.isEmpty
            ? const Center(child: Text('ノートがありません'))
            : ListView.builder(
                itemCount: notes.length + 1,
                itemBuilder: (context, index) {
                  if (index == notes.length) {
                    return Padding(
                      padding: const EdgeInsets.all(16),
                      child: FilledButton(
                        onPressed: () => ref
                            .read(timelineNotifierProvider.notifier)
                            .loadMore(),
                        child: const Text('もっと読み込む'),
                      ),
                    );
                  }
                  return RepaintBoundary(
                    child: NoteCard(note: notes[index]),
                  );
                },
              ),
      ),
    );
  }
}
