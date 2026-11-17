import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mischie/core/api/misskey_api_client.dart';
import 'package:mischie/core/api/request_log.dart';
import 'package:mischie/core/storage/account_store.dart';
import 'package:mischie/features/auth/domain/auth_notifier.dart';

final flutterSecureStorageProvider = Provider<FlutterSecureStorage>(
  (ref) => const FlutterSecureStorage(),
);

final accountStoreProvider = Provider<AccountStore>(
  (ref) => AccountStore(ref.watch(flutterSecureStorageProvider)),
);

final requestLogProvider = Provider<RequestLog>((ref) {
  final log = RequestLog();
  ref.onDispose(log.dispose);
  return log;
});

final misskeyApiClientProvider = Provider<MisskeyApiClient?>((ref) {
  final account = ref.watch(activeAccountProvider);
  if (account == null) return null;
  final log = ref.watch(requestLogProvider);
  return MisskeyApiClient(
    host: account.host,
    getToken: () async => account.accessToken,
    onRequest: log.record,
  );
});
