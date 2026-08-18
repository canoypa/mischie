import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mischie/core/storage/prefs_store.dart';
import 'package:mischie/core/emoji/emoji_repository.dart';
import 'package:mischie/core/providers/core_providers.dart';

final emojiRepositoryProvider = Provider<EmojiRepository?>((ref) {
  final client = ref.watch(misskeyApiClientProvider).value;
  if (client == null) return null;
  return EmojiRepository(client);
});

/// サーバーの全カスタム絵文字キャッシュ (shortcode name → URL)
/// 一度取得したら再利用する。ログアウト/ログイン時は自動で invalidate される。
final emojiCacheProvider = FutureProvider<Map<String, String>>((ref) async {
  final repo = ref.watch(emojiRepositoryProvider);
  if (repo == null) return {};
  return repo.fetchEmojis();
});

final prefsStoreProvider = Provider<PrefsStore>((ref) => const PrefsStore());

/// よく使うリアクションの履歴（新しい順）。
///
/// 毎回グリッドから探させると、同じ絵文字を押すだけでも手間がかかる。
final reactionHistoryProvider =
    AsyncNotifierProvider<ReactionHistory, List<String>>(ReactionHistory.new);

class ReactionHistory extends AsyncNotifier<List<String>> {
  static const _key = 'reaction_history';
  static const _limit = 16;

  @override
  Future<List<String>> build() async {
    final saved = await ref.read(prefsStoreProvider).read<List<dynamic>>(_key);
    return saved?.cast<String>() ?? const [];
  }

  Future<void> record(String reaction) async {
    final current = state.value ?? const <String>[];
    final updated = [
      reaction,
      ...current.where((e) => e != reaction),
    ].take(_limit).toList();
    state = AsyncValue.data(updated);
    await ref.read(prefsStoreProvider).write(_key, updated);
  }
}
