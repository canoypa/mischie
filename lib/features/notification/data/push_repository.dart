import 'package:mischie/core/api/misskey_api_client.dart';

/// Misskey の Web Push 購読登録。
///
/// Misskey は FCM ではなく Web Push (VAPID) しか話さないため、UnifiedPush の
/// ディストリビュータから受け取ったエンドポイントをそのまま登録する。
class PushRepository {
  const PushRepository(this._client);

  final MisskeyApiClient _client;

  Future<void> register({
    required String endpoint,
    required String auth,
    required String publicKey,
  }) => _client.postVoid(
    'sw/register',
    body: {'endpoint': endpoint, 'auth': auth, 'publickey': publicKey},
  );

  Future<void> unregister(String endpoint) =>
      _client.postVoid('sw/unregister', body: {'endpoint': endpoint});

  /// サーバーの VAPID 公開鍵。未設定のサーバーでは null が返り、その場合
  /// サーバーは push を送らない（管理画面の ServiceWorker 設定が必要）。
  Future<String?> fetchVapidKey() async {
    final meta = await _client.post('meta');
    return meta['swPublickey'] as String?;
  }
}
