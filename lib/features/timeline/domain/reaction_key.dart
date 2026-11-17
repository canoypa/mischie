final _customEmojiPattern = RegExp(r'^:([^:]+):$');

/// サーバーが返すキーの形へ揃える。揃えないと同じ絵文字が別キーになる。
/// カスタム絵文字は `:name:` を `:name@.:` に、Unicode 絵文字は VS16 を落とす
/// （ZWJ 合成絵文字では VS16 が構成要素なので残す）。
String normalizeReactionKey(String reaction) {
  final match = _customEmojiPattern.firstMatch(reaction);
  if (match != null) {
    final identifier = match.group(1)!;
    return identifier.contains('@') ? reaction : ':$identifier@.:';
  }
  if (reaction.contains('\u200d')) return reaction;
  return reaction.replaceAll('\ufe0f', '');
}
