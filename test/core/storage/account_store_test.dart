import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mischie/core/storage/account_store.dart';
import 'package:mischie/features/auth/domain/account.dart';

class _MemoryStorage implements FlutterSecureStorage {
  _MemoryStorage([Map<String, String>? initial]) : _data = {...?initial};

  final Map<String, String> _data;

  @override
  Future<String?> read({
    required String key,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async => _data[key];

  @override
  Future<void> write({
    required String key,
    required String? value,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    if (value == null) {
      _data.remove(key);
    } else {
      _data[key] = value;
    }
  }

  @override
  Future<void> delete({
    required String key,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async => _data.remove(key);

  @override
  Future<void> deleteAll({
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async => _data.clear();

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('AccountStore', () {
    test('保存したアカウントを読み戻せる', () async {
      final store = AccountStore(_MemoryStorage());
      await store.writeAccounts(const [
        Account(
          host: 'misskey.io',
          accessToken: 't1',
          userId: 'u1',
          username: 'alice',
        ),
      ]);
      await store.writeActiveId('misskey.io/u1');

      final accounts = await store.readAccounts();
      expect(accounts, hasLength(1));
      expect(accounts.first.host, 'misskey.io');
      expect(accounts.first.accessToken, 't1');
      expect(await store.readActiveId(), 'misskey.io/u1');
    });

    test('単一アカウント時代の保存を引き継ぐ', () async {
      // ここが壊れると、更新した瞬間に全員がログアウトする
      final storage = _MemoryStorage({
        'server_host': 'example.com',
        'access_token': 'legacy-token',
      });
      final store = AccountStore(storage);

      final accounts = await store.readAccounts();
      expect(accounts, hasLength(1));
      expect(accounts.first.host, 'example.com');
      expect(accounts.first.accessToken, 'legacy-token');
      expect(await store.readActiveId(), accounts.first.id);
    });

    test('移行は一度きりで、古いキーは残さない', () async {
      final storage = _MemoryStorage({
        'server_host': 'example.com',
        'access_token': 'legacy-token',
      });
      final store = AccountStore(storage);
      await store.readAccounts();

      expect(await storage.read(key: 'server_host'), isNull);
      expect(await storage.read(key: 'access_token'), isNull);
      expect(await store.readAccounts(), hasLength(1));
    });

    test('何も保存されていなければ空', () async {
      final store = AccountStore(_MemoryStorage());
      expect(await store.readAccounts(), isEmpty);
      expect(await store.readActiveId(), isNull);
    });

    test('壊れた内容でも落ちない', () async {
      // 読めない値でアプリが起動不能になるほうが困る
      final store = AccountStore(_MemoryStorage({'accounts': 'not json'}));
      expect(await store.readAccounts(), isEmpty);
    });
  });

  group('Account', () {
    test('同じサーバーの別ユーザーは別アカウント', () {
      const a = Account(host: 'misskey.io', accessToken: 't', userId: 'u1');
      const b = Account(host: 'misskey.io', accessToken: 't', userId: 'u2');
      expect(a.id, isNot(b.id));
    });

    test('userId が無ければホストで識別する（移行直後）', () {
      const a = Account(host: 'misskey.io', accessToken: 't');
      expect(a.id, 'misskey.io');
    });
  });
}
