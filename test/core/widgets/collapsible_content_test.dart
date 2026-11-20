import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mischie/core/widgets/collapsible_content.dart';

Widget _wrap(double contentHeight) => MaterialApp(
  home: Scaffold(
    // 展開時は画面より高くなるのでスクロールできるようにしておく
    body: SingleChildScrollView(
      child: SizedBox(
        width: 300,
        child: CollapsibleContent(
          maxHeight: 200,
          child: Container(
            height: contentHeight,
            color: const Color(0xFF3355FF),
          ),
        ),
      ),
    ),
  ),
);

void main() {
  testWidgets('閾値より低い中身は折りたたまない', (tester) async {
    await tester.pumpWidget(_wrap(120));
    await tester.pumpAndSettle();

    expect(find.text('続きを見る'), findsNothing);
    expect(tester.getSize(find.byType(Container)).height, 120);
  });

  testWidgets('閾値を超えると切り詰めて「続きを見る」を出す', (tester) async {
    await tester.pumpWidget(_wrap(600));
    await tester.pumpAndSettle();

    expect(find.text('続きを見る'), findsOneWidget);
    expect(tester.getSize(find.byType(Container)).height, 600);
    expect(
      tester.getSize(find.byType(CollapsibleContent)).height,
      lessThan(300),
    );
  });

  testWidgets('展開すると全体が出て、折りたたみに戻せる', (tester) async {
    await tester.pumpWidget(_wrap(600));
    await tester.pumpAndSettle();

    await tester.tap(find.text('続きを見る'));
    await tester.pumpAndSettle();

    expect(find.text('折りたたむ'), findsOneWidget);
    expect(
      tester.getSize(find.byType(CollapsibleContent)).height,
      greaterThan(600),
    );

    await tester.ensureVisible(find.text('折りたたむ'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('折りたたむ'));
    await tester.pumpAndSettle();
    expect(find.text('続きを見る'), findsOneWidget);
  });
}
