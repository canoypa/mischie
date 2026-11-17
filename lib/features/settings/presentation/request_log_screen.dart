import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mischie/core/providers/core_providers.dart';

/// API を無駄に呼んでいないかを確かめるための画面。
class RequestLogScreen extends ConsumerWidget {
  const RequestLogScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final log = ref.watch(requestLogProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('通信ログ'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: '記録を消す',
            onPressed: log.clear,
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: log,
        builder: (context, _) {
          final counts = log.countsByPath();
          final lastMinute = log.recentCount(const Duration(minutes: 1));
          final since = log.since;

          return ListView(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    _Stat(label: '直近 1 分', value: '$lastMinute'),
                    _Stat(label: '件数', value: '${log.total}'),
                    _Stat(
                      label: '最古',
                      value: since == null
                          ? '-'
                          : '${DateTime.now().difference(since).inMinutes} 分前',
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              if (counts.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(child: Text('まだ記録がありません')),
                )
              else
                for (final entry in counts)
                  ListTile(
                    dense: true,
                    title: Text(entry.key),
                    trailing: Text(
                      '${entry.value}',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
            ],
          );
        },
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value, style: Theme.of(context).textTheme.headlineSmall),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
