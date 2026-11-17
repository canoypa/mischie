import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mischie/core/providers/core_providers.dart';
import 'package:mischie/features/compose/data/compose_repository.dart';

enum NoteVisibility {
  public,
  home,
  followers,
  specified;

  static NoteVisibility fromName(String? name) => NoteVisibility.values
      .firstWhere((v) => v.name == name, orElse: () => NoteVisibility.public);
}

final composeRepositoryProvider = Provider<ComposeRepository?>((ref) {
  final client = ref.watch(misskeyApiClientProvider);
  if (client == null) return null;
  return ComposeRepository(client);
});

final composeNotifierProvider = AsyncNotifierProvider<ComposeNotifier, void>(
  ComposeNotifier.new,
);

class ComposeNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> postNote(
    String text, {
    String? cw,
    NoteVisibility visibility = NoteVisibility.public,
    String? replyId,
    String? renoteId,
    String? channelId,
    List<String> fileIds = const [],
    List<String> pollChoices = const [],
    bool pollMultiple = false,
    Duration? pollDuration,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(composeRepositoryProvider);
      if (repo == null) throw Exception('未ログイン');
      await repo.postNote(
        text,
        cw: cw,
        visibility: visibility,
        replyId: replyId,
        renoteId: renoteId,
        channelId: channelId,
        fileIds: fileIds,
        pollChoices: pollChoices,
        pollMultiple: pollMultiple,
        pollDuration: pollDuration,
      );
    });
  }
}
