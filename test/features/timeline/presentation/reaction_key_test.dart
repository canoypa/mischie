import 'package:flutter_test/flutter_test.dart';
import 'package:mischie/features/timeline/presentation/note/reactions.dart';

void main() {
  group('isRemoteReaction', () {
    test('Unicode 絵文字はローカル扱い', () {
      expect(isRemoteReaction('👍'), isFalse);
    });

    test('ホスト無しのカスタム絵文字はローカル', () {
      expect(isRemoteReaction('kawaii'), isFalse);
    });

    test('`@.` はローカルホストを指す', () {
      // 取り違えるとローカルの絵文字にリアクションできなくなる
      expect(isRemoteReaction('kawaii2@.'), isFalse);
    });

    test('実在のホストが付いていればリモート', () {
      expect(isRemoteReaction('kawaii@misskey.io'), isTrue);
    });
  });
}
