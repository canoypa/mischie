import 'package:material_ui/material_ui.dart';

/// 中身が無いときも引っ張って更新できるよう、画面の高さいっぱいの
/// スクロール領域に置く。
class ScrollableMessage extends StatelessWidget {
  const ScrollableMessage({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: Center(
            child: Padding(padding: const EdgeInsets.all(24), child: child),
          ),
        ),
      ),
    );
  }
}
