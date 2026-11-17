import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mischie/core/error/error_handler.dart';
import 'package:mischie/features/timeline/domain/note.dart';
import 'package:mischie/features/timeline/domain/note_actions.dart';

class PollView extends ConsumerWidget {
  const PollView({super.key, required this.note, required this.poll});

  final Note note;
  final Poll poll;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final showResults = poll.hasVoted || poll.isExpired;
    final total = poll.totalVotes;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < poll.choices.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: showResults
                ? _Result(
                    choice: poll.choices[i],
                    maxVotes: poll.choices.fold(
                      0,
                      (max, c) => c.votes > max ? c.votes : max,
                    ),
                    onPressed:
                        poll.multiple &&
                            !poll.isExpired &&
                            !poll.choices[i].isVoted
                        ? () => _vote(context, ref, i)
                        : null,
                  )
                : _ChoiceButton(
                    text: poll.choices[i].text,
                    onPressed: () => _vote(context, ref, i),
                  ),
          ),
        Text(
          _footer(total),
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  String _footer(int total) {
    final parts = ['$total 票'];
    if (poll.multiple) parts.add('複数選択可');
    if (poll.isExpired) {
      parts.add('終了');
    } else if (poll.expiresAt != null) {
      parts.add('締め切りあり');
    }
    return parts.join(' · ');
  }

  Future<void> _vote(BuildContext context, WidgetRef ref, int choice) async {
    try {
      await ref.read(noteActionsProvider).vote(note, choice);
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(resolveErrorMessage(e))));
    }
  }
}

class _ChoiceButton extends StatelessWidget {
  const _ChoiceButton({required this.text, required this.onPressed});

  final String text;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
        child: Text(text),
      ),
    );
  }
}

class _Result extends StatelessWidget {
  const _Result({required this.choice, required this.maxVotes, this.onPressed});

  final PollChoice choice;
  final VoidCallback? onPressed;

  /// 帯は合計ではなく最多票を基準にする。
  /// 合計で割ると、複数選択可のとき比率の和が 100% を超える。
  final int maxVotes;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final ratio = maxVotes == 0 ? 0.0 : choice.votes / maxVotes;

    return Stack(
      children: [
        Container(
          height: 36,
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        FractionallySizedBox(
          widthFactor: ratio.clamp(0.0, 1.0),
          child: Container(
            height: 36,
            decoration: BoxDecoration(
              color: choice.isVoted
                  ? colorScheme.primaryContainer
                  : colorScheme.secondaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        SizedBox(
          height: 36,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                if (choice.isVoted) ...[
                  const Icon(Icons.check, size: 16),
                  const SizedBox(width: 4),
                ],
                Expanded(
                  child: Text(
                    choice.text,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                Text(
                  '${choice.votes} 票',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ),
        // 波紋が帯に隠れないよう、最前面に重ねる
        if (onPressed != null)
          Positioned.fill(
            child: Material(
              type: MaterialType.transparency,
              child: InkWell(
                onTap: onPressed,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
      ],
    );
  }
}
