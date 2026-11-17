import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mischie/core/api/misskey_api_client.dart';
import 'package:mischie/core/providers/core_providers.dart';
import 'package:mischie/features/auth/data/oauth_service.dart';
import 'package:mischie/features/auth/domain/account.dart';
import 'package:mischie/features/auth/domain/auth_state.dart';

final oauthServiceProvider = Provider<OAuthService>((ref) => OAuthService());

final accountsProvider = AsyncNotifierProvider<AccountsNotifier, AccountsState>(
  AccountsNotifier.new,
);

class AccountsState {
  const AccountsState({required this.accounts, this.activeId});

  final List<Account> accounts;
  final String? activeId;

  Account? get active {
    if (accounts.isEmpty) return null;
    for (final account in accounts) {
      if (account.id == activeId) return account;
    }
    return accounts.first;
  }
}

class AccountsNotifier extends AsyncNotifier<AccountsState> {
  @override
  Future<AccountsState> build() async {
    final store = ref.watch(accountStoreProvider);
    final accounts = await store.readAccounts();
    return AccountsState(
      accounts: accounts,
      activeId: await store.readActiveId(),
    );
  }

  /// 新しいサーバーにログインして追加する。同じアカウントなら差し替える。
  Future<void> add(String host) async {
    final oauth = ref.read(oauthServiceProvider);
    final result = await oauth.login(host);

    // 表示名とアイコンを持たせておくと、切り替え画面で見分けが付く
    final account = await _withProfile(
      Account(host: result.host, accessToken: result.accessToken),
    );

    final current = state.value?.accounts ?? const <Account>[];
    final accounts = [
      ...current.where(
        (a) =>
            a.id != account.id &&
            // ユーザーの分からない旧形式のログインは、同じサーバーに
            // ログインし直したら置き換える（残すと同じアカウントが並ぶ）
            !(a.userId == null && a.host == account.host),
      ),
      account,
    ];
    await _persist(accounts, activeId: account.id);
  }

  void cancelLogin() => ref.read(oauthServiceProvider).cancel();

  Future<Account> _withProfile(Account account) async {
    try {
      final client = MisskeyApiClient(
        host: account.host,
        getToken: () async => account.accessToken,
      );
      final me = await client.post('i');
      return account.copyWith(
        userId: me['id'] as String?,
        username: me['username'] as String?,
        name: me['name'] as String?,
        avatarUrl: me['avatarUrl'] as String?,
      );
    } catch (_) {
      // 取れなくてもログイン自体は成立する
      return account;
    }
  }

  Future<void> switchTo(String accountId) async {
    final accounts = state.value?.accounts ?? const <Account>[];
    if (!accounts.any((a) => a.id == accountId)) return;
    await _persist(accounts, activeId: accountId);
  }

  /// 指定したアカウントだけを外す。残りがあればそのまま使い続ける。
  Future<void> remove(String accountId) async {
    final current = state.value;
    if (current == null) return;
    final accounts = current.accounts.where((a) => a.id != accountId).toList();
    final activeId = current.activeId == accountId
        ? (accounts.isEmpty ? null : accounts.first.id)
        : current.activeId;
    await _persist(accounts, activeId: activeId);
  }

  Future<void> _persist(List<Account> accounts, {String? activeId}) async {
    final store = ref.read(accountStoreProvider);
    await store.writeAccounts(accounts);
    await store.writeActiveId(activeId);
    state = AsyncValue.data(
      AccountsState(accounts: accounts, activeId: activeId),
    );
  }
}

/// アカウントに依存する値の入り口は、ここと [misskeyApiClientProvider] に絞る。
final authNotifierProvider = Provider<AsyncValue<AuthState>>((ref) {
  return ref.watch(accountsProvider).whenData((state) {
    final active = state.active;
    return active == null
        ? const AuthState.unauthenticated()
        : AuthState.authenticated(
            host: active.host,
            accessToken: active.accessToken,
          );
  });
});

final currentHostProvider = Provider<String?>((ref) {
  final state = ref.watch(authNotifierProvider).value;
  return state is AuthStateAuthenticated ? state.host : null;
});

final activeAccountProvider = Provider<Account?>((ref) {
  return ref.watch(accountsProvider).value?.active;
});

/// いま使っているアカウントの識別子（[Account.id]）。
///
/// 同じサーバーの別アカウントも区別できる。アカウントに紐づくローカルの
/// 状態は、これを watch して切り替えのたびに捨てる。
final currentAccountIdProvider = Provider<String?>((ref) {
  return ref.watch(activeAccountProvider.select((account) => account?.id));
});
