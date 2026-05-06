import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mischie/core/providers/core_providers.dart';

final composeNotifierProvider =
    AsyncNotifierProvider<ComposeNotifier, void>(ComposeNotifier.new);

class ComposeNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> postNote(String text) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final client = ref.read(misskeyApiClientProvider).value;
      if (client == null) throw Exception('未ログイン');
      await client.post('notes/create', body: {'text': text});
    });
  }
}
