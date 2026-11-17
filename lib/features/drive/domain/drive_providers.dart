import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mischie/core/providers/core_providers.dart';
import 'package:mischie/features/drive/data/drive_repository.dart';

final driveRepositoryProvider = Provider<DriveRepository?>((ref) {
  final client = ref.watch(misskeyApiClientProvider);
  if (client == null) return null;
  return DriveRepository(client);
});
