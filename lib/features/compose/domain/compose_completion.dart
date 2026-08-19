import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mischie/features/profile/domain/user_detailed.dart';
import 'package:mischie/features/search/domain/search_notifier.dart';

/// 入力中のトークンの種類。
enum CompletionKind {
  /// `:name` — カスタム絵文字
  emoji,

  /// `@name` — メンション
  mention,

  /// `$[fn ` — MFM の装飾
  mfmFunction,
}

/// カーソル位置で補完しようとしているもの。
class CompletionQuery {
  const CompletionQuery({
    required this.kind,
    required this.query,
    required this.start,
    required this.end,
  });

  final CompletionKind kind;

  /// 記号を除いた入力済みの文字。空でも候補は出す。
  final String query;

  /// 置き換える範囲（記号を含む）。
  final int start;
  final int end;
}

/// カーソル直前を見て、補完対象を取り出す。
///
/// 補完は入力の邪魔になりやすいので、拾う条件は狭くする。記号の直前が
/// 単語の途中（英数字）なら拾わない。`http://` の `:` などで候補が出ると
/// うるさいだけなので。
CompletionQuery? completionAt(String text, int cursor) {
  if (cursor < 0 || cursor > text.length) return null;

  for (var i = cursor - 1; i >= 0; i--) {
    final char = text[i];

    // 空白や改行まで戻ったら、そこには記号が無かったということ
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
      // 記号の手前は識別子として妥当な文字だけを許す
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

/// MFM の装飾。よく使うものだけを出す。
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

/// メンション候補の検索。打鍵ごとに投げないよう、呼ぶ側で間引く。
///
/// 絵文字と MFM は手元のデータで済むが、メンションはサーバーに聞くしかない。
/// 1 文字打つたびに検索すると、開発用サーバーにも本番にも無駄な負荷をかける。
final mentionSuggestionsProvider = FutureProvider.autoDispose
    .family<List<UserDetailed>, String>((ref, query) async {
      if (query.isEmpty) return const [];
      final repo = ref.watch(searchRepositoryProvider);
      if (repo == null) return const [];
      return repo.searchUsers(query, limit: 10);
    });
