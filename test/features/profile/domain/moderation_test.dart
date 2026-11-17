import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mischie/core/api/misskey_api_client.dart';
import 'package:mischie/features/profile/data/profile_repository.dart';
import 'package:mischie/features/profile/domain/profile_notifier.dart';
import 'package:mischie/features/profile/domain/user_detailed.dart';

import '../../../support/account_switch.dart';

class _FakeProfileRepository extends ProfileRepository {
  _FakeProfileRepository()
    : super(MisskeyApiClient(host: 'example.test', getToken: () async => null));

  final calls = <String>[];

  @override
  Future<void> mute(String userId) async => calls.add('mute:$userId');

  @override
  Future<void> unmute(String userId) async => calls.add('unmute:$userId');

  @override
  Future<void> block(String userId) async => calls.add('block:$userId');

  @override
  Future<void> unblock(String userId) async => calls.add('unblock:$userId');

  @override
  Future<void> follow(String userId) async => calls.add('follow:$userId');

  @override
  Future<void> cancelFollowRequest(String userId) async =>
      calls.add('cancel:$userId');
}

void main() {
  late _FakeProfileRepository repo;
  late ProviderContainer container;

  setUp(() {
    repo = _FakeProfileRepository();
    container = ProviderContainer(
      overrides: [
        accountSwitchOverride,
        profileRepositoryProvider.overrideWithValue(repo),
      ],
    );
    addTearDown(container.dispose);
    container.listen(moderationOverridesProvider, (_, _) {});
    container.listen(hiddenUserIdsProvider, (_, _) {});
    container.listen(followOverridesProvider, (_, _) {});
  });

  UserModeration? stateOf(String userId) =>
      container.read(moderationOverridesProvider)[userId];

  group('ミュートとブロックは別々に持つ', () {
    test('ブロックしてもミュート側は変わらない', () async {
      final actions = container.read(moderationActionsProvider);

      await actions.setBlocked('u1', blocked: true);

      expect(stateOf('u1')!.blocking, isTrue);
      expect(stateOf('u1')!.muted, isNull);
      expect(repo.calls, ['block:u1']);
    });

    test('ミュートしてもブロック側は変わらない', () async {
      final actions = container.read(moderationActionsProvider);

      await actions.setMuted('u1', muted: true);

      expect(stateOf('u1')!.muted, isTrue);
      expect(stateOf('u1')!.blocking, isNull);
      expect(repo.calls, ['mute:u1']);
    });

    test('片方を解除しても、もう片方は残る', () async {
      final actions = container.read(moderationActionsProvider);
      await actions.setMuted('u1', muted: true);
      await actions.setBlocked('u1', blocked: true);

      await actions.setBlocked('u1', blocked: false);

      expect(stateOf('u1')!.muted, isTrue);
      expect(stateOf('u1')!.blocking, isFalse);
      expect(container.read(hiddenUserIdsProvider), {'u1'});
    });

    test('どちらも解除すれば、ノートを伏せなくなる', () async {
      final actions = container.read(moderationActionsProvider);
      await actions.setMuted('u1', muted: true);
      await actions.setBlocked('u1', blocked: true);

      await actions.setMuted('u1', muted: false);
      await actions.setBlocked('u1', blocked: false);

      expect(container.read(hiddenUserIdsProvider), isEmpty);
    });

    test('ユーザーごとに独立している', () async {
      final actions = container.read(moderationActionsProvider);

      await actions.setMuted('u1', muted: true);

      expect(stateOf('u2'), isNull);
      expect(container.read(hiddenUserIdsProvider), {'u1'});
    });
  });

  test('ブロックするとフォロー状態も外れる', () async {
    final actions = container.read(moderationActionsProvider);
    container
        .read(followOverridesProvider.notifier)
        .put('u1', FollowState.following);

    await actions.setBlocked('u1', blocked: true);

    expect(container.read(followOverridesProvider)['u1'], FollowState.none);
  });

  test('API が失敗したら上書きしない', () async {
    final failing = _FailingRepository();
    final failingContainer = ProviderContainer(
      overrides: [
        accountSwitchOverride,
        profileRepositoryProvider.overrideWithValue(failing),
      ],
    );
    addTearDown(failingContainer.dispose);
    failingContainer.listen(moderationOverridesProvider, (_, _) {});

    await expectLater(
      failingContainer
          .read(moderationActionsProvider)
          .setBlocked('u1', blocked: true),
      throwsException,
    );

    expect(failingContainer.read(moderationOverridesProvider), isEmpty);
  });

  group('フォロー', () {
    FollowState? followOf(String userId) =>
        container.read(followOverridesProvider)[userId];

    test('鍵アカウントへのフォローは申請中になり、取り消すと戻る', () async {
      final actions = container.read(followActionsProvider);

      await actions.follow('u1', locked: true);
      expect(followOf('u1'), FollowState.requested);

      await actions.cancelRequest('u1');
      expect(followOf('u1'), FollowState.none);
      expect(repo.calls, ['follow:u1', 'cancel:u1']);
    });

    test('鍵のないアカウントはすぐフォロー中になる', () async {
      await container.read(followActionsProvider).follow('u1', locked: false);
      expect(followOf('u1'), FollowState.following);
    });
  });
}

class _FailingRepository extends _FakeProfileRepository {
  @override
  Future<void> block(String userId) async => throw Exception('failed');
}
