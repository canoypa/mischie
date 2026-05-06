import 'package:mischie/core/api/misskey_api_client.dart';
import 'package:mischie/features/timeline/domain/user.dart';

class ProfileRepository {
  const ProfileRepository(this._client);

  final MisskeyApiClient _client;

  Future<User> fetchMe() async {
    final data = await _client.post('i');
    return User.fromJson(data);
  }
}
