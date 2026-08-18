import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mischie/core/providers/core_providers.dart';
import 'package:mischie/features/profile/domain/user_detailed.dart';
import 'package:mischie/features/search/data/search_repository.dart';
import 'package:mischie/features/timeline/domain/note.dart';

final searchRepositoryProvider = Provider<SearchRepository?>((ref) {
  final client = ref.watch(misskeyApiClientProvider).value;
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

final noteSearchProvider = FutureProvider.autoDispose<List<Note>>((ref) async {
  final query = ref.watch(searchQueryProvider);
  if (query.isEmpty) return const [];
  final repo = ref.watch(searchRepositoryProvider);
  if (repo == null) return const [];
  return repo.searchNotes(query);
});

final userSearchProvider = FutureProvider.autoDispose<List<UserDetailed>>((
  ref,
) async {
  final query = ref.watch(searchQueryProvider);
  if (query.isEmpty) return const [];
  final repo = ref.watch(searchRepositoryProvider);
  if (repo == null) return const [];
  return repo.searchUsers(query);
});
