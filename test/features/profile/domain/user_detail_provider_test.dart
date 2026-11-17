import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mischie/core/api/misskey_api_client.dart';
import 'package:mischie/features/profile/data/profile_repository.dart';
import 'package:mischie/features/profile/domain/profile_notifier.dart';
import 'package:mischie/features/profile/domain/user_detailed.dart';

import '../../../support/account_switch.dart';

class _CountingRepository extends ProfileRepository {
  _CountingRepository()
    : super(MisskeyApiClient(host: 'example.test', getToken: () async => null));

  int fetches = 0;

  @override
  Future<UserDetailed> fetchUser(String userId) async {
    fetches++;
    return UserDetailed(id: userId, username: 'alice');
  }
}

void main() {
  test('プロフィールを閉じて開き直すと取り直す', () async {
    final repo = _CountingRepository();
    final container = ProviderContainer(
      overrides: [
        accountSwitchOverride,
        profileRepositoryProvider.overrideWithValue(repo),
      ],
    );
    addTearDown(container.dispose);

    final open = container.listen(userDetailProvider('u1'), (_, _) {});
    await container.read(userDetailProvider('u1').future);
    expect(repo.fetches, 1);

    await container.read(userDetailProvider('u1').future);
    expect(repo.fetches, 1);

    open.close();
    await Future<void>.delayed(Duration.zero);

    final reopen = container.listen(userDetailProvider('u1'), (_, _) {});
    addTearDown(reopen.close);
    await container.read(userDetailProvider('u1').future);
    expect(repo.fetches, 2);
  });
}
