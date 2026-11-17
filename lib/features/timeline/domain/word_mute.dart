import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mischie/features/profile/domain/profile_notifier.dart';
import 'package:mischie/features/timeline/domain/note.dart';

/// 配列はその語をすべて含むとき、`/.../flags` の文字列は正規表現として
/// 一致するときに当たる。
class WordMute {
  WordMute(List<dynamic> filters)
    : _keywordSets = [
        for (final filter in filters)
          if (filter is List)
            filter.whereType<String>().where((k) => k.isNotEmpty).toList(),
      ].where((keywords) => keywords.isNotEmpty).toList(),
      _patterns = [
        for (final filter in filters)
          if (filter is String) ?_compile(filter),
      ];

  static final empty = WordMute(const []);

  final List<List<String>> _keywordSets;
  final List<RegExp> _patterns;

  bool get isEmpty => _keywordSets.isEmpty && _patterns.isEmpty;

  /// JavaScript の正規表現リテラルとして読む。
  static RegExp? _compile(String filter) {
    final match = RegExp(r'^/(.+)/(.*)$').firstMatch(filter);
    if (match == null) return null;
    final flags = match.group(2)!;
    try {
      return RegExp(
        match.group(1)!,
        caseSensitive: !flags.contains('i'),
        multiLine: flags.contains('m'),
        dotAll: flags.contains('s'),
        unicode: flags.contains('u'),
      );
    } on FormatException {
      return null;
    }
  }

  bool matches(Note note) {
    if (isEmpty) return false;
    final text = '${note.cw ?? ''}\n${note.text ?? ''}'.trim();
    if (text.isEmpty) return false;
    return _keywordSets.any((keywords) => keywords.every(text.contains)) ||
        _patterns.any((pattern) => pattern.hasMatch(text));
  }
}

final wordMuteProvider = Provider<WordMute>((ref) {
  final me = ref.watch(meProvider).value;
  final filters = me?['mutedWords'];
  return filters is List ? WordMute(filters) : WordMute.empty;
});
