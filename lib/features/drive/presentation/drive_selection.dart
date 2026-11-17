import 'package:flutter/foundation.dart';
import 'package:mischie/features/timeline/domain/drive_file.dart';

/// フォルダを行き来しても選択が消えないよう、入れ子の画面で 1 つを共有する。
class DriveSelection extends ChangeNotifier {
  DriveSelection({required this.max});

  final int max;
  final List<DriveFile> _files = [];

  List<DriveFile> get files => List.unmodifiable(_files);

  int get count => _files.length;

  bool get isFull => _files.length >= max;

  bool contains(DriveFile file) => _files.any((f) => f.id == file.id);

  /// 上限に達していて増やせなかったときは false。
  bool toggle(DriveFile file) {
    final index = _files.indexWhere((f) => f.id == file.id);
    if (index >= 0) {
      _files.removeAt(index);
    } else if (isFull) {
      return false;
    } else {
      _files.add(file);
    }
    notifyListeners();
    return true;
  }
}
