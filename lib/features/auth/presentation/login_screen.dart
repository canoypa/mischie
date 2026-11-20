import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mischie/core/error/error_handler.dart';
import 'package:mischie/features/auth/data/oauth_service.dart';
import 'package:mischie/features/auth/domain/auth_notifier.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _hostController = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _hostController.dispose();
    super.dispose();
  }

  /// `Misskey.io` や `https://misskey.io/` と入れられても、ホスト名だけにする。
  String? _parseHost(String input) {
    final text = input.trim();
    if (text.isEmpty) return null;
    final uri = Uri.tryParse(text.contains('://') ? text : 'https://$text');
    final host = uri?.host;
    return host == null || host.isEmpty ? null : host;
  }

  Future<void> _login() async {
    if (_loading) return;
    final host = _parseHost(_hostController.text);
    if (host == null) return;

    setState(() => _loading = true);
    try {
      await ref.read(accountsProvider.notifier).add(host);
      // 設定から積んで開いた場合は自分で閉じる。最初のログインでは
      // ルーターがホームへ差し替えるので、その時は何もしない。
      if (mounted && Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
    } on OAuthCancelledException {
      // やめたのは本人なので、何も出さない
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('ログインできませんでした: ${resolveErrorMessage(e)}')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        // 横向きでキーボードを出しても欄とボタンに届くよう、全体をスクロールさせる
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'mischie',
                  style: Theme.of(context).textTheme.headlineLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),
                TextField(
                  controller: _hostController,
                  decoration: const InputDecoration(
                    labelText: 'サーバーのホスト名',
                    hintText: 'misskey.io',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.url,
                  autocorrect: false,
                  onSubmitted: (_) => _login(),
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: _loading ? null : _login,
                  child: _loading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('ログイン'),
                ),
                if (_loading) ...[
                  const SizedBox(height: 16),
                  Text(
                    'ブラウザで許可すると、ここに戻ってきます',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  TextButton(
                    onPressed: () =>
                        ref.read(accountsProvider.notifier).cancelLogin(),
                    child: const Text('キャンセル'),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
