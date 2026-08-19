import 'package:flutter_test/flutter_test.dart';
import 'package:mischie/features/compose/domain/compose_completion.dart';

CompletionQuery? at(String text) =>
    completionAt(text.replaceAll('|', ''), text.indexOf('|'));

void main() {
  group('completionAt', () {
    test('絵文字を打ちかけている', () {
      final q = at('おはよう :kawa|');
      expect(q?.kind, CompletionKind.emoji);
      expect(q?.query, 'kawa');
    });

    test('記号だけでも候補を出す', () {
      final q = at('おはよう :|');
      expect(q?.kind, CompletionKind.emoji);
      expect(q?.query, '');
    });

    test('メンション', () {
      final q = at('@can|');
      expect(q?.kind, CompletionKind.mention);
      expect(q?.query, 'can');
    });

    test('MFM の装飾', () {
      final q = at(r'$[ji|');
      expect(q?.kind, CompletionKind.mfmFunction);
      expect(q?.query, 'ji');
    });

    test('URL の : では出さない', () {
      // http:// で候補が出るとうるさいだけ
      expect(at('https:|'), isNull);
    });

    test('閉じた絵文字は対象にしない', () {
      expect(at(':kawaii:|'), isNull);
    });

    test('空白をまたいだら拾わない', () {
      expect(at(':kawaii あ|'), isNull);
    });

    test('記号が無ければ何も返さない', () {
      expect(at('ふつうの本文|'), isNull);
    });

    test('置き換える範囲は記号を含む', () {
      final q = at('あ :kawa|');
      expect(q!.start, 2);
      expect(q.end, 7);
    });
  });
}
