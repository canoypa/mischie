import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mischie/features/auth/domain/auth_notifier.dart';
import 'package:mischie/features/auth/domain/auth_state.dart';
import 'package:mischie/features/timeline/data/timeline_repository.dart';
import 'package:mischie/features/timeline/domain/note.dart';
import 'package:mischie/features/timeline/domain/timeline_kind.dart';
import 'package:mischie/features/timeline/domain/timeline_notifier.dart';
import 'package:mischie/features/timeline/domain/timeline_source.dart';
import 'package:mischie/features/timeline/domain/user.dart';
import 'package:mischie/features/timeline/domain/user_list.dart';

Note _note(String id) => Note(
  id: id,
  createdAt: '2026-08-18T00:00:00.000Z',
  user: const User(id: 'user1', username: 'alice'),
);

/// 追加読み込みは completeLoadMore を呼ぶまで返らない。
class _FakeTimelineRepository implements TimelineRepository {
  final Map<String, List<Note>> _initial;
  final Map<String, Completer<List<Note>>> _loadMoreCompleters = {};

  final Map<String, List<Note>> _catchUpResponses = {};

  _FakeTimelineRepository(this._initial);

  void setInitial(TimelineSource source, List<Note> notes) {
    _initial[source.storageKey] = notes;
  }

  void setCatchUp(TimelineSource source, List<Note> notes) {
    _catchUpResponses[source.storageKey] = notes;
  }

  @override
  Future<List<Note>> fetchTimeline(
    TimelineSource source, {
    int limit = 20,
    String? untilId,
    String? sinceId,
  }) async {
    if (sinceId != null) {
      return _catchUpResponses[source.storageKey] ?? const [];
    }
    if (untilId == null) {
      return _initial[source.storageKey] ?? const [];
    }
    final completer = Completer<List<Note>>();
    _loadMoreCompleters[source.storageKey] = completer;
    return completer.future;
  }

  @override
  Future<List<UserList>> fetchLists() async => const [];

  void completeLoadMore(TimelineSource source, List<Note> notes) {
    _loadMoreCompleters[source.storageKey]!.complete(notes);
  }
}

ProviderContainer _container(_FakeTimelineRepository repo) {
  final container = ProviderContainer(
    overrides: [
      authNotifierProvider.overrideWithValue(
        const AsyncValue.data(AuthState.unauthenticated()),
      ),
      timelineRepositoryProvider.overrideWithValue(repo),
    ],
  );
  addTearDown(container.dispose);
  return container;
}

void main() {
  const home = TimelineSource.builtin(TimelineKind.home);
  const local = TimelineSource.builtin(TimelineKind.local);

  group('TimelineNotifier.loadMore', () {
    test('取得中にタブを切り替えても、古いタブの結果は新しいタブに漏れない', () async {
      final repo = _FakeTimelineRepository({
        home.storageKey: [_note('h1'), _note('h2')],
        local.storageKey: [_note('l1'), _note('l2')],
      });
      final container = _container(repo);

      await container.read(timelineNotifierProvider.future);
      final notifier = container.read(timelineNotifierProvider.notifier);

      final loadMoreFuture = notifier.loadMore();

      container.read(selectedTimelineProvider.notifier).source = local;
      await container.read(timelineNotifierProvider.future);

      repo.completeLoadMore(home, [_note('h3')]);
      await loadMoreFuture;

      expect(container.read(timelineNotifierProvider).value!.map((n) => n.id), [
        'l1',
        'l2',
      ]);

      container.read(selectedTimelineProvider.notifier).source = home;
      final backToHome = await container.read(timelineNotifierProvider.future);
      expect(backToHome.map((n) => n.id), ['h1', 'h2', 'h3']);
    });

    test('取得中に別の更新でキャッシュが変わっても、それを起点にマージし重複IDは捨てる', () async {
      final repo = _FakeTimelineRepository({
        home.storageKey: [_note('n1')],
      });
      final container = _container(repo);

      await container.read(timelineNotifierProvider.future);
      final notifier = container.read(timelineNotifierProvider.notifier);

      final loadMoreFuture = notifier.loadMore();

      repo.setInitial(home, [_note('n2'), _note('n1')]);
      await notifier.refresh();

      repo.completeLoadMore(home, [_note('n1'), _note('n0')]);
      await loadMoreFuture;

      expect(container.read(timelineNotifierProvider).value!.map((n) => n.id), [
        'n2',
        'n1',
        'n0',
      ]);
    });
  });

  group('TimelineNotifier のキャッチアップ（タブを戻したとき）', () {
    test('フルページ未満なら、新着として先頭に積む', () async {
      final repo = _FakeTimelineRepository({
        home.storageKey: [_note('h2'), _note('h1')],
        local.storageKey: [_note('l1')],
      });
      final container = _container(repo);

      await container.read(timelineNotifierProvider.future);
      final notifier = container.read(timelineNotifierProvider.notifier);

      container.read(selectedTimelineProvider.notifier).source = local;
      await container.read(timelineNotifierProvider.future);

      repo.setCatchUp(home, [_note('h3')]);
      container.read(selectedTimelineProvider.notifier).source = home;
      final backToHome = await container.read(timelineNotifierProvider.future);

      // 新着はキャッチアップで後から届く
      expect(backToHome.map((n) => n.id), ['h2', 'h1']);

      await Future<void>.delayed(Duration.zero);

      expect(notifier.pendingCount.value, 1);
      notifier.flushPending();
      expect(container.read(timelineNotifierProvider).value!.map((n) => n.id), [
        'h3',
        'h2',
        'h1',
      ]);
    });

    test('フルページ分返ってきたら穴を残さず全体を取り直す', () async {
      final repo = _FakeTimelineRepository({
        home.storageKey: [_note('h1')],
        local.storageKey: [_note('l1')],
      });
      final container = _container(repo);

      await container.read(timelineNotifierProvider.future);

      container.read(selectedTimelineProvider.notifier).source = local;
      await container.read(timelineNotifierProvider.future);

      repo.setCatchUp(home, List.generate(20, (i) => _note('c$i')));
      repo.setInitial(home, [_note('fresh2'), _note('fresh1')]);

      container.read(selectedTimelineProvider.notifier).source = home;
      await container.read(timelineNotifierProvider.future);

      // キャッチアップ → 取り直しの 2 段の非同期を待つ
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);

      expect(container.read(timelineNotifierProvider).value!.map((n) => n.id), [
        'fresh2',
        'fresh1',
      ]);
    });
  });
}
