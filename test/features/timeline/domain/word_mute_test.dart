import 'package:flutter_test/flutter_test.dart';
import 'package:mischie/features/timeline/domain/note.dart';
import 'package:mischie/features/timeline/domain/user.dart';
import 'package:mischie/features/timeline/domain/word_mute.dart';

Note _note({String? text, String? cw}) => Note(
  id: 'n1',
  createdAt: '2026-10-01T00:00:00.000Z',
  user: const User(id: 'u1', username: 'alice'),
  text: text,
  cw: cw,
);

void main() {
  group('WordMute', () {
    test('配列はすべての語を含むときだけ一致する', () {
      final mute = WordMute([
        ['ネタバレ', '映画'],
      ]);
      expect(mute.matches(_note(text: '映画のネタバレです')), isTrue);
      expect(mute.matches(_note(text: '映画を観た')), isFalse);
    });

    test('正規表現はフラグも含めて読み替える', () {
      final mute = WordMute(['/spoiler/i']);
      expect(mute.matches(_note(text: 'SPOILER alert')), isTrue);
      expect(mute.matches(_note(text: 'nothing here')), isFalse);
    });

    test('CW も判定の対象に含める', () {
      final mute = WordMute([
        ['ネタバレ'],
      ]);
      expect(mute.matches(_note(cw: 'ネタバレ注意', text: '本文')), isTrue);
    });

    test('空の語や読めない正規表現は無視する', () {
      final mute = WordMute([
        [''],
        '/(/',
      ]);
      expect(mute.isEmpty, isTrue);
      expect(mute.matches(_note(text: 'なんでも')), isFalse);
    });
  });
}
