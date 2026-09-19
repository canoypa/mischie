import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mischie/features/timeline/domain/note.dart';
import 'package:mischie/features/timeline/domain/note_store.dart';
import 'package:mischie/features/timeline/domain/user.dart';

Note _note(String id, {Note? renote}) => Note(
  id: id,
  createdAt: '2026-08-18T00:00:00.000Z',
  user: const User(id: 'user1', username: 'alice'),
  renote: renote,
);

void main() {
  group('NoteOverrides.evictFetched', () {
    test('取得したノートの上書きを外す', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final overrides = container.read(noteOverridesProvider.notifier);

      overrides.put(_note('n1'));
      overrides.put(_note('n2'));

      overrides.evictFetched([_note('n1')]);

      final state = container.read(noteOverridesProvider);
      expect(state.containsKey('n1'), isFalse);
      expect(state.containsKey('n2'), isTrue);
    });

    test('renote 先の上書きも外す', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final overrides = container.read(noteOverridesProvider.notifier);

      overrides.put(_note('renoted'));

      // renoted をリノートした投稿が取得された場合
      overrides.evictFetched([_note('quote', renote: _note('renoted'))]);

      expect(
        container.read(noteOverridesProvider).containsKey('renoted'),
        isFalse,
      );
    });

    test('該当する上書きが無ければ state を作り直さない', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final overrides = container.read(noteOverridesProvider.notifier);
      overrides.put(_note('n1'));

      final before = container.read(noteOverridesProvider);
      overrides.evictFetched([_note('n2')]);
      final after = container.read(noteOverridesProvider);

      expect(identical(before, after), isTrue);
    });

    test('上書きが元々無ければ何もしない', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final overrides = container.read(noteOverridesProvider.notifier);

      final before = container.read(noteOverridesProvider);
      overrides.evictFetched([_note('n1')]);
      final after = container.read(noteOverridesProvider);

      expect(identical(before, after), isTrue);
    });
  });
}
