import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const _keyAccessToken = 'access_token';
const _keyServerHost = 'server_host';

class TokenStorage {
  const TokenStorage(this._storage);

  final FlutterSecureStorage _storage;

  Future<String?> readAccessToken() {
    return _storage.read(key: _keyAccessToken);
  }

  Future<void> writeAccessToken(String token) {
    return _storage.write(key: _keyAccessToken, value: token);
  }

  Future<String?> readServerHost() {
    return _storage.read(key: _keyServerHost);
  }

  Future<void> writeServerHost(String host) {
    return _storage.write(key: _keyServerHost, value: host);
  }

  Future<void> clear() {
    return _storage.deleteAll();
  }
}
