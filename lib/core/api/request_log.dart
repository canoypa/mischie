import 'package:flutter/foundation.dart';

/// サーバーに無駄な負荷をかけていないかを確かめるための、API 呼び出しの記録。
class RequestLog extends ChangeNotifier {
  RequestLog({this.capacity = 500});

  final int capacity;

  final List<({String path, DateTime at})> _entries = [];

  List<({String path, DateTime at})> get entries => List.unmodifiable(_entries);

  DateTime? get since => _entries.isEmpty ? null : _entries.first.at;

  int get total => _entries.length;

  void record(String path) {
    _entries.add((path: path, at: DateTime.now()));
    if (_entries.length > capacity) _entries.removeAt(0);
    notifyListeners();
  }

  List<MapEntry<String, int>> countsByPath() {
    final counts = <String, int>{};
    for (final entry in _entries) {
      counts[entry.path] = (counts[entry.path] ?? 0) + 1;
    }
    return counts.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
  }

  int recentCount(Duration window) {
    final from = DateTime.now().subtract(window);
    return _entries.where((e) => e.at.isAfter(from)).length;
  }

  void clear() {
    _entries.clear();
    notifyListeners();
  }
}
