import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mischie/core/providers/core_providers.dart';
import 'package:mischie/core/streaming/streaming_service.dart';
import 'package:mischie/features/auth/domain/auth_notifier.dart';
import 'package:mischie/features/auth/domain/auth_state.dart';
import 'package:mischie/features/timeline/data/timeline_repository.dart';
import 'package:mischie/features/timeline/domain/note.dart';

final timelineRepositoryProvider = Provider<TimelineRepository?>((ref) {
  final clientAsync = ref.watch(misskeyApiClientProvider);
  final client = clientAsync.value;
  if (client == null) return null;
  return TimelineRepository(client);
});

final timelineNotifierProvider =
    AsyncNotifierProvider<TimelineNotifier, List<Note>>(TimelineNotifier.new);

class TimelineNotifier extends AsyncNotifier<List<Note>> {
  StreamingService? _streaming;
  StreamSubscription<Note>? _subscription;

  @override
  Future<List<Note>> build() async {
    final authState = ref.watch(authNotifierProvider).value;

    _subscription?.cancel();
    _streaming?.dispose();
    _streaming = null;

    if (authState is AuthStateAuthenticated) {
      _startStreaming(authState.host, authState.accessToken);
    }

    ref.onDispose(() {
      _subscription?.cancel();
      _streaming?.dispose();
    });

    final repo = ref.watch(timelineRepositoryProvider);
    if (repo == null) return [];
    return repo.fetchHomeTimeline();
  }

  void _startStreaming(String host, String accessToken) {
    _streaming = StreamingService(host: host, accessToken: accessToken);
    _streaming!.connect();
    _subscription = _streaming!.noteStream.listen((note) {
      final current = state.value;
      if (current != null) {
        state = AsyncValue.data([note, ...current]);
      }
    });
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(timelineRepositoryProvider);
      if (repo == null) return [];
      return repo.fetchHomeTimeline();
    });
  }

  Future<void> loadMore() async {
    final current = state.value;
    if (current == null || current.isEmpty) return;

    final repo = ref.read(timelineRepositoryProvider);
    if (repo == null) return;

    final older = await repo.fetchHomeTimeline(untilId: current.last.id);
    state = AsyncValue.data([...current, ...older]);
  }
}
