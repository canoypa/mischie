import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mischie/core/providers/core_providers.dart';
import 'package:mischie/features/profile/domain/user_detailed.dart';
import 'package:mischie/features/search/data/search_repository.dart';
import 'package:mischie/features/timeline/domain/note.dart';

final searchRepositoryProvider = Provider<SearchRepository?>((ref) {
  final client = ref.watch(misskeyApiClientProvider);
  if (client == null) return null;
  return SearchRepository(client);
});

/// 検索語。空文字のときは検索しない。
final searchQueryProvider = NotifierProvider<SearchQuery, String>(
  SearchQuery.new,
);

class SearchQuery extends Notifier<String> {
  @override
  String build() => '';

  set query(String value) => state = value;
}

/// 検索結果は先頭 20 件で終わりではない。末尾まで読んだら続きを足す。
final noteSearchProvider = AsyncNotifierProvider<NoteSearch, List<Note>>(
  NoteSearch.new,
);

class NoteSearch extends AsyncNotifier<List<Note>> {
  @override
  Future<List<Note>> build() async {
    final query = ref.watch(searchQueryProvider);
    if (query.isEmpty) return const [];
    final repo = ref.watch(searchRepositoryProvider);
    if (repo == null) return const [];
    return repo.searchNotes(query);
  }

  Future<void> loadMore() async {
    final current = state.value;
    if (current == null || current.isEmpty) return;
    final repo = ref.read(searchRepositoryProvider);
    if (repo == null) return;
    final more = await repo.searchNotes(
      ref.read(searchQueryProvider),
      untilId: current.last.id,
    );
    if (more.isEmpty) return;
    state = AsyncValue.data([...current, ...more]);
  }
}

final userSearchProvider =
    AsyncNotifierProvider<UserSearch, List<UserDetailed>>(UserSearch.new);

class UserSearch extends AsyncNotifier<List<UserDetailed>> {
  @override
  Future<List<UserDetailed>> build() async {
    final query = ref.watch(searchQueryProvider);
    if (query.isEmpty) return const [];
    final repo = ref.watch(searchRepositoryProvider);
    if (repo == null) return const [];
    return repo.searchUsers(query);
  }

  /// users/search は untilId を取らないので件数で位置を送る。
  Future<void> loadMore() async {
    final current = state.value;
    if (current == null || current.isEmpty) return;
    final repo = ref.read(searchRepositoryProvider);
    if (repo == null) return;
    final more = await repo.searchUsers(
      ref.read(searchQueryProvider),
      offset: current.length,
    );
    if (more.isEmpty) return;
    state = AsyncValue.data([...current, ...more]);
  }
}
