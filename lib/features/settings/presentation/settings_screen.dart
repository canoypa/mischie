import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mischie/core/navigation/link_handler.dart';
import 'package:mischie/features/auth/domain/auth_notifier.dart';
import 'package:mischie/features/auth/presentation/login_screen.dart';
import 'package:mischie/core/widgets/decorated_avatar.dart';
import 'package:mischie/features/notification/domain/push_notifier.dart';
import 'package:mischie/features/settings/presentation/request_log_screen.dart';

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
          ListTile(
            leading: const Icon(Icons.query_stats),
            title: const Text('通信ログ'),
            subtitle: const Text('どのエンドポイントを何回叩いたか'),
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
              // 例外の toString をそのまま出す（表示用の文言を持たせてある）
              '${enabledAsync.error}',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        if (enabled) const _PushDiagnostics(),
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

    // enable は notifier 経由でだけ呼ぶ。直接呼ぶと二重に購読され、
    // 失敗もエラー表示に乗らない。
    await ref
        .read(pushEnabledProvider.notifier)
        .set(enabled: true, distributor: selected);
  }
}

/// 登録済みアカウントの一覧と切り替え。
///
/// 普段使いのサーバーと開発用サーバーを行き来できるようにするためのもの。
/// 切り替えると API クライアントごと差し替わり、取得済みのデータは破棄される。
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

/// 通知が届かないときに、どこで止まっているかを見るための表示。
///
/// 経路は「配信アプリ → 購読先 URL → サーバーへ登録」と長く、どこが
/// 欠けても症状は同じ「来ない」になる。切り分けの手がかりを出しておく。
class _PushDiagnostics extends ConsumerWidget {
  const _PushDiagnostics();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final diagnostics = ref.watch(pushDiagnosticsProvider).value;
    if (diagnostics == null) return const SizedBox.shrink();

    final colorScheme = Theme.of(context).colorScheme;
    final ok = colorScheme.primary;
    final ng = colorScheme.error;

    return Padding(
      padding: const EdgeInsets.fromLTRB(56, 0, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Line(
            label: 'サーバーの対応',
            value: diagnostics.serverSupportsPush ? '対応' : '鍵が未設定',
            color: diagnostics.serverSupportsPush ? ok : ng,
          ),
          _Line(
            label: '配信アプリ',
            value: diagnostics.endpoint == null ? '未接続' : '接続済み',
            color: diagnostics.endpoint == null ? ng : ok,
          ),
        ],
      ),
    );
  }
}

class _Line extends StatelessWidget {
  const _Line({required this.label, required this.value, required this.color});

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(label, style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(width: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: color),
        ),
      ],
    );
  }
}
