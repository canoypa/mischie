import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mischie/core/emoji/emoji_providers.dart';
import 'package:mischie/core/error/error_handler.dart';
import 'package:mischie/core/widgets/decorated_avatar.dart';
import 'package:mischie/core/widgets/mfm_text.dart';
import 'package:mischie/features/profile/domain/profile_notifier.dart';
import 'package:mischie/features/profile/domain/user_detailed.dart';
import 'package:mischie/features/profile/domain/user_relation_page.dart';
import 'package:mischie/features/profile/presentation/user_profile_screen.dart';

enum UserRelation {
  following('フォロー'),
  followers('フォロワー');

  const UserRelation(this.label);

  final String label;
}

void openUserRelations(
  BuildContext context, {
  required String userId,
  required UserRelation relation,
}) {
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => UserRelationsScreen(userId: userId, relation: relation),
    ),
  );
}

class UserRelationsScreen extends ConsumerStatefulWidget {
  const UserRelationsScreen({
    super.key,
    required this.userId,
    required this.relation,
  });

  final String userId;
  final UserRelation relation;

  @override
  ConsumerState<UserRelationsScreen> createState() =>
      _UserRelationsScreenState();
}

class _UserRelationsScreenState extends ConsumerState<UserRelationsScreen> {
  final List<UserDetailed> _users = [];
  bool _loading = true;
  bool _loadingMore = false;
  Object? _error;

  /// ユーザーの ID ではなく、フォロー関係の ID。
  String? _nextUntilId;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<UserRelationPage> _fetch({String? untilId}) {
    final repo = ref.read(profileRepositoryProvider)!;
    return widget.relation == UserRelation.following
        ? repo.fetchFollowing(widget.userId, untilId: untilId)
        : repo.fetchFollowers(widget.userId, untilId: untilId);
  }

  Future<void> _load() async {
    if (ref.read(profileRepositoryProvider) == null) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final page = await _fetch();
      if (!mounted) return;
      setState(() {
        _users
          ..clear()
          ..addAll(page.users);
        _nextUntilId = page.nextUntilId;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e;
        _loading = false;
      });
    }
  }

  Future<void> _loadMore() async {
    if (_loadingMore || _nextUntilId == null) return;
    setState(() => _loadingMore = true);
    try {
      final page = await _fetch(untilId: _nextUntilId);
      if (!mounted) return;
      setState(() {
        _users.addAll(page.users);
        _nextUntilId = page.nextUntilId;
      });
    } catch (_) {
      // 追加読み込みの失敗は黙って諦める（先頭は読めている）
    } finally {
      if (mounted) setState(() => _loadingMore = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final serverEmojis = ref.watch(emojiCacheProvider).value ?? const {};

    return Scaffold(
      appBar: AppBar(title: Text(widget.relation.label)),
      body: switch ((_loading, _error)) {
        (true, _) => const Center(child: CircularProgressIndicator()),
        (_, final Object error) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(resolveErrorMessage(error)),
              const SizedBox(height: 8),
              FilledButton(onPressed: _load, child: const Text('再試行')),
            ],
          ),
        ),
        _ =>
          _users.isEmpty
              ? Center(child: Text('${widget.relation.label}はいません'))
              : NotificationListener<ScrollUpdateNotification>(
                  onNotification: (n) {
                    final pos = n.metrics;
                    if (pos.pixels >= pos.maxScrollExtent - 200) _loadMore();
                    return false;
                  },
                  child: ListView.builder(
                    itemCount: _users.length + 1,
                    itemBuilder: (context, index) {
                      if (index == _users.length) {
                        return _loadingMore
                            ? const Padding(
                                padding: EdgeInsets.all(16),
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              )
                            : const SizedBox(height: 40);
                      }
                      return _UserTile(
                        user: _users[index],
                        emojis: serverEmojis,
                      );
                    },
                  ),
                ),
      },
    );
  }
}

class _UserTile extends StatelessWidget {
  const _UserTile({required this.user, required this.emojis});

  final UserDetailed user;
  final Map<String, String> emojis;

  @override
  Widget build(BuildContext context) {
    final handle = user.acct;

    return ListTile(
      leading: DecoratedAvatar(
        avatarUrl: user.avatarUrl,
        isCat: user.isCat,
        decorations: user.avatarDecorations,
      ),
      title: MfmText(user.name ?? user.username, emojis: emojis),
      subtitle: Text(handle),
      onTap: () => openUserProfile(context, user.id),
    );
  }
}
