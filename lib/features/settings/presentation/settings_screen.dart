import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mischie/core/navigation/link_handler.dart';
import 'package:mischie/features/auth/domain/auth_notifier.dart';
import 'package:mischie/features/notification/domain/push_notifier.dart';

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
          const Divider(),
          const _PushTile(),
          const Divider(),
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

/// プッシュ通知の切り替え。
///
/// Android の標準は FCM だが Misskey は FCM を話さないため、配信は
/// UnifiedPush のディストリビュータ（ntfy など）に任せる。どれを使うかは
/// ユーザーの選択なので、ここで選ばせる。
class _PushTile extends ConsumerWidget {
  const _PushTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enabledAsync = ref.watch(pushEnabledProvider);
    final enabled = enabledAsync.value ?? false;

    return Column(
      children: [
        SwitchListTile(
          secondary: const Icon(Icons.notifications_active_outlined),
          title: const Text('プッシュ通知'),
          subtitle: Text(
            enabled ? 'アプリを開いていなくても通知を受け取ります' : '受け取るには配信アプリ（ntfy など）が必要です',
          ),
          value: enabled,
          onChanged: enabledAsync.isLoading
              ? null
              : (value) => _toggle(context, ref, value: value),
        ),
        if (enabledAsync.hasError)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Text(
              '${enabledAsync.error}',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
      ],
    );
  }

  Future<void> _toggle(
    BuildContext context,
    WidgetRef ref, {
    required bool value,
  }) async {
    if (!value) {
      await ref.read(pushEnabledProvider.notifier).set(enabled: false);
      return;
    }

    final distributors = await ref
        .read(pushServiceProvider)
        .availableDistributors();
    if (!context.mounted) return;

    if (distributors.isEmpty) {
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('配信アプリが見つかりません'),
          content: const Text(
            'Misskey は FCM ではなく Web Push を使います。通知を受け取るには '
            'UnifiedPush に対応した配信アプリ（ntfy など）を入れてください。',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('閉じる'),
            ),
          ],
        ),
      );
      return;
    }

    final selected = distributors.length == 1
        ? distributors.first
        : await showDialog<String>(
            context: context,
            builder: (context) => SimpleDialog(
              title: const Text('配信アプリを選ぶ'),
              children: [
                for (final distributor in distributors)
                  SimpleDialogOption(
                    onPressed: () => Navigator.pop(context, distributor),
                    child: Text(distributor),
                  ),
              ],
            ),
          );
    if (selected == null) return;

    await ref.read(pushServiceProvider).enable(distributor: selected);
    await ref.read(pushEnabledProvider.notifier).set(enabled: true);
  }
}
