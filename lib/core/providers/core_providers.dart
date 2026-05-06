import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mischie/core/api/misskey_api_client.dart';
import 'package:mischie/core/storage/token_storage.dart';

final flutterSecureStorageProvider = Provider<FlutterSecureStorage>(
  (ref) => const FlutterSecureStorage(),
);

final tokenStorageProvider = Provider<TokenStorage>(
  (ref) => TokenStorage(ref.watch(flutterSecureStorageProvider)),
);

final misskeyApiClientProvider = FutureProvider<MisskeyApiClient?>((ref) async {
  final storage = ref.watch(tokenStorageProvider);
  final host = await storage.readServerHost();
  if (host == null) return null;
  return MisskeyApiClient(host: host, getToken: storage.readAccessToken);
});
