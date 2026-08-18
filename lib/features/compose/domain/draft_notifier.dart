import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mischie/features/compose/data/draft_store.dart';

final draftStoreProvider = Provider<DraftStore>((ref) => const DraftStore());

final draftsProvider = AsyncNotifierProvider<DraftsNotifier, List<Draft>>(
  DraftsNotifier.new,
);

class DraftsNotifier extends AsyncNotifier<List<Draft>> {
  @override
  Future<List<Draft>> build() => ref.read(draftStoreProvider).load();

  Future<void> save(Draft draft) async {
    final drafts = await ref.read(draftStoreProvider).put(draft);
    state = AsyncValue.data(drafts);
  }

  Future<void> remove(String id) async {
    final drafts = await ref.read(draftStoreProvider).remove(id);
    state = AsyncValue.data(drafts);
  }
}
