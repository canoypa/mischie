import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mischie/features/auth/domain/auth_notifier.dart';

final testAccountIdProvider = NotifierProvider<TestAccountId, String?>(
  TestAccountId.new,
);

class TestAccountId extends Notifier<String?> {
  @override
  String? build() => 'example.test/alice';

  set id(String? value) => state = value;
}

/// 実物はセキュアストレージを読むので、テストでは差し替える。
final accountSwitchOverride = currentAccountIdProvider.overrideWith(
  (ref) => ref.watch(testAccountIdProvider),
);
