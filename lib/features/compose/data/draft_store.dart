import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

/// 書きかけのノート。添付はアップロード済みの fileId で保持するので、
/// 下書きから戻したときに上げ直さなくてよい。
class Draft {
  const Draft({
    required this.id,
    required this.text,
    required this.savedAt,
    this.cw,
    this.visibility = 'public',
    this.fileIds = const [],
    this.replyId,
    this.renoteId,
  });

  factory Draft.fromJson(Map<String, dynamic> json) => Draft(
    id: json['id'] as String,
    text: json['text'] as String? ?? '',
    savedAt: json['savedAt'] as String,
    cw: json['cw'] as String?,
    visibility: json['visibility'] as String? ?? 'public',
    fileIds: (json['fileIds'] as List<dynamic>? ?? []).cast<String>(),
    replyId: json['replyId'] as String?,
    renoteId: json['renoteId'] as String?,
  );

  final String id;
  final String text;
  final String savedAt;
  final String? cw;
  final String visibility;
  final List<String> fileIds;
  final String? replyId;
  final String? renoteId;

  Map<String, dynamic> toJson() => {
    'id': id,
    'text': text,
    'savedAt': savedAt,
    'cw': cw,
    'visibility': visibility,
    'fileIds': fileIds,
    'replyId': replyId,
    'renoteId': renoteId,
  };
}

/// 下書きの保存先。サーバーに下書き API は無いので端末内に置く。
class DraftStore {
  const DraftStore();

  static const _fileName = 'drafts.json';

  Future<File> _file() async {
    final dir = await getApplicationSupportDirectory();
    return File('${dir.path}/$_fileName');
  }

  Future<List<Draft>> load() async {
    try {
      final file = await _file();
      if (!await file.exists()) return const [];
      final list = jsonDecode(await file.readAsString()) as List<dynamic>;
      return list.cast<Map<String, dynamic>>().map(Draft.fromJson).toList();
    } catch (_) {
      // 壊れた下書きで投稿画面が開けなくなるほうが困る
      return const [];
    }
  }

  Future<void> _save(List<Draft> drafts) async {
    final file = await _file();
    await file.writeAsString(
      jsonEncode(drafts.map((d) => d.toJson()).toList()),
    );
  }

  Future<List<Draft>> put(Draft draft) async {
    final drafts = [...await load()]
      ..removeWhere((d) => d.id == draft.id)
      ..insert(0, draft);
    await _save(drafts);
    return drafts;
  }

  Future<List<Draft>> remove(String id) async {
    final drafts = [...await load()]..removeWhere((d) => d.id == id);
    await _save(drafts);
    return drafts;
  }
}
