import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

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
    this.channelId,
    this.channelName,
    this.pollChoices,
    this.pollMultiple = false,
    this.pollExpiresInMs,
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
    channelId: json['channelId'] as String?,
    channelName: json['channelName'] as String?,
    pollChoices: (json['pollChoices'] as List<dynamic>?)?.cast<String>(),
    pollMultiple: json['pollMultiple'] as bool? ?? false,
    pollExpiresInMs: json['pollExpiresInMs'] as int?,
  );

  final String id;
  final String text;
  final String savedAt;
  final String? cw;
  final String visibility;
  final List<String> fileIds;
  final String? replyId;
  final String? renoteId;

  /// 名前は再開した画面にすぐ出すために持つ。
  final String? channelId;
  final String? channelName;

  /// 未入力の欄も含めて持つ。null なら投票なし。
  final List<String>? pollChoices;
  final bool pollMultiple;
  final int? pollExpiresInMs;

  Map<String, dynamic> toJson() => {
    'id': id,
    'text': text,
    'savedAt': savedAt,
    'cw': cw,
    'visibility': visibility,
    'fileIds': fileIds,
    'replyId': replyId,
    'renoteId': renoteId,
    'channelId': channelId,
    'channelName': channelName,
    'pollChoices': pollChoices,
    'pollMultiple': pollMultiple,
    'pollExpiresInMs': pollExpiresInMs,
  };
}

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
