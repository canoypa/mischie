import 'package:flutter_test/flutter_test.dart';
import 'package:mischie/core/emoji/layered_emojis.dart';

void main() {
  group('LayeredEmojis', () {
    const base = {'a': 'base-a', 'b': 'base-b'};
    const overlay = {'b': 'note-b', 'c': 'note-c'};
    const layered = LayeredEmojis(base: base, overlay: overlay);

    test('ノート固有の定義が優先される', () {
      expect(layered['b'], 'note-b');
    });

    test('無ければサーバー全体から引く', () {
      expect(layered['a'], 'base-a');
    });

    test('どちらにも無ければ null', () {
      expect(layered['zzz'], isNull);
    });

    test('キーは重複せず両方を返す', () {
      expect(layered.keys.toSet(), {'a', 'b', 'c'});
      expect(layered.keys.length, 3);
    });

    test('元のマップを複製しない', () {
      // タイムラインではノートごとに生成されるので、ここが複製だと
      // 絵文字の数だけコストが積み上がる
      expect(identical(layered.base, base), isTrue);
    });
  });
}
