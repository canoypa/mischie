import 'package:mischie/features/timeline/domain/timeline_kind.dart';

class TimelineSource {
  const TimelineSource.builtin(TimelineKind kind)
    : _kind = kind,
      listId = null,
      _listName = null;

  const TimelineSource.list({required String id, required String name})
    : _kind = null,
      listId = id,
      _listName = name;

  final TimelineKind? _kind;
  final String? listId;
  final String? _listName;

  String get label => _kind?.label ?? _listName!;

  String get endpoint => _kind?.endpoint ?? 'notes/user-list-timeline';

  String get streamingChannel => _kind?.streamingChannel ?? 'userList';

  Map<String, dynamic> get params =>
      listId == null ? const {} : {'listId': listId};

  /// 端末に保存される値なので、形式を変えない。
  String get storageKey =>
      listId == null ? 'kind:${_kind!.name}' : 'list:$listId';

  @override
  bool operator ==(Object other) =>
      other is TimelineSource && other._kind == _kind && other.listId == listId;

  @override
  int get hashCode => Object.hash(_kind, listId);
}
