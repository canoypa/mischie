/// ログイン済みのアカウント 1 つ。
///
/// Fediverse では同じ人が複数のサーバーに別々のアカウントを持つ。
/// 普段使いのサーバーと開発用サーバーを行き来できるようにするため、
/// ホストとトークンの組を複数保持する。
class Account {
  const Account({
    required this.host,
    required this.accessToken,
    this.userId,
    this.username,
    this.name,
    this.avatarUrl,
  });

  factory Account.fromJson(Map<String, dynamic> json) => Account(
    host: json['host'] as String,
    accessToken: json['accessToken'] as String,
    userId: json['userId'] as String?,
    username: json['username'] as String?,
    name: json['name'] as String?,
    avatarUrl: json['avatarUrl'] as String?,
  );

  final String host;
  final String accessToken;
  final String? userId;
  final String? username;
  final String? name;
  final String? avatarUrl;

  /// 同じサーバーの別アカウントも区別する。userId が取れていない
  /// （移行直後など）場合はホストだけで識別する。
  String get id => userId == null ? host : '$host/$userId';

  String get acct => username == null ? host : '@$username@$host';

  String get displayName => name ?? username ?? host;

  Map<String, dynamic> toJson() => {
    'host': host,
    'accessToken': accessToken,
    'userId': userId,
    'username': username,
    'name': name,
    'avatarUrl': avatarUrl,
  };

  Account copyWith({
    String? userId,
    String? username,
    String? name,
    String? avatarUrl,
  }) => Account(
    host: host,
    accessToken: accessToken,
    userId: userId ?? this.userId,
    username: username ?? this.username,
    name: name ?? this.name,
    avatarUrl: avatarUrl ?? this.avatarUrl,
  );
}
