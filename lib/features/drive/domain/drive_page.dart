class DrivePage<T> {
  const DrivePage(this.items, {this.nextUntilId});

  final List<T> items;

  final String? nextUntilId;
}

/// 単位はバイト。
class DriveUsage {
  const DriveUsage({required this.usage, required this.capacity});

  final int usage;
  final int capacity;

  double get ratio => capacity <= 0 ? 0 : (usage / capacity).clamp(0.0, 1.0);
}
