import 'dart:convert';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mischie/core/providers/core_providers.dart';
import 'package:mischie/core/storage/push_store.dart';
import 'package:mischie/features/notification/data/push_repository.dart';
import 'package:mischie/features/notification/domain/notification_item.dart';
import 'package:mischie/features/notification/domain/notification_label.dart';
import 'package:unifiedpush/unifiedpush.dart';

final pushStoreProvider = Provider<PushStore>(
  (ref) => PushStore(ref.watch(flutterSecureStorageProvider)),
);

final pushRepositoryProvider = Provider<PushRepository?>((ref) {
  final client = ref.watch(misskeyApiClientProvider);
  if (client == null) return null;
  return PushRepository(client);
});

final pushServiceProvider = Provider<PushService>(PushService.new);

/// サーバーが Web Push の鍵を設定していない。クライアント側では直せない。
class PushUnsupportedException implements Exception {
  const PushUnsupportedException();

  @override
  String toString() => 'このサーバーはプッシュ通知に対応していません（管理者が ServiceWorker の鍵を設定していません）';
}

/// 通知を配達するアプリ（UnifiedPush ディストリビュータ）が端末にない。
class PushDistributorMissingException implements Exception {
  const PushDistributorMissingException();

  @override
  String toString() => '通知を配達するアプリ（ntfy など）が見つかりません';
}

/// プッシュ通知の有効・無効。設定画面が読む。
final pushEnabledProvider = AsyncNotifierProvider<PushEnabled, bool>(
  PushEnabled.new,
);

/// プッシュ購読の状態。届かないときにどこで止まっているかを見るために使う。
///
/// 経路は「配信アプリ → 購読先 URL → サーバーへ登録」と長く、どこが
/// 欠けても症状は同じ「通知が来ない」になる。切り分けられるようにしておく。
final pushDiagnosticsProvider = FutureProvider<PushDiagnostics>((ref) async {
  // 有効・無効の切り替えに追従させる
  ref.watch(pushEnabledProvider);
  final endpoint = await ref.read(pushStoreProvider).readEndpoint();
  final vapid = await ref.read(pushRepositoryProvider)?.fetchVapidKey();
  return PushDiagnostics(endpoint: endpoint, serverSupportsPush: vapid != null);
});

class PushDiagnostics {
  const PushDiagnostics({
    required this.endpoint,
    required this.serverSupportsPush,
  });

  /// 配信アプリから受け取った購読先。null なら配信アプリまで届いていない。
  final String? endpoint;

  /// サーバーが Web Push の鍵を持っているか。無ければ何をしても届かない。
  final bool serverSupportsPush;
}

class PushEnabled extends AsyncNotifier<bool> {
  @override
  Future<bool> build() => ref.read(pushStoreProvider).readEnabled();

  Future<void> set({required bool enabled, String? distributor}) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final service = ref.read(pushServiceProvider);
      if (enabled) {
        await service.enable(distributor: distributor);
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
      final vapid = await _vapidKey();
      if (vapid != null) await UnifiedPush.register(vapid: vapid);
    }
  }

  /// サーバーの VAPID 公開鍵。
  ///
  /// Misskey の Web Push はサーバー側で鍵ペアを設定していないと動かない。
  /// 公開インスタンスは自前の Web クライアントの通知がこれに依存するため
  /// 大抵は設定済みだが、設定していないサーバーもある。
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
    // 鍵が無いサーバーでは購読しても何も届かない。黙って有効にすると
    // 「設定したのに通知が来ない」という壊れ方をするので、先に弾く。
    final vapid = await _vapidKey();
    if (vapid == null) {
      throw const PushUnsupportedException();
    }

    if (distributor != null) {
      await UnifiedPush.saveDistributor(distributor);
    } else if (!await UnifiedPush.tryUseCurrentOrDefaultDistributor()) {
      throw const PushDistributorMissingException();
    }

    await _local
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();

    await UnifiedPush.register(vapid: vapid);
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
    await _local.show(
      // 同じ通知が二重に出ないよう ID で束ねる
      id: item.id.hashCode,
      title: notificationSummary(item),
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
