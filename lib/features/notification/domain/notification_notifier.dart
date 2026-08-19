import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mischie/core/providers/core_providers.dart';
import 'package:mischie/core/streaming/streaming_service.dart';
import 'package:mischie/features/auth/domain/auth_notifier.dart';
import 'package:mischie/features/auth/domain/auth_state.dart';
import 'package:mischie/features/notification/data/notification_repository.dart';
import 'package:mischie/features/notification/domain/notification_item.dart';

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

  @override
  Future<List<NotificationItem>> build() async {
    final authState = ref.watch(authNotifierProvider).value;

    _subscription?.cancel();
    _streaming?.dispose();
    _streaming = null;

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
        state = AsyncValue.data([item, ...current]);
      }
      unreadCount.value++;
    });
  }

  void markAllRead() => unreadCount.value = 0;

  Future<List<NotificationItem>> _fetch({String? untilId}) async {
    final repo = ref.read(notificationRepositoryProvider);
    if (repo == null) throw Exception('未ログイン');
    return repo.fetchNotifications(untilId: untilId);
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(_fetch);
    markAllRead();
  }

  Future<void> loadMore() async {
    final current = state.value;
    if (current == null || current.isEmpty) return;
    final more = await _fetch(untilId: current.last.id);
    state = AsyncValue.data([...current, ...more]);
  }
}
