import 'package:material_ui/material_ui.dart';

/// 選択肢は 2 つ以上必要なので、最初から 2 つ用意する。
class PollDraft {
  PollDraft()
    : controllers = [TextEditingController(), TextEditingController()];

  final List<TextEditingController> controllers;
  bool multiple = false;

  /// null は無期限。
  Duration? duration;

  static const maxChoices = 10;

  List<String> get choices => controllers
      .map((c) => c.text.trim())
      .where((text) => text.isNotEmpty)
      .toList();

  bool get isValid => choices.length >= 2;

  void addChoice() {
    if (controllers.length >= maxChoices) return;
    controllers.add(TextEditingController());
  }

  void removeChoice(int index) {
    if (controllers.length <= 2) return;
    controllers.removeAt(index).dispose();
  }

  void dispose() {
    for (final controller in controllers) {
      controller.dispose();
    }
  }
}

class PollEditor extends StatelessWidget {
  const PollEditor({
    super.key,
    required this.draft,
    required this.onChanged,
    required this.onRemove,
  });

  final PollDraft draft;

  final VoidCallback onChanged;
  final VoidCallback onRemove;

  static const _durations = <String, Duration?>{
    '無期限': null,
    '1 時間': Duration(hours: 1),
    '1 日': Duration(days: 1),
    '1 週間': Duration(days: 7),
  };

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.poll_outlined, size: 18, color: colorScheme.primary),
              const SizedBox(width: 8),
              Text('投票', style: Theme.of(context).textTheme.titleSmall),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.close),
                tooltip: '投票をやめる',
                onPressed: onRemove,
              ),
            ],
          ),
          for (var i = 0; i < draft.controllers.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: draft.controllers[i],
                      maxLength: 50,
                      decoration: InputDecoration(
                        hintText: '選択肢 ${i + 1}',
                        border: const OutlineInputBorder(),
                        isDense: true,
                        counterText: '',
                      ),
                      onChanged: (_) => onChanged(),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline),
                    tooltip: '削除',
                    onPressed: draft.controllers.length <= 2
                        ? null
                        : () {
                            draft.removeChoice(i);
                            onChanged();
                          },
                  ),
                ],
              ),
            ),
          if (draft.controllers.length < PollDraft.maxChoices)
            TextButton.icon(
              onPressed: () {
                draft.addChoice();
                onChanged();
              },
              icon: const Icon(Icons.add),
              label: const Text('選択肢を追加'),
            ),
          const Divider(),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            dense: true,
            title: const Text('複数選択を許可'),
            value: draft.multiple,
            onChanged: (value) {
              draft.multiple = value;
              onChanged();
            },
          ),
          Row(
            children: [
              const Text('締め切り'),
              const SizedBox(width: 12),
              DropdownButton<Duration?>(
                value: draft.duration,
                items: [
                  for (final entry in _durations.entries)
                    DropdownMenuItem(
                      value: entry.value,
                      child: Text(entry.key),
                    ),
                ],
                onChanged: (value) {
                  draft.duration = value;
                  onChanged();
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
