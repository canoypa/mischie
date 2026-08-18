import 'dart:collection';

/// サーバー全体の絵文字と、ノート固有の絵文字を、コピーせずに重ねて引く。
///
/// `{...serverEmojis, ...note.emojis}` と書くとノート 1 件ごとにサーバー全体の
/// マップが複製される。カスタム絵文字は数千〜1 万件規模になりうるため、
/// タイムラインを流すだけで巨大なコピーが積み上がる。
class LayeredEmojis extends UnmodifiableMapBase<String, String> {
  const LayeredEmojis({required this.base, required this.overlay});

  /// サーバー全体のキャッシュ。共有され、複製しない。
  final Map<String, String> base;

  /// ノート固有の定義。こちらを優先する。
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
