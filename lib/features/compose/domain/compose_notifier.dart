import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mischie/core/providers/core_providers.dart';

final composeNotifierProvider = AsyncNotifierProvider<ComposeNotifier, void>(
  ComposeNotifier.new,
);

enum NoteVisibility { public, home, followers, specified }

class ComposeNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> postNote(
    String text, {
    String? cw,
    NoteVisibility visibility = NoteVisibility.public,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final client = ref.read(misskeyApiClientProvider).value;
      if (client == null) throw Exception('未ログイン');
      await client.post('notes/create', body: {
        'text': text,
        if (cw != null && cw.isNotEmpty) 'cw': cw,
        'visibility': visibility.name,
      });
    });
  }
}
