import 'package:material_ui/material_ui.dart';

/// blurhash の先頭にある平均色を取り出す。画像の読み込みを待たずに色が分かる。
Color? averageColorOfBlurhash(String? hash) {
  if (hash == null || hash.length < 6) return null;
  final dc = _decode83(hash.substring(2, 6));
  if (dc == null) return null;
  return Color.fromARGB(255, dc >> 16, (dc >> 8) & 0xFF, dc & 0xFF);
}

const _alphabet =
    r'0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz#$%*+,-.:;=?@[]^_{|}~';

int? _decode83(String value) {
  var result = 0;
  for (final char in value.split('')) {
    final index = _alphabet.indexOf(char);
    if (index < 0) return null;
    result = result * 83 + index;
  }
  return result;
}
