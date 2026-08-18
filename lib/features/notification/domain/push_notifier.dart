import 'dart:convert';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mischie/core/providers/core_providers.dart';
import 'package:mischie/core/storage/push_store.dart';
import 'package:mischie/features/notification/data/push_repository.dart';
import 'package:mischie/features/notification/domain/notification_item.dart';
import 'package:unifiedpush/unifiedpush.dart';

final pushStoreProvider = Provider<PushStore>(
  (ref) => PushStore(ref.watch(flutterSecureStorageProvider)),
);

final pushRepositoryProvider = Provider<PushRepository?>((ref) {
  final client = ref.watch(misskeyApiClientProvider).value;
  if (client == null) return null;
  return PushRepository(client);
});

final pushServiceProvider = Provider<PushService>(PushService.new);

/// プッシュ通知の有効・無効。設定画面が読む。
final pushEnabledProvider = AsyncNotifierProvider<PushEnabled, bool>(
  PushEnabled.new,
);

class PushEnabled extends AsyncNotifier<bool> {
  @override
  Future<bool> build() => ref.read(pushStoreProvider).readEnabled();

  Future<void> set({required bool enabled}) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final service = ref.read(pushServiceProvider);
      if (enabled) {
        await service.enable();
      } else {
        await service.disable();
      }
      await ref.read(pushStoreProvider).writeEnabled(enabled: enabled);
      return enabled;
    });
  }
}

/// UnifiedPush 経由の Web Push 購読と、届いた通知の表示。
///
/// Android の標準は FCM だが、Misskey は FCM を話さない。中継サーバーを
/// 建てずに即時通知を得るため、Fediverse クライアントで一般的な
/// UnifiedPush を使う（配信元はユーザーが選んだディストリビュータ）。
class PushService {
  PushService(this._ref);

  final Ref _ref;

  static const _channelId = 'mischie_notifications';
  final _local = FlutterLocalNotificationsPlugin();

  /// 起動時に呼ぶ。受信ハンドラを繋ぐだけで、購読はしない。
  Future<void> initialize() async {
    await _local.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      ),
    );

    await UnifiedPush.initialize(
      onNewEndpoint: (endpoint, _) => _onNewEndpoint(endpoint),
      onMessage: (message, _) => _onMessage(message),
      onUnregistered: (_) => _ref.read(pushStoreProvider).writeEndpoint(null),
    );

    // 既に有効なら、起動のたびに登録し直す（UnifiedPush の作法）
    if (await _ref.read(pushStoreProvider).readEnabled()) {
      await UnifiedPush.register(vapid: await _vapidKey());
    }
  }

  Future<String?> _vapidKey() async {
    try {
      return await _ref.read(pushRepositoryProvider)?.fetchVapidKey();
    } catch (_) {
      return null;
    }
  }

  /// 利用できるディストリビュータ（ntfy など）の一覧。
  Future<List<String>> availableDistributors() => UnifiedPush.getDistributors();

  Future<void> enable({String? distributor}) async {
    if (distributor != null) {
      await UnifiedPush.saveDistributor(distributor);
    } else if (!await UnifiedPush.tryUseCurrentOrDefaultDistributor()) {
      throw Exception('通知を配信するアプリ（ディストリビュータ）が見つかりません');
    }

    await _local
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();

    await UnifiedPush.register(vapid: await _vapidKey());
  }

  Future<void> disable() async {
    final store = _ref.read(pushStoreProvider);
    final endpoint = await store.readEndpoint();
    if (endpoint != null) {
      // サーバー側の購読も消す。残すと配信され続ける。
      try {
        await _ref.read(pushRepositoryProvider)?.unregister(endpoint);
      } catch (_) {
        // 消せなくてもローカルの購読は解除する
      }
    }
    await UnifiedPush.unregister();
    await store.writeEndpoint(null);
  }

  Future<void> _onNewEndpoint(PushEndpoint endpoint) async {
    final keys = endpoint.pubKeySet;
    final repo = _ref.read(pushRepositoryProvider);
    if (keys == null || repo == null) return;

    await repo.register(
      endpoint: endpoint.url,
      auth: keys.auth,
      publicKey: keys.pubKey,
    );
    await _ref.read(pushStoreProvider).writeEndpoint(endpoint.url);
  }

  Future<void> _onMessage(PushMessage message) async {
    if (!message.decrypted) return;

    final Map<String, dynamic> payload;
    try {
      payload =
          jsonDecode(utf8.decode(message.content)) as Map<String, dynamic>;
    } catch (_) {
      return;
    }
    if (payload['type'] != 'notification') return;

    final body = payload['body'];
    if (body is! Map<String, dynamic>) return;

    final item = NotificationItem.fromJson(body);
    await _show(item);
  }

  Future<void> _show(NotificationItem item) async {
    final name = item.user?.name ?? item.user?.username ?? '通知';
    final title = switch (item.type) {
      'reaction' => '$name がリアクション ${item.reaction ?? ''}',
      'reply' => '$name が返信',
      'renote' => '$name がリノート',
      'quote' => '$name が引用',
      'mention' => '$name がメンション',
      'follow' => '$name にフォローされました',
      'followRequestAccepted' => '$name がフォローを承認しました',
      _ => name,
    };

    await _local.show(
      // 同じ通知が二重に出ないよう ID で束ねる
      id: item.id.hashCode,
      title: title,
      body: item.note?.text,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          '通知',
          channelDescription: 'Misskey からの通知',
          importance: Importance.defaultImportance,
        ),
      ),
    );
  }
}
