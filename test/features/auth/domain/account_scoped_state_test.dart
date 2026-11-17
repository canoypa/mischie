import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mischie/features/auth/domain/auth_notifier.dart';
import 'package:mischie/features/auth/domain/auth_state.dart';
import 'package:mischie/features/channel/domain/channel_notifier.dart';
import 'package:mischie/features/profile/domain/profile_notifier.dart';
import 'package:mischie/features/profile/domain/user_detailed.dart';
import 'package:mischie/features/timeline/data/timeline_repository.dart';
import 'package:mischie/features/timeline/domain/note.dart';
import 'package:mischie/features/timeline/domain/note_store.dart';
import 'package:mischie/features/timeline/domain/timeline_kind.dart';
import 'package:mischie/features/timeline/domain/timeline_notifier.dart';
import 'package:mischie/features/timeline/domain/timeline_source.dart';
import 'package:mischie/features/timeline/domain/user.dart';
import 'package:mischie/features/timeline/domain/user_list.dart';

import '../../../support/account_switch.dart';

Note _note(String id) => Note(
  id: id,
  createdAt: '2026-08-18T00:00:00.000Z',
  user: const User(id: 'user1', username: 'alice'),
);

class _FakeTimelineRepository implements TimelineRepository {
  List<Note> notes = const [];

  @override
  Future<List<Note>> fetchTimeline(
    TimelineSource source, {
    int limit = 20,
    String? untilId,
    String? sinceId,
  }) async => sinceId != null ? const [] : notes;

  @override
  Future<List<UserList>> fetchLists() async => const [];
}

ProviderContainer _container({TimelineRepository? repo}) {
  final container = ProviderContainer(
    overrides: [
      accountSwitchOverride,
      authNotifierProvider.overrideWithValue(
        const AsyncValue.data(AuthState.unauthenticated()),
      ),
      if (repo != null) timelineRepositoryProvider.overrideWithValue(repo),
    ],
  );
  addTearDown(container.dispose);
  return container;
}

void _switchAccount(ProviderContainer container, String id) {
  container.read(testAccountIdProvider.notifier).id = id;
}

void main() {
  group('アカウントを切り替えたとき', () {
    test('操作の上書きは同じサーバーの別アカウントでも空に戻る', () {
      final container = _container();
      container.listen(noteOverridesProvider, (_, _) {});
      container.listen(deletedNoteIdsProvider, (_, _) {});
      container.listen(followOverridesProvider, (_, _) {});
      container.listen(moderationOverridesProvider, (_, _) {});
      container.listen(channelFollowOverridesProvider, (_, _) {});

      container.read(noteOverridesProvider.notifier).put(_note('n1'));
      container.read(deletedNoteIdsProvider.notifier).add('n2');
      container
          .read(followOverridesProvider.notifier)
          .put('u1', FollowState.following);
      container
          .read(moderationOverridesProvider.notifier)
          .setMuted('u1', muted: true);
      container
          .read(channelFollowOverridesProvider.notifier)
          .put('c1', following: true);

      expect(container.read(noteOverridesProvider), isNotEmpty);
      expect(container.read(hiddenUserIdsProvider), {'u1'});

      _switchAccount(container, 'example.test/bob');

      expect(container.read(noteOverridesProvider), isEmpty);
      expect(container.read(deletedNoteIdsProvider), isEmpty);
      expect(container.read(followOverridesProvider), isEmpty);
      expect(container.read(moderationOverridesProvider), isEmpty);
      expect(container.read(hiddenUserIdsProvider), isEmpty);
      expect(container.read(channelFollowOverridesProvider), isEmpty);
    });

    test('アカウントが変わらなければ上書きは残る', () {
      final container = _container();
      container.listen(noteOverridesProvider, (_, _) {});
      container.read(noteOverridesProvider.notifier).put(_note('n1'));

      _switchAccount(container, 'example.test/alice');

      expect(container.read(noteOverridesProvider), isNotEmpty);
    });

    test('表示中のタイムラインはホームに戻る', () {
      final container = _container();
      container.listen(selectedTimelineProvider, (_, _) {});
      container.read(selectedTimelineProvider.notifier).source =
          const TimelineSource.list(id: 'l1', name: 'リスト');

      _switchAccount(container, 'example.test/bob');

      expect(
        container.read(selectedTimelineProvider),
        const TimelineSource.builtin(TimelineKind.home),
      );
    });

    test('同じサーバーの別アカウントにはタイムラインのキャッシュを見せない', () async {
      final repo = _FakeTimelineRepository()..notes = [_note('alice1')];
      final container = _container(repo: repo);
      container.listen(timelineNotifierProvider, (_, _) {});

      final first = await container.read(timelineNotifierProvider.future);
      expect(first.map((n) => n.id), ['alice1']);

      repo.notes = [_note('bob1')];
      _switchAccount(container, 'example.test/bob');

      final second = await container.read(timelineNotifierProvider.future);
      expect(second.map((n) => n.id), ['bob1']);
    });
  });
}
