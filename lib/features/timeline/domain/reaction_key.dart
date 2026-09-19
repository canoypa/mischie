final _customEmojiPattern = RegExp(r'^:([^:]+):$');

/// リアクションキーをサーバーが実際に保持する形へ揃える。
///
/// - カスタム絵文字はホスト無し表記 (`:name:`) をローカルホスト表記
///   (`:name@.:`) にする。サーバーはリアクションのキーに必ずホストを
///   付けて返す・配信するため、揃えないと同じ絵文字が別キーとして
///   扱われ、チップが二重に出たり自分のリアクションが認識されない。
/// - Unicode 絵文字は VS16 (U+FE0F) を落とす。ただし ZWJ (U+200D) を
///   含む合成絵文字では VS16 が構成要素そのものなので落とすと崩れる。
String normalizeReactionKey(String reaction) {
  final match = _customEmojiPattern.firstMatch(reaction);
  if (match != null) {
    final identifier = match.group(1)!;
    return identifier.contains('@') ? reaction : ':$identifier@.:';
  }
  if (reaction.contains('\u200d')) return reaction;
  return reaction.replaceAll('\ufe0f', '');
}
