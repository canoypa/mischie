import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mischie/core/error/error_handler.dart';
import 'package:mischie/features/compose/domain/compose_notifier.dart';

const _maxLength = 3000;

class ComposeScreen extends ConsumerStatefulWidget {
  const ComposeScreen({super.key});

  @override
  ConsumerState<ComposeScreen> createState() => _ComposeScreenState();
}

class _ComposeScreenState extends ConsumerState<ComposeScreen> {
  final _textController = TextEditingController();
  final _cwController = TextEditingController();
  bool _showCw = false;
  NoteVisibility _visibility = NoteVisibility.public;
  int _textLength = 0;

  @override
  void initState() {
    super.initState();
    _textController.addListener(
      () => setState(() => _textLength = _textController.text.length),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    _cwController.dispose();
    super.dispose();
  }

  Future<void> _post() async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    await ref.read(composeNotifierProvider.notifier).postNote(
      text,
      cw: _showCw ? _cwController.text.trim() : null,
      visibility: _visibility,
    );

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
    final remaining = _maxLength - _textLength;
    final isOverLimit = remaining < 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('ノートを書く'),
        actions: [
          TextButton(
            onPressed: isLoading || isOverLimit ? null : _post,
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
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              children: [
                // CW トグル
                IconButton(
                  icon: Icon(
                    _showCw ? Icons.warning : Icons.warning_outlined,
                    color: _showCw
                        ? Theme.of(context).colorScheme.primary
                        : null,
                  ),
                  tooltip: 'CW (閲覧注意)',
                  onPressed: () => setState(() => _showCw = !_showCw),
                ),
                // 公開範囲
                _VisibilitySelector(
                  value: _visibility,
                  onChanged: (v) => setState(() => _visibility = v),
                ),
                const Spacer(),
                // 文字数カウント
                Text(
                  '$remaining',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: isOverLimit
                        ? Theme.of(context).colorScheme.error
                        : Theme.of(context).colorScheme.outline,
                    fontWeight:
                        isOverLimit ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          if (_showCw)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: TextField(
                controller: _cwController,
                decoration: const InputDecoration(
                  hintText: '閲覧注意の説明',
                  border: UnderlineInputBorder(),
                ),
              ),
            ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _textController,
                autofocus: true,
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                decoration: const InputDecoration(
                  hintText: '今何してる？',
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _VisibilitySelector extends StatelessWidget {
  const _VisibilitySelector({required this.value, required this.onChanged});

  final NoteVisibility value;
  final ValueChanged<NoteVisibility> onChanged;

  IconData _icon(NoteVisibility v) => switch (v) {
        NoteVisibility.public => Icons.public,
        NoteVisibility.home => Icons.home,
        NoteVisibility.followers => Icons.lock,
        NoteVisibility.specified => Icons.mail,
      };

  String _label(NoteVisibility v) => switch (v) {
        NoteVisibility.public => 'パブリック',
        NoteVisibility.home => 'ホーム',
        NoteVisibility.followers => 'フォロワー',
        NoteVisibility.specified => 'ダイレクト',
      };

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<NoteVisibility>(
      initialValue: value,
      onSelected: onChanged,
      itemBuilder: (_) => NoteVisibility.values
          .map(
            (v) => PopupMenuItem(
              value: v,
              child: Row(
                children: [
                  Icon(_icon(v), size: 18),
                  const SizedBox(width: 8),
                  Text(_label(v)),
                ],
              ),
            ),
          )
          .toList(),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_icon(value), size: 20),
          const Icon(Icons.arrow_drop_down, size: 16),
        ],
      ),
    );
  }
}
