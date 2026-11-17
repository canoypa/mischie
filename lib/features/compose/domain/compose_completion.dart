import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mischie/features/profile/domain/user_detailed.dart';
import 'package:mischie/features/search/domain/search_notifier.dart';

enum CompletionKind { emoji, mention, mfmFunction }

class CompletionQuery {
  const CompletionQuery({
    required this.kind,
    required this.query,
    required this.start,
    required this.end,
  });

  final CompletionKind kind;

  /// 記号を除いた部分。空でも候補は出す。
  final String query;

  /// 置き換える範囲（記号を含む）。
  final int start;
  final int end;
}

/// 補完は入力の邪魔になりやすいので、拾う条件を狭くしている。
CompletionQuery? completionAt(String text, int cursor) {
  if (cursor < 0 || cursor > text.length) return null;

  for (var i = cursor - 1; i >= 0; i--) {
    final char = text[i];

    if (char == ' ' || char == '\n' || char == '\t') return null;

    final kind = switch (char) {
      ':' => CompletionKind.emoji,
      '@' => CompletionKind.mention,
      _ => null,
    };

    // `$[` は 2 文字で 1 つの記号
    if (char == '[' && i > 0 && text[i - 1] == '\$') {
      return _build(text, i - 1, cursor, CompletionKind.mfmFunction, i + 1);
    }

    if (kind == null) {
      if (!_isWordChar(char)) return null;
      continue;
    }

    // 直前が英数字なら単語の途中（メールアドレスや時刻など）
    if (i > 0 && _isWordChar(text[i - 1])) return null;
    return _build(text, i, cursor, kind, i + 1);
  }
  return null;
}

CompletionQuery? _build(
  String text,
  int start,
  int cursor,
  CompletionKind kind,
  int queryStart,
) {
  final query = text.substring(queryStart, cursor);
  // 補完しきったもの（`:name:` など）は対象にしない
  if (query.contains(':') || query.contains(' ')) return null;
  return CompletionQuery(kind: kind, query: query, start: start, end: cursor);
}

bool _isWordChar(String char) => RegExp(r'[0-9A-Za-z_\-]').hasMatch(char);

/// よく使うものだけに絞っている。
const mfmFunctions = [
  'x2',
  'x3',
  'x4',
  'blur',
  'bounce',
  'flip',
  'jelly',
  'jump',
  'rainbow',
  'rotate',
  'shake',
  'sparkle',
  'spin',
  'tada',
  'twitch',
];

/// 呼ぶ側で打鍵を間引いてから渡す。
final mentionSuggestionsProvider = FutureProvider.autoDispose
    .family<List<UserDetailed>, String>((ref, query) async {
      if (query.isEmpty) return const [];
      final repo = ref.watch(searchRepositoryProvider);
      if (repo == null) return const [];
      return repo.searchUsers(query, limit: 10);
    });
