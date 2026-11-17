import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

/// 秘密でない設定値の置き場。
///
/// トークンはここに置かない。
class PrefsStore {
  const PrefsStore();

  static const _fileName = 'prefs.json';

  Future<File> _file() async {
    final dir = await getApplicationSupportDirectory();
    return File('${dir.path}/$_fileName');
  }

  Future<Map<String, dynamic>> _read() async {
    try {
      final file = await _file();
      if (!await file.exists()) return {};
      return jsonDecode(await file.readAsString()) as Map<String, dynamic>;
    } catch (_) {
      // 壊れた設定でアプリが立ち上がらなくなるほうが困る
      return {};
    }
  }

  Future<T?> read<T>(String key) async => (await _read())[key] as T?;

  Future<void> write(String key, Object? value) async {
    final data = await _read();
    if (value == null) {
      data.remove(key);
    } else {
      data[key] = value;
    }
    try {
      await (await _file()).writeAsString(jsonEncode(data));
    } catch (_) {
      // 保存できなくても動作は続ける
    }
  }
}
