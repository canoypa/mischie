import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mischie/core/providers/core_providers.dart';
import 'package:mischie/core/streaming/streaming_service.dart';
import 'package:mischie/features/auth/domain/auth_notifier.dart';
import 'package:mischie/features/auth/domain/auth_state.dart';
import 'package:mischie/features/timeline/data/timeline_repository.dart';
import 'package:mischie/features/timeline/domain/note.dart';
import 'package:mischie/features/timeline/domain/note_capture.dart';
import 'package:mischie/features/timeline/domain/note_store.dart';
import 'package:mischie/features/timeline/domain/timeline_kind.dart';
import 'package:mischie/features/timeline/domain/timeline_source.dart';
import 'package:mischie/features/timeline/domain/user_list.dart';

final timelineRepositoryProvider = Provider<TimelineRepository?>((ref) {
  final client = ref.watch(misskeyApiClientProvider);
  if (client == null) return null;
  return TimelineRepository(client);
});

final userListsProvider = FutureProvider<List<UserList>>((ref) async {
  final repo = ref.watch(timelineRepositoryProvider);
  if (repo == null) return const [];
  return repo.fetchLists();
});

final selectedTimelineProvider =
    NotifierProvider<SelectedTimeline, TimelineSource>(SelectedTimeline.new);

class SelectedTimeline extends Notifier<TimelineSource> {
  @override
  TimelineSource build() {
    // リストは別アカウントのものを指しうるので、切り替えたらホームに戻す
    ref.watch(currentAccountIdProvider);
    return const TimelineSource.builtin(TimelineKind.home);
  }

  set source(TimelineSource value) => state = value;
}

final timelineNotifierProvider =
    AsyncNotifierProvider<TimelineNotifier, List<Note>>(TimelineNotifier.new);

class TimelineNotifier extends AsyncNotifier<List<Note>> {
  StreamingService? _streaming;

  StreamingService? get streaming => _streaming;

  StreamSubscription<Note>? _subscription;
  StreamSubscription<StreamingEvent>? _updateSubscription;
  StreamSubscription<void>? _reconnectedSubscription;
  final List<Note> _pending = [];

  static const _catchUpLimit = 20;

  /// タブを戻したときに再取得で待たせないためのキャッシュ。
  final Map<TimelineSource, List<Note>> _cache = {};

  String? _cachedAccountId;

  final pendingCount = ValueNotifier<int>(0);

  /// 出現アニメーション用。UI が読んだら取り除く。
  final Set<String> justInserted = {};

  /// UI 側のフラグはタブ切り替えをまたぐとすり抜けるので、ここでも多重実行を防ぐ。
  bool _loadingMore = false;

  @override
  Future<List<Note>> build() async {
    final authState = ref.watch(authNotifierProvider).value;
    final source = ref.watch(selectedTimelineProvider);

    _subscription?.cancel();
    _updateSubscription?.cancel();
    _reconnectedSubscription?.cancel();
    _streaming?.dispose();
    _streaming = null;
    _pending.clear();
    pendingCount.value = 0;

    final accountId = ref.watch(currentAccountIdProvider);
    if (accountId != _cachedAccountId) {
      _cache.clear();
      _cachedAccountId = accountId;
    }

    if (authState is AuthStateAuthenticated) {
      _startStreaming(authState.host, authState.accessToken, source);
    }

    ref.onDispose(() {
      _subscription?.cancel();
      _updateSubscription?.cancel();
      _reconnectedSubscription?.cancel();
      _streaming?.dispose();
    });

    final cached = _cache[source];
    if (cached != null) {
      // 非表示の間の新着が抜けている。
      unawaited(_catchUp(source));
      return cached;
    }

    final repo = ref.watch(timelineRepositoryProvider);
    if (repo == null) return [];
    final notes = await repo.fetchTimeline(source);
    ref.read(noteOverridesProvider.notifier).evictFetched(notes);
    _cache[source] = notes;
    return notes;
  }

  void _startStreaming(String host, String accessToken, TimelineSource source) {
    _streaming = StreamingService(
      host: host,
      accessToken: accessToken,
      channel: source.streamingChannel,
      params: source.params,
    );
    _streaming!.connect();
    _subscription = _streaming!.noteStream.listen((note) {
      _pending.insert(0, note);
      pendingCount.value = _pending.length;
    });
    _updateSubscription?.cancel();
    _updateSubscription = _streaming!.events.listen((event) {
      if (event.type == 'noteUpdated') {
        applyNoteUpdate(ref, event.body);
      }
    });
    _reconnectedSubscription?.cancel();
    _reconnectedSubscription = _streaming!.reconnected.listen((_) {
      unawaited(_catchUp(source));
    });
  }

