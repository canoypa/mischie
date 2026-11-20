import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mischie/core/navigation/link_handler.dart';
import 'package:mischie/features/auth/domain/auth_notifier.dart';
import 'package:mischie/features/auth/presentation/login_screen.dart';
import 'package:mischie/features/drive/presentation/drive_screen.dart';
import 'package:mischie/core/widgets/decorated_avatar.dart';
import 'package:mischie/features/settings/presentation/request_log_screen.dart';
import 'package:mischie/features/timeline/presentation/favorites_screen.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final host = ref.watch(currentHostProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('設定')),
      body: ListView(
        children: [
          const _AccountsSection(),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.cloud_outlined),
            title: const Text('ドライブ'),
            onTap: () => Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const DriveScreen())),
          ),
          ListTile(
            leading: const Icon(Icons.star_outline),
            title: const Text('お気に入り'),
            onTap: () => Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const FavoritesScreen())),
          ),
          const Divider(),
          for (final (icon, title, path) in const [
            (Icons.manage_accounts_outlined, 'プロフィールを編集', '/settings/profile'),
            (Icons.person_add_alt, 'フォローリクエスト', '/my/follow-requests'),
            (Icons.list_alt, 'リスト', '/my/lists'),
            (Icons.satellite_alt_outlined, 'アンテナ', '/my/antennas'),
            (Icons.attach_file, 'クリップ', '/my/clips'),
            (Icons.block, 'ミュートとブロック', '/settings/mute-block'),
          ])
            ListTile(
              leading: Icon(icon),
              title: Text(title),
              trailing: const Icon(Icons.open_in_new, size: 20),
              onTap: () => openOnServer(ref, path),
            ),
          ListTile(
            leading: const Icon(Icons.open_in_browser),
            title: const Text('Web クライアントを開く'),
            subtitle: const Text('Mischie にない機能はこちらから'),
            onTap: () => openOnServer(ref, '/'),
          ),
          ListTile(
            leading: const Icon(Icons.query_stats),
            title: const Text('通信ログ'),
            subtitle: const Text('サーバーへのリクエストの回数'),
            onTap: () => Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const RequestLogScreen())),
          ),
          const Divider(),
          ListTile(
            leading: Icon(
              Icons.logout,
              color: Theme.of(context).colorScheme.error,
            ),
            title: Text(
              host == null ? 'ログアウト' : '$host からログアウト',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
            onTap: () => _confirmLogout(context, ref),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmLogout(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ログアウト'),
        content: const Text('ログアウトしますか？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('キャンセル'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('ログアウト'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    final active = ref.read(activeAccountProvider);
    if (active != null) {
      await ref.read(accountsProvider.notifier).remove(active.id);
    }
    if (context.mounted && ref.read(activeAccountProvider) == null) {
      context.go('/login');
    }
  }
}

class _AccountsSection extends ConsumerWidget {
  const _AccountsSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accounts = ref.watch(accountsProvider).value;
    final active = accounts?.active;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
          child: Text(
            'アカウント',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
        for (final account in accounts?.accounts ?? const [])
          ListTile(
            leading: DecoratedAvatar(avatarUrl: account.avatarUrl, size: 40),
            title: Text(account.displayName),
            subtitle: Text(account.acct),
            trailing: account.id == active?.id
                ? Icon(
                    Icons.check_circle,
                    color: Theme.of(context).colorScheme.primary,
                  )
                : null,
            onTap: account.id == active?.id
                ? null
                : () =>
                      ref.read(accountsProvider.notifier).switchTo(account.id),
          ),
        ListTile(
          leading: const Icon(Icons.add),
          title: const Text('アカウントを追加'),
          onTap: () => Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => const LoginScreen())),
        ),
      ],
    );
  }
}
