import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// プッシュ通知の設定。端末に紐づくのでアカウントのトークンとは別に持つ。
class PushStore {
  const PushStore(this._storage);

  final FlutterSecureStorage _storage;

  static const _enabledKey = 'push_enabled';
  static const _endpointKey = 'push_endpoint';

  Future<bool> readEnabled() async =>
      await _storage.read(key: _enabledKey) == 'true';

  Future<void> writeEnabled({required bool enabled}) =>
      _storage.write(key: _enabledKey, value: enabled ? 'true' : 'false');

  Future<String?> readEndpoint() => _storage.read(key: _endpointKey);

  Future<void> writeEndpoint(String? endpoint) => endpoint == null
      ? _storage.delete(key: _endpointKey)
      : _storage.write(key: _endpointKey, value: endpoint);
}