  /// アプリ復帰時に呼ぶ。バックグラウンド中に切れた接続は生きて見えるので、
  /// 無条件に張り直す。
  void resumeStreaming() => _streaming?.reconnect();

  Future<void> _catchUp(TimelineSource source) async {
    final repo = ref.read(timelineRepositoryProvider);
    if (repo == null) return;

    final isSelected = source == ref.read(selectedTimelineProvider);
    final baseline = _cache[source] ?? const <Note>[];
    final newestId = isSelected && _pending.isNotEmpty
        ? _pending.first.id
        : (baseline.isNotEmpty ? baseline.first.id : null);
    if (newestId == null) return;

    List<Note> notes;
    try {
      notes = await repo.fetchTimeline(
        source,
        sinceId: newestId,
        limit: _catchUpLimit,
      );
    } catch (_) {
      // 次の再接続か、引っ張って更新で追いつける
      return;
    }
    if (notes.isEmpty) return;
    ref.read(noteOverridesProvider.notifier).evictFetched(notes);

    if (notes.length >= _catchUpLimit) {
      // 取りこぼした範囲を読み切れないので、穴を残さず全体を取り直す。
      final fresh = await _fetchFresh(source);
      if (fresh == null) return;
      _cache[source] = fresh;
      if (ref.read(selectedTimelineProvider) == source) {
        _pending.clear();
        pendingCount.value = 0;
        state = AsyncValue.data(fresh);
      }
      return;
    }

    // 新しい順で届く前提。
    final stillSelected = source == ref.read(selectedTimelineProvider);
    final latestCache = _cache[source] ?? baseline;
    final knownIds = {
      ...latestCache.map((n) => n.id),
      if (stillSelected) ..._pending.map((n) => n.id),
    };
    final fresh = notes.where((n) => knownIds.add(n.id)).toList();
    if (fresh.isEmpty) return;

    if (stillSelected) {
      // 取得を待つ間に新着が先頭へ届いていることがあるので、投稿日時で並べ直す。
      _pending
        ..addAll(fresh)
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      pendingCount.value = _pending.length;
    } else {
      // 非表示タブは新着チップを出せないので、キャッシュへ直接積む。
      _cache[source] = [...fresh, ...latestCache];
    }
  }

  Future<List<Note>?> _fetchFresh(TimelineSource source) async {
    final repo = ref.read(timelineRepositoryProvider);
    if (repo == null) return null;
    try {
      final notes = await repo.fetchTimeline(source);
      ref.read(noteOverridesProvider.notifier).evictFetched(notes);
      return notes;
    } catch (_) {
      return null;
    }
  }

  void flushPending() {
    if (_pending.isEmpty) return;
    final current = state.value ?? [];
    justInserted.addAll(_pending.map((note) => note.id));
    _publish([..._pending, ...current]);
    _pending.clear();
    pendingCount.value = 0;
  }

  Future<void> refresh() async {
    _pending.clear();
    pendingCount.value = 0;
    final source = ref.read(selectedTimelineProvider);
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(timelineRepositoryProvider);
      if (repo == null) return [];
      final notes = await repo.fetchTimeline(source);
      ref.read(noteOverridesProvider.notifier).evictFetched(notes);
      _cache[source] = notes;
      return notes;
    });
  }

  Future<void> loadMore() async {
    if (_loadingMore) return;
    final current = state.value;
    if (current == null || current.isEmpty) return;

    final repo = ref.read(timelineRepositoryProvider);
    if (repo == null) return;

    // await の間にタブが切り替わりうるので、書き込み先は最初に読んだタブに固定する。
    final source = ref.read(selectedTimelineProvider);
    _loadingMore = true;
    try {
      final older = await repo.fetchTimeline(source, untilId: current.last.id);
      ref.read(noteOverridesProvider.notifier).evictFetched(older);

      // await の間の flushPending を消さないよう、取得前のコピーではなく今のキャッシュに積む。
      final latest = _cache[source] ?? current;
      final existingIds = latest.map((note) => note.id).toSet();
      final merged = [
        ...latest,
        ...older.where((note) => !existingIds.contains(note.id)),
      ];
      _cache[source] = merged;
      if (ref.read(selectedTimelineProvider) == source) {
        state = AsyncValue.data(merged);
      }
    } finally {
      _loadingMore = false;
    }
  }

  void _publish(List<Note> notes) {
    _cache[ref.read(selectedTimelineProvider)] = notes;
    state = AsyncValue.data(notes);
  }
}
