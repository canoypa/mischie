import 'package:flutter_test/flutter_test.dart';
import 'package:mischie/features/timeline/domain/reaction_key.dart';

void main() {
  group('normalizeReactionKey', () {
    test('ホスト無しのカスタム絵文字はローカルホスト表記になる', () {
      expect(normalizeReactionKey(':kawaii:'), ':kawaii@.:');
    });

    test('ローカルホスト表記はそのまま', () {
      expect(normalizeReactionKey(':kawaii@.:'), ':kawaii@.:');
    });

    test('リモートのカスタム絵文字はそのまま', () {
      expect(
        normalizeReactionKey(':kawaii@example.com:'),
        ':kawaii@example.com:',
      );
    });

    test('❤️ (VS16 付き) は VS16 を落とす', () {
      expect(normalizeReactionKey('❤️'), '❤');
    });

    test('ZWJ を含む合成絵文字は VS16 を残す', () {
      const heartOnFire = '❤️‍🔥';
      expect(normalizeReactionKey(heartOnFire), heartOnFire);
    });
  });
}
