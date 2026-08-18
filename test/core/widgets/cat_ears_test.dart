import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mischie/core/widgets/cat_ears.dart';

void main() {
  testWidgets('猫耳がアイコンの上に描かれる', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          backgroundColor: const Color(0xFF101010),
          body: Center(
            child: SizedBox(
              width: 120,
              height: 120,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  const Positioned(
                    top: -40,
                    left: 0,
                    right: 0,
                    child: CatEars(width: 120),
                  ),
                  Container(
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFF6B4E3D),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    await expectLater(
      find.byType(Stack).first,
      matchesGoldenFile('goldens/cat_ears.png'),
    );
  });
}
