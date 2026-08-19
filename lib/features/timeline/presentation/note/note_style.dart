import 'package:flutter/material.dart';

/// Misskey のチャンネル色は "#86b300" 形式。読めなければ色を付けない。
Color? parseChannelColor(String? value) {
  if (value == null) return null;
  final hex = value.replaceFirst('#', '');
  if (hex.length != 6) return null;
  final parsed = int.tryParse(hex, radix: 16);
  return parsed == null ? null : Color(0xFF000000 | parsed);
}

/// パブリック以外だけアイコンを出す（既定を目立たせない）。
IconData? visibilityIcon(String visibility) => switch (visibility) {
  'home' => Icons.home_outlined,
  'followers' => Icons.lock_outline,
  'specified' => Icons.mail_outline,
  _ => null,
};
