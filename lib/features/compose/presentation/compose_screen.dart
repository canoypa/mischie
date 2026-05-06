import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mischie/core/error/error_handler.dart';
import 'package:mischie/features/compose/domain/compose_notifier.dart';

class ComposeScreen extends ConsumerStatefulWidget {
  const ComposeScreen({super.key});

  @override
  ConsumerState<ComposeScreen> createState() => _ComposeScreenState();
}

class _ComposeScreenState extends ConsumerState<ComposeScreen> {
  final _textController = TextEditingController();

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _post() async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    await ref.read(composeNotifierProvider.notifier).postNote(text);

    if (mounted) {
      final state = ref.read(composeNotifierProvider);
      if (state.hasError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(resolveErrorMessage(state.error!))),
        );
      } else {
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(composeNotifierProvider).isLoading;

    return Scaffold(
      appBar: AppBar(
        title: const Text('ノートを書く'),
        actions: [
          TextButton(
            onPressed: isLoading ? null : _post,
            child: isLoading
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('投稿'),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: TextField(
          controller: _textController,
          autofocus: true,
          maxLines: null,
          decoration: const InputDecoration(
            hintText: '今何してる？',
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }
}
