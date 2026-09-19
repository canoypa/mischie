import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mischie/core/providers/core_providers.dart';
import 'package:mischie/core/streaming/streaming_service.dart';
import 'package:mischie/features/auth/domain/auth_notifier.dart';
import 'package:mischie/features/auth/domain/auth_state.dart';
import 'package:mischie/features/notification/data/notification_repository.dart';
import 'package:mischie/features/notification/domain/notification_item.dart';
import 'package:mischie/features/notification/domain/notification_merge.dart';
import 'package:mischie/features/timeline/domain/note.dart';
import 'package:mischie/features/timeline/domain/note_store.dart';

final notificationRepositoryProvider = Provider<NotificationRepository?>((ref) {
  final client = ref.watch(misskeyApiClientProvider);
  if (client == null) return null;
  return NotificationRepository(client);
});

final notificationNotifierProvider =
    AsyncNotifierProvider<NotificationNotifier, List<NotificationItem>>(
      NotificationNotifier.new,
    );

class NotificationNotifier extends AsyncNotifier<List<NotificationItem>> {
  StreamingService? _streaming;
  StreamSubscription<StreamingEvent>? _subscription;

  /// 未読の通知数。通知タブを開いたら 0 に戻す。
  final unreadCount = ValueNotifier<int>(0);

  /// loadMore の多重実行を防ぐガード。
  bool _loadingMore = false;

  /// 末尾まで読み終えたか。これが立った後は、スクロールが末尾付近に
  /// 留まる間ずっと同じリクエストを送り続けてしまうのを防ぐ。
  bool _hasMore = true;

  @override
  Future<List<NotificationItem>> build() async {
    final authState = ref.watch(authNotifierProvider).value;

    _subscription?.cancel();
    _streaming?.dispose();
    _streaming = null;
    _hasMore = true;

    if (authState is AuthStateAuthenticated) {
      _startStreaming(authState.host, authState.accessToken);
    }
    ref.onDispose(() {
      _subscription?.cancel();
      _streaming?.dispose();
    });

    return _fetch();
  }

  /// main チャンネルは通知やフォローなど自分宛のイベントが流れる。
  void _startStreaming(String host, String accessToken) {
    _streaming = StreamingService(
      host: host,
      accessToken: accessToken,
      channel: 'main',
    );
    _streaming!.connect();
    _subscription = _streaming!.events.listen((event) {
      if (event.type != 'notification') return;
      final item = NotificationItem.fromJson(event.body);
      final current = state.value;
      if (current != null) {
        state = AsyncValue.data(mergeIncomingNotification(item, current));
      }
      unreadCount.value++;
    });
  }

  void markAllRead() => unreadCount.value = 0;

  Future<List<NotificationItem>> _fetch({String? untilId}) async {
    final repo = ref.read(notificationRepositoryProvider);
    if (repo == null) throw Exception('未ログイン');
    final items = await repo.fetchNotifications(untilId: untilId);
    final notes = items.map((item) => item.note).whereType<Note>();
    ref.read(noteOverridesProvider.notifier).evictFetched(notes);
    return items;
  }

  Future<void> refresh() async {
    _hasMore = true;
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(_fetch);
    markAllRead();
  }

  Future<void> loadMore() async {
    if (_loadingMore || !_hasMore) return;
    final current = state.value;
    if (current == null || current.isEmpty) return;
    _loadingMore = true;
    try {
      final more = await _fetch(untilId: current.last.id);
      if (more.isEmpty) {
        _hasMore = false;
        return;
      }
      state = AsyncValue.data([...current, ...more]);
    } finally {
      _loadingMore = false;
    }
  }
}
