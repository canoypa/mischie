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

/// 自分のリスト一覧。タブに並べるために使う。
final userListsProvider = FutureProvider<List<UserList>>((ref) async {
  final repo = ref.watch(timelineRepositoryProvider);
  if (repo == null) return const [];
  return repo.fetchLists();
});

/// 表示中のタイムライン。切り替えると再取得とストリーミング再接続が走る。
final selectedTimelineProvider =
    NotifierProvider<SelectedTimeline, TimelineSource>(SelectedTimeline.new);

class SelectedTimeline extends Notifier<TimelineSource> {
  @override
  TimelineSource build() => const TimelineSource.builtin(TimelineKind.home);

  set source(TimelineSource value) => state = value;
}

final timelineNotifierProvider =
    AsyncNotifierProvider<TimelineNotifier, List<Note>>(TimelineNotifier.new);

class TimelineNotifier extends AsyncNotifier<List<Note>> {
  StreamingService? _streaming;

  /// 表示中のノートを個別購読するために使う。接続前は null。
  StreamingService? get streaming => _streaming;

  StreamSubscription<Note>? _subscription;
  StreamSubscription<StreamingEvent>? _updateSubscription;
  StreamSubscription<void>? _reconnectedSubscription;
  final List<Note> _pending = [];

  /// 取得の全量を表す件数。これ以上件数が返ってきたら、取りこぼしの範囲を
  /// 読み切れないとみなして穴を残さず全体を取り直す。
  static const _catchUpLimit = 20;

  /// タイムラインごとの取得済みノート。タブを戻したときに再取得で待たせない
  /// ため、表示は即座にキャッシュから復帰させる（新着はストリーミングで届く）。
  final Map<TimelineSource, List<Note>> _cache = {};

  /// キャッシュがどのサーバーのものか。アカウントを切り替えたら捨てる。
  String? _cachedHost;

  /// ストリーミングで届いた未表示ノート数。UI が listen して使う。
  final pendingCount = ValueNotifier<int>(0);

  /// 直近の flush で差し込んだノートの ID。UI が一度だけ出現アニメーションに
  /// 使い、消費したら取り除く（既に並んでいたノートは動かさない）。
  final Set<String> justInserted = {};

  /// loadMore の多重実行を防ぐ。スクロールの通知は連発するので、UI 側の
  /// フラグだけでは間に入るタブ切り替えなどをすり抜けることがある。
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

    final host = authState is AuthStateAuthenticated ? authState.host : null;
    if (host != _cachedHost) {
      _cache.clear();
      _cachedHost = host;
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
      // このキャッシュはタブが非表示だった間ストリーミングが止まっていた
      // ので、その間の新着を取りこぼしている。
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

  /// アプリ復帰時に呼ぶ。ソケットは背景復帰後サイレントに死んでいることが
  /// あるため、生きているように見えても張り直す。
  void resumeStreaming() => _streaming?.reconnect();

  /// 再接続やタブの再表示で空いた期間に投稿されたノートを取りに行く。
  /// 満杯（穴の可能性あり）なら refresh 相当で全体を取り直し、そうでなけ
  /// れば streamed ノートと同じ pending 経由で先頭に積む。
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
      // ベストエフォート。次の再接続やユーザーの pull-to-refresh で追いつける
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

    // sinceId 順（新しい順）で来る前提。streamed ノートと同じキューに
    // 乗せて、新着チップ / 先頭差し込みの挙動をそのまま使う。
    final stillSelected = source == ref.read(selectedTimelineProvider);
    final latestCache = _cache[source] ?? baseline;
    final knownIds = {
      ...latestCache.map((n) => n.id),
      if (stillSelected) ..._pending.map((n) => n.id),
    };
    final fresh = notes.where((n) => knownIds.add(n.id)).toList();
    if (fresh.isEmpty) return;

    if (stillSelected) {
      // _pending は新しい順。取得を待つ間に再接続後の新着が先頭へ届いて
      // いることがあるので、単純に前後へ足さず投稿日時で並べ直す。
      _pending
        ..addAll(fresh)
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      pendingCount.value = _pending.length;
    } else {
      // 非表示タブはチップを見せる相手がいないので、キャッシュの先頭に
      // 積んでおく。次に選ばれたとき build() がそのまま返す。
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

  /// バッファしたノートをリスト先頭に追加してカウントをリセット。
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

    // タブ切り替えは await の間にも起きるので、書き込み先は最初に読んだ
    // このタブ（source）に固定する。「今選ばれているタブ」を都度読むと、
    // 別タブへ切り替えた後に古いタブのノートがそこへ紛れ込む。
    final source = ref.read(selectedTimelineProvider);
    _loadingMore = true;
    try {
      final older = await repo.fetchTimeline(source, untilId: current.last.id);
      ref.read(noteOverridesProvider.notifier).evictFetched(older);

      // 積む先は取得前のコピー（current）ではなく、このタブの「今の」
      // キャッシュ。await の間に flushPending が届いていると、取得前の
      // コピーに積んでしまってその分が消える。
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
