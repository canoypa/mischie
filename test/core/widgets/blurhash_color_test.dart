import 'package:flutter_test/flutter_test.dart';
import 'package:mischie/core/widgets/blurhash_color.dart';

void main() {
  group('averageColorOfBlurhash', () {
    test('実サーバーが返す blurhash から色を取れる', () {
      // misskey.io のアイコンから取得したもの
      final color = averageColorOfBlurhash(
        r'eCE-UV%$0;Wab]9lb{.9p0I[?b-qJEwK${^8bcO?OYIo~C$*5RNs,-',
      );
      expect(color, isNotNull);
      expect(color!.a, 1.0);
    });

    test('短すぎる・null は色なし', () {
      expect(averageColorOfBlurhash(null), isNull);
      expect(averageColorOfBlurhash('abc'), isNull);
    });

    test('表に無い文字が混ざっていたら色なし', () {
      expect(averageColorOfBlurhash('ab<<<<xyz'), isNull);
    });
  });
}
