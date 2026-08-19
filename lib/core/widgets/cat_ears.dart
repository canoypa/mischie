import 'package:flutter/material.dart';

/// isCat のユーザーのアイコンに生やす猫耳。
///
/// アイコンの上へはみ出して描くので、置く側は Stack の `clipBehavior` を
/// `Clip.none` にしておく。色はアイコンの平均色に合わせる。素の三角形だと
/// アイコンから浮くうえ、猫らしさも出ない。
class CatEars extends StatelessWidget {
  const CatEars({super.key, required this.width, this.color, this.innerColor});

  /// アイコンの直径。耳の大きさと間隔はここから決める。
  final double width;

  /// 耳の色。アイコンの平均色を渡す。省略時はテーマの色を使う。
  final Color? color;
  final Color? innerColor;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final base = color ?? colorScheme.surfaceContainerHighest;
    return CustomPaint(
      size: Size(width, width * 0.42),
      painter: CatEarsPainter(
        color: base,
        // 内側は少し明るく。同系色のまま濃淡で耳の内外を描き分ける。
        innerColor: innerColor ?? _lighten(base),
      ),
    );
  }

  static Color _lighten(Color color) =>
      Color.lerp(color, const Color(0xFFFFFFFF), 0.45)!;
}

class CatEarsPainter extends CustomPainter {
  const CatEarsPainter({required this.color, required this.innerColor});

  final Color color;
  final Color innerColor;

  @override
  void paint(Canvas canvas, Size size) {
    final outer = Paint()
      ..color = color
      ..isAntiAlias = true;
    final inner = Paint()
      ..color = innerColor
      ..isAntiAlias = true;

    /// [side] が -1 なら左耳、1 なら右耳。
    void ear(double side) {
      final w = size.width;
      final h = size.height;
      // 猫の耳は根元が広く、先が外へ倒れる。細長いと狐になる。
      final baseInner = w * (0.5 + side * 0.10);
      final baseOuter = w * (0.5 + side * 0.52);
      final tipX = w * (0.5 + side * 0.40);

      // 外側は膨らませ、内側はくぼませる。直線で結ぶと三角形になる。
      canvas.drawPath(
        Path()
          ..moveTo(baseInner, h)
          ..quadraticBezierTo(w * (0.5 + side * 0.12), h * 0.34, tipX, h * 0.06)
          ..quadraticBezierTo(w * (0.5 + side * 0.5), h * 0.3, baseOuter, h)
          ..close(),
        outer,
      );

      // 内側の耳。輪郭を細く残すため一回り小さく描く。
      canvas.drawPath(
        Path()
          ..moveTo(w * (0.5 + side * 0.18), h * 0.96)
          ..quadraticBezierTo(
            w * (0.5 + side * 0.24),
            h * 0.42,
            w * (0.5 + side * 0.38),
            h * 0.22,
          )
          ..quadraticBezierTo(
            w * (0.5 + side * 0.47),
            h * 0.44,
            w * (0.5 + side * 0.45),
            h * 0.96,
          )
          ..close(),
        inner,
      );
    }

    ear(-1);
    ear(1);
  }

  @override
  bool shouldRepaint(CatEarsPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.innerColor != innerColor;
}
