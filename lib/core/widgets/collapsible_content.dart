import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';

/// 長いノートを、描画後の高さで折りたたむ。
///
/// 本文を文字数で切ると MFM（装飾・絵文字・引用）の途中で切れて表現が壊れる。
/// ここでは中身をそのまま組んだうえで、実測の高さが [maxHeight] を超えた
/// ときだけ表示を切り詰める。
class CollapsibleContent extends StatefulWidget {
  const CollapsibleContent({
    super.key,
    required this.child,
    this.maxHeight = 320,
  });

  final Widget child;
  final double maxHeight;

  @override
  State<CollapsibleContent> createState() => _CollapsibleContentState();
}

class _CollapsibleContentState extends State<CollapsibleContent> {
  bool _expanded = false;
  bool _overflowing = false;

  @override
  Widget build(BuildContext context) {
    if (_expanded) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          widget.child,
          _ToggleButton(
            expanded: true,
            onPressed: () => setState(() => _expanded = false),
          ),
        ],
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          children: [
            _MaxHeight(
              maxHeight: widget.maxHeight,
              onOverflowChanged: (value) {
                if (mounted && value != _overflowing) {
                  setState(() => _overflowing = value);
                }
              },
              child: widget.child,
            ),
            if (_overflowing)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                height: 40,
                child: IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Theme.of(
                            context,
                          ).colorScheme.surfaceContainerLow.withAlpha(0),
                          Theme.of(context).colorScheme.surfaceContainerLow,
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
        if (_overflowing)
          _ToggleButton(
            expanded: false,
            onPressed: () => setState(() => _expanded = true),
          ),
      ],
    );
  }
}

class _ToggleButton extends StatelessWidget {
  const _ToggleButton({required this.expanded, required this.onPressed});

  final bool expanded;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: TextButton.icon(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          minimumSize: const Size(0, 32),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        icon: Icon(expanded ? Icons.expand_less : Icons.expand_more, size: 18),
        label: Text(expanded ? '折りたたむ' : '続きを見る'),
      ),
    );
  }
}

/// 子を高さ無制限で組んだうえで、[maxHeight] までに切り詰めて描く。
class _MaxHeight extends SingleChildRenderObjectWidget {
  const _MaxHeight({
    required super.child,
    required this.maxHeight,
    required this.onOverflowChanged,
  });

  final double maxHeight;
  final ValueChanged<bool> onOverflowChanged;

  @override
  RenderObject createRenderObject(BuildContext context) => _RenderMaxHeight(
    maxHeight: maxHeight,
    onOverflowChanged: onOverflowChanged,
  );

  @override
  void updateRenderObject(BuildContext context, _RenderMaxHeight renderObject) {
    renderObject
      ..maxHeight = maxHeight
      ..onOverflowChanged = onOverflowChanged;
  }
}

class _RenderMaxHeight extends RenderBox
    with RenderObjectWithChildMixin<RenderBox> {
  _RenderMaxHeight({required double maxHeight, required this.onOverflowChanged})
    : _maxHeight = maxHeight;

  double _maxHeight;
  bool? _lastOverflowing;

  ValueChanged<bool> onOverflowChanged;

  set maxHeight(double value) {
    if (_maxHeight == value) return;
    _maxHeight = value;
    markNeedsLayout();
  }

  @override
  void performLayout() {
    final child = this.child;
    if (child == null) {
      size = constraints.smallest;
      return;
    }

    // 高さは無制限で組む。ここで切ると中身の折り返しが変わってしまう。
    child.layout(
      BoxConstraints(
        minWidth: constraints.minWidth,
        maxWidth: constraints.maxWidth,
      ),
      parentUsesSize: true,
    );

    final overflowing = child.size.height > _maxHeight + 0.5;
    size = constraints.constrain(
      Size(child.size.width, math.min(child.size.height, _maxHeight)),
    );

    if (overflowing != _lastOverflowing) {
      _lastOverflowing = overflowing;
      // レイアウト中に setState は呼べないのでフレーム後に通知する
      SchedulerBinding.instance.addPostFrameCallback(
        (_) => onOverflowChanged(overflowing),
      );
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final child = this.child;
    if (child == null) return;
    if (child.size.height <= size.height) {
      context.paintChild(child, offset);
      return;
    }
    context.pushClipRect(
      needsCompositing,
      offset,
      Offset.zero & size,
      (context, offset) => context.paintChild(child, offset),
    );
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    final child = this.child;
    if (child == null) return false;
    return result.addWithPaintOffset(
      offset: Offset.zero,
      position: position,
      hitTest: (result, transformed) =>
          child.hitTest(result, position: transformed),
    );
  }

  @override
  double computeMinIntrinsicWidth(double height) =>
      child?.getMinIntrinsicWidth(height) ?? 0;

  @override
  double computeMaxIntrinsicWidth(double height) =>
      child?.getMaxIntrinsicWidth(height) ?? 0;

  @override
  double computeMinIntrinsicHeight(double width) =>
      math.min(child?.getMinIntrinsicHeight(width) ?? 0, _maxHeight);

  @override
  double computeMaxIntrinsicHeight(double width) =>
      math.min(child?.getMaxIntrinsicHeight(width) ?? 0, _maxHeight);
}
