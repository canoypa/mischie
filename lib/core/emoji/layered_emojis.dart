import 'dart:collection';

/// ノートごとにサーバー全体の絵文字マップを複製しないよう、コピーせずに重ねて引く。
class LayeredEmojis extends UnmodifiableMapBase<String, String> {
  const LayeredEmojis({required this.base, required this.overlay});

  final Map<String, String> base;

  final Map<String, String> overlay;

  @override
  String? operator [](Object? key) => overlay[key] ?? base[key];

  @override
  bool containsKey(Object? key) =>
      overlay.containsKey(key) || base.containsKey(key);

  @override
  Iterable<String> get keys => overlay.keys.followedBy(
    base.keys.where((key) => !overlay.containsKey(key)),
  );
}
