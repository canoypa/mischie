import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:mischie/core/widgets/cat_ears.dart';
import 'package:mischie/core/widgets/collapsible_content.dart';
import 'package:mischie/core/widgets/decorated_avatar.dart';

/// `dart:io` に依存するウィジェットはプレビューで動かないため、ここには置かず
/// ゴールデンで確かめる。

/// 配色は MischieApp のテーマと揃えておく。
final class _MischiePreview extends MultiPreview {
  const _MischiePreview({required this.previewName, this.previewSize});

  final String previewName;
  final Size? previewSize;

  static const _seed = Color(0xFFA8E800);

  @override
  List<Preview> get previews => [
    Preview(
      name: '$previewName / light',
      size: previewSize,
      theme: _theme,
      brightness: Brightness.light,
    ),
    Preview(
      name: '$previewName / dark',
      size: previewSize,
      theme: _theme,
      brightness: Brightness.dark,
    ),
  ];

  static PreviewThemeData _theme() => PreviewThemeData(
    materialLight: ThemeData(useMaterial3: true, colorSchemeSeed: _seed),
    materialDark: ThemeData(
      useMaterial3: true,
      colorSchemeSeed: _seed,
      brightness: Brightness.dark,
    ),
  );
}

@_MischiePreview(previewName: '猫耳アイコン', previewSize: Size(240, 160))
Widget catAvatars() {
  return const Center(
    child: Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 24,
      children: [
        DecoratedAvatar(avatarUrl: null, size: 40, isCat: true),
        DecoratedAvatar(avatarUrl: null, size: 64, isCat: true),
        DecoratedAvatar(avatarUrl: null, size: 40),
      ],
    ),
  );
}

@_MischiePreview(previewName: '猫耳の形', previewSize: Size(240, 160))
Widget catEars() {
  return const Center(
    child: SizedBox(
      width: 120,
      height: 120,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(top: -40, left: 0, right: 0, child: CatEars(width: 120)),
          CircleAvatar(radius: 60),
        ],
      ),
    ),
  );
}

@_MischiePreview(previewName: '長文の折りたたみ', previewSize: Size(360, 480))
Widget collapsibleContent() {
  return Padding(
    padding: const EdgeInsets.all(16),
    child: CollapsibleContent(child: Text('これは長いノートの例です。\n' * 40)),
  );
}
