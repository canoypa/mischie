import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mischie/core/providers/core_providers.dart';
import 'package:mischie/features/profile/domain/user_detailed.dart';
import 'package:mischie/features/search/data/search_repository.dart';
import 'package:mischie/features/timeline/domain/note.dart';
import 'package:mischie/features/timeline/domain/note_store.dart';

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
  bool _loadingMore = false;
  bool _hasMore = true;

  @override
  Future<List<Note>> build() async {
    _hasMore = true;
    final query = ref.watch(searchQueryProvider);
    if (query.isEmpty) return const [];
    final repo = ref.watch(searchRepositoryProvider);
    if (repo == null) return const [];
    final notes = await repo.searchNotes(query);
    ref.read(noteOverridesProvider.notifier).evictFetched(notes);
    return notes;
  }

  Future<void> loadMore() async {
    if (_loadingMore || !_hasMore) return;
    final current = state.value;
    if (current == null || current.isEmpty) return;
    final repo = ref.read(searchRepositoryProvider);
    if (repo == null) return;

    final query = ref.read(searchQueryProvider);
    _loadingMore = true;
    try {
      final more = await repo.searchNotes(query, untilId: current.last.id);
      // 取得中に検索語が変わっていたら、別の検索の結果なので捨てる
      if (ref.read(searchQueryProvider) != query) return;
      if (more.isEmpty) {
        _hasMore = false;
        return;
      }
      ref.read(noteOverridesProvider.notifier).evictFetched(more);
      state = AsyncValue.data([...current, ...more]);
    } finally {
      _loadingMore = false;
    }
  }
}

final userSearchProvider =
    AsyncNotifierProvider<UserSearch, List<UserDetailed>>(UserSearch.new);

class UserSearch extends AsyncNotifier<List<UserDetailed>> {
  bool _loadingMore = false;
  bool _hasMore = true;

  @override
  Future<List<UserDetailed>> build() async {
    _hasMore = true;
    final query = ref.watch(searchQueryProvider);
    if (query.isEmpty) return const [];
    final repo = ref.watch(searchRepositoryProvider);
    if (repo == null) return const [];
    return repo.searchUsers(query);
  }

  /// users/search は untilId を取らないので件数で位置を送る。
  Future<void> loadMore() async {
    if (_loadingMore || !_hasMore) return;
    final current = state.value;
    if (current == null || current.isEmpty) return;
    final repo = ref.read(searchRepositoryProvider);
    if (repo == null) return;

    final query = ref.read(searchQueryProvider);
    _loadingMore = true;
    try {
      final more = await repo.searchUsers(query, offset: current.length);
      // 取得中に検索語が変わっていたら、別の検索の結果なので捨てる
      if (ref.read(searchQueryProvider) != query) return;
      if (more.isEmpty) {
        _hasMore = false;
        return;
      }
      state = AsyncValue.data([...current, ...more]);
    } finally {
      _loadingMore = false;
    }
  }
}
