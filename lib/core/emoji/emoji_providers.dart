import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mischie/core/storage/prefs_store.dart';
import 'package:mischie/core/emoji/emoji_repository.dart';
import 'package:mischie/core/providers/core_providers.dart';
import 'package:mischie/features/timeline/domain/reaction_key.dart';

final emojiRepositoryProvider = Provider<EmojiRepository?>((ref) {
  final client = ref.watch(misskeyApiClientProvider);
  if (client == null) return null;
  return EmojiRepository(client);
});

final emojiCatalogProvider = FutureProvider<EmojiCatalog>((ref) async {
  final repo = ref.watch(emojiRepositoryProvider);
  if (repo == null) return EmojiCatalog.empty;
  return repo.fetchCatalog();
});

final emojiCacheProvider = FutureProvider<Map<String, String>>(
  (ref) async => (await ref.watch(emojiCatalogProvider.future)).urls,
);

final prefsStoreProvider = Provider<PrefsStore>((ref) => const PrefsStore());

/// 使ったリアクションの履歴（新しい順）。
final reactionHistoryProvider =
    AsyncNotifierProvider<ReactionHistory, List<String>>(ReactionHistory.new);

class ReactionHistory extends AsyncNotifier<List<String>> {
  static const _key = 'reaction_history';
  static const _limit = 16;

  @override
  Future<List<String>> build() async {
    final saved = await ref.read(prefsStoreProvider).read<List<dynamic>>(_key);
    final raw = saved?.cast<String>() ?? const <String>[];
    return _dedupe(raw.map(normalizeReactionKey));
  }

  Future<void> record(String reaction) async {
    final key = normalizeReactionKey(reaction);
    // 読み込み前に呼ばれると、state.value では今の記録が後から上書きされて消える。
    // 読み込みを待つ。
    final loaded = await future;
    final updated = _dedupe([key, ...loaded]);
    state = AsyncValue.data(updated);
    await ref.read(prefsStoreProvider).write(_key, updated);
  }

  List<String> _dedupe(Iterable<String> reactions) {
    final seen = <String>{};
    final result = <String>[];
    for (final reaction in reactions) {
      if (seen.add(reaction)) result.add(reaction);
    }
    return result.take(_limit).toList();
  }
}
