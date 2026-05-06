import 'package:flutter_riverpod/flutter_riverpod.dart';
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
