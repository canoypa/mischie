import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mischie/features/auth/domain/account.dart';

/// トークンを含むので暗号化ストレージに置く。
class AccountStore {
  const AccountStore(this._storage);

  final FlutterSecureStorage _storage;

  static const _keyAccounts = 'accounts';
  static const _keyActiveId = 'active_account_id';

  // 旧形式のキー。読み出し時に移行する。
  static const _legacyToken = 'access_token';
  static const _legacyHost = 'server_host';

  Future<List<Account>> readAccounts() async {
    final raw = await _storage.read(key: _keyAccounts);
    if (raw == null) return _migrateLegacy();
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list.cast<Map<String, dynamic>>().map(Account.fromJson).toList();
    } catch (_) {
      return const [];
    }
  }

  /// 単一アカウントで保存されていたログインを引き継ぐ。
  /// ここで移行しないと、更新した瞬間にログアウトさせることになる。
  Future<List<Account>> _migrateLegacy() async {
    final host = await _storage.read(key: _legacyHost);
    final token = await _storage.read(key: _legacyToken);
    if (host == null || token == null) return const [];

    final accounts = [Account(host: host, accessToken: token)];
    await writeAccounts(accounts);
    await writeActiveId(accounts.first.id);
    await _storage.delete(key: _legacyHost);
    await _storage.delete(key: _legacyToken);
    return accounts;
  }

  Future<void> writeAccounts(List<Account> accounts) => _storage.write(
    key: _keyAccounts,
    value: jsonEncode(accounts.map((a) => a.toJson()).toList()),
  );

  Future<String?> readActiveId() => _storage.read(key: _keyActiveId);

  Future<void> writeActiveId(String? id) => id == null
      ? _storage.delete(key: _keyActiveId)
      : _storage.write(key: _keyActiveId, value: id);

  Future<void> clear() => _storage.deleteAll();
}
