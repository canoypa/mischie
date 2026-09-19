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

/// 初回取得（untilId 無し）は即座に返し、追加読み込み（untilId 付き）だけ
/// テストから明示的に完了させられるようにする。タブ切り替えや別の更新が
/// await の間に起きる状況を、実際のストリーミングを繋がずに再現するため。
class _FakeTimelineRepository implements TimelineRepository {
  final Map<String, List<Note>> _initial;
  final Map<String, Completer<List<Note>>> _loadMoreCompleters = {};

  _FakeTimelineRepository(this._initial);

  void setInitial(TimelineSource source, List<Note> notes) {
    _initial[source.storageKey] = notes;
  }

  @override
  Future<List<Note>> fetchTimeline(
    TimelineSource source, {
    int limit = 20,
    String? untilId,
  }) async {
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

      // home の追加読み込みを始めるが、まだ完了させない
      final loadMoreFuture = notifier.loadMore();

      // その間に local タブへ切り替える
      container.read(selectedTimelineProvider.notifier).source = local;
      await container.read(timelineNotifierProvider.future);

      // home の追加読み込みが今になって完了する
      repo.completeLoadMore(home, [_note('h3')]);
      await loadMoreFuture;

      // 表示中（local）は home の結果で汚れていない
      expect(container.read(timelineNotifierProvider).value!.map((n) => n.id), [
        'l1',
        'l2',
      ]);

      // home のキャッシュ側には正しく追記されている
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

      // n1 を最後として追加読み込みを開始（まだ完了させない）
      final loadMoreFuture = notifier.loadMore();

      // 追加読み込みの最中に、新着を反映した更新が別経路で先頭に来たとする
      repo.setInitial(home, [_note('n2'), _note('n1')]);
      await notifier.refresh();

      // 追加読み込みが完了する。応答には既存の n1 が重複して含まれることもある
      repo.completeLoadMore(home, [_note('n1'), _note('n0')]);
      await loadMoreFuture;

      // 取得前のコピー（[n1] だけ）を起点にせず、refresh 後の最新
      // （[n2, n1]）に積む。重複した n1 は 1 つだけ残る。
      expect(container.read(timelineNotifierProvider).value!.map((n) => n.id), [
        'n2',
        'n1',
        'n0',
      ]);
    });
  });
}
