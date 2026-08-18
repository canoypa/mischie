import 'package:flutter/material.dart';

/// isCat のユーザーのアイコンに生やす猫耳。
///
/// アイコンの上へはみ出して描くので、置く側は Stack の `clipBehavior` を
/// `Clip.none` にしておく。
class CatEars extends StatelessWidget {
  const CatEars({super.key, required this.width, this.color, this.innerColor});

  /// アイコンの直径。耳の大きさと間隔はここから決める。
  final double width;
  final Color? color;
  final Color? innerColor;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return CustomPaint(
      size: Size(width, width * 0.55),
      painter: CatEarsPainter(
        color: color ?? colorScheme.surfaceContainerHighest,
        innerColor: innerColor ?? colorScheme.primaryContainer,
      ),
    );
  }
}

class CatEarsPainter extends CustomPainter {
  const CatEarsPainter({required this.color, required this.innerColor});

  final Color color;
  final Color innerColor;

  @override
  void paint(Canvas canvas, Size size) {
    final outer = Paint()..color = color;
    final inner = Paint()..color = innerColor;

    // 耳は外側へ倒れる。tilt が正なら右へ、負なら左へ傾く。
    void ear(double centerX, double tilt) {
      final earWidth = size.width * 0.48;
      final apexX = centerX + earWidth * tilt;
      canvas.drawPath(
        Path()
          ..moveTo(centerX - earWidth / 2, size.height)
          ..lineTo(apexX, 0)
          ..lineTo(centerX + earWidth / 2, size.height)
          ..close(),
        outer,
      );
      canvas.drawPath(
        Path()
          ..moveTo(centerX - earWidth * 0.32, size.height * 0.84)
          ..lineTo(apexX, size.height * 0.18)
          ..lineTo(centerX + earWidth * 0.32, size.height * 0.84)
          ..close(),
        inner,
      );
    }

    ear(size.width * 0.24, -0.24);
    ear(size.width * 0.76, 0.24);
  }

  @override
  bool shouldRepaint(CatEarsPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.innerColor != innerColor;
}
