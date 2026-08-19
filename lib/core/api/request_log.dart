import 'package:flutter/foundation.dart';

/// API リクエストの記録。
///
/// 「サーバーに無駄な負荷をかけていないか」を推測ではなく実測で見るためのもの。
/// 直近の呼び出しだけを保持し、エンドポイント別の回数と直近 1 分の頻度を出す。
class RequestLog extends ChangeNotifier {
  RequestLog({this.capacity = 500});

  /// 保持する件数。増やしても得るものが少ないので上限を設ける。
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

  /// エンドポイント別の回数（多い順）。
  List<MapEntry<String, int>> countsByPath() {
    final counts = <String, int>{};
    for (final entry in _entries) {
      counts[entry.path] = (counts[entry.path] ?? 0) + 1;
    }
    return counts.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
  }

  /// 直近 [window] の件数。急に増えていないかを見る。
  int recentCount(Duration window) {
    final from = DateTime.now().subtract(window);
    return _entries.where((e) => e.at.isAfter(from)).length;
  }

  void clear() {
    _entries.clear();
    notifyListeners();
  }
}
