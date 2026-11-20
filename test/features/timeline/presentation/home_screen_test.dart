import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mischie/core/emoji/emoji_providers.dart';
import 'package:mischie/core/providers/core_providers.dart';
import 'package:mischie/core/storage/prefs_store.dart';
import 'package:mischie/features/timeline/domain/timeline_notifier.dart';
import 'package:mischie/features/timeline/domain/timeline_source.dart';
import 'package:mischie/features/timeline/domain/user_list.dart';
import 'package:mischie/features/timeline/presentation/home_screen.dart';

import '../../../support/golden_support.dart';

class _MemoryPrefsStore implements PrefsStore {
  final values = <String, Object?>{};

  @override
  Future<T?> read<T>(String key) async => values[key] as T?;

  @override
  Future<void> write(String key, Object? value) async => values[key] = value;
}

void main() {
  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('receive_sharing_intent/messages'),
          (_) async => null,
        );
  });

  testWidgets('読み込めたリストがタブに並び、選ぶとタイムラインが切り替わる', (tester) async {
    final prefs = _MemoryPrefsStore();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          accountStoreProvider.overrideWithValue(FakeAccountStore()),
          prefsStoreProvider.overrideWithValue(prefs),
          userListsProvider.overrideWith(
            (ref) async => const [UserList(id: 'list1', name: '友達')],
          ),
        ],
        child: const MaterialApp(home: HomeScreen()),
      ),
    );
    await tester.pumpAndSettle();

    final tab = find.widgetWithText(Tab, '友達');
    expect(tab, findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tap(tab);
    await tester.pumpAndSettle();

    final container = ProviderScope.containerOf(
      tester.element(find.byType(HomeScreen)),
    );
    expect(
      container.read(selectedTimelineProvider),
      const TimelineSource.list(id: 'list1', name: '友達'),
    );
    expect(prefs.values['selected_timeline'], 'list:list1');
  });
}
