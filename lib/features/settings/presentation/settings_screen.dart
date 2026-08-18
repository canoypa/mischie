import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mischie/core/navigation/link_handler.dart';
import 'package:mischie/features/auth/domain/auth_notifier.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final host = ref.watch(currentHostProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('設定')),
      body: ListView(
        children: [
          if (host != null)
            ListTile(
              leading: const Icon(Icons.dns_outlined),
              title: const Text('サーバー'),
              subtitle: Text(host),
            ),
          // 設定・ドライブ・Play など Mischie が持たない画面は Web に任せる
          ListTile(
            leading: const Icon(Icons.open_in_browser),
            title: const Text('Web クライアントを開く'),
            subtitle: const Text('Mischie にない機能はこちらから'),
            onTap: () => openOnServer(ref, '/'),
          ),
          const Divider(),
          ListTile(
            leading: Icon(
              Icons.logout,
              color: Theme.of(context).colorScheme.error,
            ),
            title: Text(
              'ログアウト',
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

    await ref.read(authNotifierProvider.notifier).logout();
    if (context.mounted) context.go('/login');
  }
}
