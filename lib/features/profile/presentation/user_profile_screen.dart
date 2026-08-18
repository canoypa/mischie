import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blurhash/flutter_blurhash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mischie/core/emoji/emoji_providers.dart';
import 'package:mischie/core/error/error_handler.dart';
import 'package:mischie/core/navigation/link_handler.dart';
import 'package:mischie/core/widgets/decorated_avatar.dart';
import 'package:mischie/core/widgets/mfm_text.dart';
import 'package:mischie/features/profile/domain/profile_notifier.dart';
import 'package:mischie/features/profile/domain/user_detailed.dart';
import 'package:mischie/features/profile/presentation/user_relations_screen.dart';
import 'package:mischie/features/timeline/domain/note.dart';
import 'package:mischie/features/timeline/domain/user.dart';
import 'package:mischie/features/timeline/presentation/note_card.dart';

/// ユーザーのプロフィールと投稿一覧。
///
/// 自分のプロフィールタブからも他人のプロフィール画面からも使うため、
/// Scaffold は持たない（AppBar の有無は呼び出し側が決める）。
class UserProfileView extends ConsumerStatefulWidget {
  const UserProfileView({super.key, required this.userId, this.initialUser});

  final String userId;
  final User? initialUser;

  @override
  ConsumerState<UserProfileView> createState() => _UserProfileViewState();
}

class _UserProfileViewState extends ConsumerState<UserProfileView> {
  final _scrollController = ScrollController();

  final List<Note> _notes = [];
  bool _loadingNotes = false;
  bool _loadingMore = false;
  bool _notesError = false;
  Object? _notesErrorObject;

  @override
  void initState() {
    super.initState();
    _fetchInitial();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _fetchInitial() async {
    final repo = ref.read(profileRepositoryProvider);
    if (repo == null) return;
    setState(() {
      _loadingNotes = true;
      _notesError = false;
    });
    try {
      final notes = await repo.fetchUserNotes(widget.userId);
      if (!mounted) return;
      setState(() {
        _notes
          ..clear()
          ..addAll(notes);
        _loadingNotes = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loadingNotes = false;
        _notesError = true;
        _notesErrorObject = e;
      });
    }
  }

  Future<void> _loadMore() async {
    final repo = ref.read(profileRepositoryProvider);
    if (repo == null || _notes.isEmpty) return;
    setState(() => _loadingMore = true);
    try {
      final notes = await repo.fetchUserNotes(
        widget.userId,
        untilId: _notes.last.id,
      );
      if (!mounted) return;
      setState(() {
        _notes.addAll(notes);
        _loadingMore = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loadingMore = false);
    }
  }

  void _onScroll(ScrollUpdateNotification notification) {
    if (!_scrollController.hasClients) return;
    final pos = _scrollController.position;
    if (pos.pixels >= pos.maxScrollExtent - 300 &&
        !_loadingMore &&
        !_loadingNotes &&
        _notes.isNotEmpty) {
      _loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final detailAsync = ref.watch(userDetailProvider(widget.userId));
    final serverEmojis = ref.watch(emojiCacheProvider).value ?? const {};

    final initialUser = widget.initialUser;

    return NotificationListener<ScrollUpdateNotification>(
      onNotification: (n) {
        _onScroll(n);
        return false;
      },
      child: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverToBoxAdapter(
            child: _ProfileHeader(
              detailAsync: detailAsync,
              initialUser: initialUser,
              serverEmojis: serverEmojis,
              userId: widget.userId,
            ),
          ),
          if (_loadingNotes && _notes.isEmpty)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Center(child: CircularProgressIndicator()),
              ),
            )
          else if (_notesError && _notes.isEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        resolveErrorMessage(
                          _notesErrorObject ?? Exception('エラーが発生しました'),
                        ),
                      ),
                      const SizedBox(height: 8),
                      FilledButton(
                        onPressed: _fetchInitial,
                        child: const Text('再試行'),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => RepaintBoundary(
                  key: ValueKey(_notes[index].id),
                  child: NoteCard(
                    note: _notes[index],
                    serverEmojis: serverEmojis,
                  ),
                ),
                childCount: _notes.length,
              ),
            ),
          SliverToBoxAdapter(
            child: _loadingMore
                ? const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  )
                : const SizedBox(height: 80),
          ),
        ],
      ),
    );
  }
}

/// 他人のプロフィールを開く画面。AppBar 付きで UserProfileView を包む。
class UserProfileScreen extends ConsumerWidget {
  const UserProfileScreen({super.key, required this.userId, this.initialUser});

  final String userId;
  final User? initialUser;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detail = ref.watch(userDetailProvider(userId)).value;
    final username = detail?.username ?? initialUser?.username;
    final title =
        detail?.name ??
        initialUser?.name ??
        (username != null ? '@$username' : userId);

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [if (detail != null) _UserMenuButton(detail: detail)],
      ),
      body: UserProfileView(userId: userId, initialUser: initialUser),
    );
  }
}

class _ProfileHeader extends ConsumerWidget {
  const _ProfileHeader({
    required this.detailAsync,
    required this.initialUser,
    required this.serverEmojis,
    required this.userId,
  });

  final AsyncValue<UserDetailed> detailAsync;
  final User? initialUser;
  final Map<String, String> serverEmojis;
  final String userId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return detailAsync.when(
      loading: () {
        if (initialUser != null) {
          return _MinimalHeader(user: initialUser!);
        }
        return const Padding(
          padding: EdgeInsets.all(32),
          child: Center(child: CircularProgressIndicator()),
        );
      },
      error: (e, _) => Padding(
        padding: const EdgeInsets.all(32),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(resolveErrorMessage(e)),
              const SizedBox(height: 8),
              FilledButton(
                onPressed: () => ref.invalidate(userDetailProvider(userId)),
                child: const Text('再試行'),
              ),
            ],
          ),
        ),
      ),
      data: (detail) {
        final emojis = {...serverEmojis, ...detail.emojis};
        return _FullHeader(detail: detail, emojis: emojis);
      },
    );
  }
}

/// 詳細情報の取得中に initialUser だけで軽量に描画するヘッダー。
class _MinimalHeader extends StatelessWidget {
  const _MinimalHeader({required this.user});

  final User user;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final handle = user.host != null
        ? '@${user.username}@${user.host}'
        : '@${user.username}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            SizedBox(
              height: 150,
              width: double.infinity,
              child: Container(color: colorScheme.surfaceContainerHighest),
            ),
            Positioned(
              left: 16,
              bottom: -40,
              child: DecoratedAvatar(
                avatarUrl: user.avatarUrl,
                size: 96,
                isCat: user.isCat,
                decorations: user.avatarDecorations,
                borderColor: colorScheme.surface,
              ),
            ),
          ],
        ),
        const SizedBox(height: 48),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                user.name ?? user.username,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              Text(
                handle,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const Divider(),
      ],
    );
  }
}

class _FullHeader extends StatelessWidget {
  const _FullHeader({required this.detail, required this.emojis});

  final UserDetailed detail;
  final Map<String, String> emojis;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final handle = detail.host != null
        ? '@${detail.username}@${detail.host}'
        : '@${detail.username}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            SizedBox(
              height: 150,
              width: double.infinity,
              child: detail.bannerUrl != null
                  ? CachedNetworkImage(
                      imageUrl: detail.bannerUrl!,
                      fit: BoxFit.cover,
                      placeholder: (context, url) =>
                          detail.bannerBlurhash != null
                          ? BlurHash(hash: detail.bannerBlurhash!)
                          : Container(
                              color: colorScheme.surfaceContainerHighest,
                            ),
                    )
                  : Container(color: colorScheme.surfaceContainerHighest),
            ),
            Positioned(
              left: 16,
              bottom: -40,
              child: DecoratedAvatar(
                avatarUrl: detail.avatarUrl,
                size: 96,
                isCat: detail.isCat,
                decorations: detail.avatarDecorations,
                borderColor: colorScheme.surface,
              ),
            ),
          ],
        ),
        // アバターがバナーへ食い込んだ分の余白を、右側でボタンに使う
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: Align(
            alignment: Alignment.centerRight,
            child: _FollowButton(detail: detail),
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Flexible(
                    child: MfmText(
                      detail.name ?? detail.username,
                      emojis: emojis,
                      style: textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (detail.isBot) ...[
                    const SizedBox(width: 6),
                    const _CompactChip(icon: Icons.smart_toy, label: 'Bot'),
                  ],
                  if (detail.isCat) ...[
                    const SizedBox(width: 6),
                    const _CompactChip(icon: Icons.pets, label: 'Cat'),
                  ],
                ],
              ),
              Text(
                handle,
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              // フォロー中かどうかはボタンが示すので、
              // ここでは「相手からフォローされている」ことだけ出す
              if (detail.isFollowed) ...[
                const SizedBox(height: 8),
                const _RelationshipChip(label: 'フォローされています'),
              ],
              if (detail.roles.isNotEmpty) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: detail.roles
                      .map((role) => _RoleChip(role: role))
                      .toList(),
                ),
              ],
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  children: [
                    _StatColumn(count: detail.notesCount, label: 'ノート'),
                    _StatColumn(
                      count: detail.followingCount,
                      label: 'フォロー',
                      onTap: () => openUserRelations(
                        context,
                        userId: detail.id,
                        relation: UserRelation.following,
                      ),
                    ),
                    _StatColumn(
                      count: detail.followersCount,
                      label: 'フォロワー',
                      onTap: () => openUserRelations(
                        context,
                        userId: detail.id,
                        relation: UserRelation.followers,
                      ),
                    ),
                  ],
                ),
              ),
              if (detail.description != null && detail.description!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: MfmText(detail.description!, emojis: emojis),
                ),
              if (detail.fields.isNotEmpty)
                Column(
                  children: detail.fields
                      .map(
                        (field) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 96,
                                child: Text(
                                  field.name,
                                  style: textTheme.bodySmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: MfmText(
                                  field.value,
                                  emojis: emojis,
                                  style: textTheme.bodySmall,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                ),
              const SizedBox(height: 4),
              if (detail.location != null && detail.location!.isNotEmpty)
                _MetaRow(icon: Icons.location_on, text: detail.location!),
              if (detail.birthday != null)
                _MetaRow(
                  icon: Icons.cake,
                  text: _formatBirthday(detail.birthday!),
                ),
              if (detail.createdAt != null)
                _MetaRow(
                  icon: Icons.calendar_today,
                  text: _formatCreatedAt(detail.createdAt!),
                ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        const Divider(),
      ],
    );
  }

  String _formatBirthday(String birthday) {
    final match = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$').firstMatch(birthday);
    if (match == null) return birthday;
    final year = int.parse(match.group(1)!);
    final month = int.parse(match.group(2)!);
    final day = int.parse(match.group(3)!);
    return '$year年$month月$day日';
  }

  String _formatCreatedAt(String createdAt) {
    try {
      final date = DateTime.parse(createdAt);
      return '${date.year}年${date.month}月に登録';
    } catch (_) {
      return createdAt;
    }
  }
}

class _CompactChip extends StatelessWidget {
  const _CompactChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(icon, size: 14),
      label: Text(label),
      labelStyle: const TextStyle(fontSize: 11),
      visualDensity: VisualDensity.compact,
      padding: EdgeInsets.zero,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}

class _RelationshipChip extends StatelessWidget {
  const _RelationshipChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(label),
      labelStyle: const TextStyle(fontSize: 12),
      visualDensity: VisualDensity.compact,
      backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
      side: BorderSide.none,
    );
  }
}

class _RoleChip extends StatelessWidget {
  const _RoleChip({required this.role});

  final UserRole role;

  @override
  Widget build(BuildContext context) {
    final color = _parseHexColor(role.color);
    return Chip(
      avatar: role.iconUrl != null
          ? CircleAvatar(
              radius: 8,
              backgroundImage: CachedNetworkImageProvider(role.iconUrl!),
            )
          : null,
      label: Text(role.name),
      labelStyle: const TextStyle(fontSize: 12),
      visualDensity: VisualDensity.compact,
      side: color != null ? BorderSide(color: color) : null,
    );
  }

  Color? _parseHexColor(String? hex) {
    if (hex == null) return null;
    var value = hex.trim();
    if (value.startsWith('#')) value = value.substring(1);
    if (value.length == 3) {
      value = value.split('').map((c) => '$c$c').join();
    }
    if (value.length != 6) return null;
    final intValue = int.tryParse(value, radix: 16);
    if (intValue == null) return null;
    return Color(0xFF000000 | intValue);
  }
}

class _StatColumn extends StatelessWidget {
  const _StatColumn({required this.count, required this.label, this.onTap});

  final int? count;
  final String label;

  /// 数字は一覧への入り口。押せるものは押せると分かるようにする。
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final content = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            count?.toString() ?? '-',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );

    if (onTap == null) return content;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: content,
    );
  }
}

class _MetaRow extends StatelessWidget {
  const _MetaRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 16,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// フォロー / フォロー解除ボタン。自分自身のプロフィールでは何も出さない。
class _FollowButton extends ConsumerWidget {
  const _FollowButton({required this.detail});

  final UserDetailed detail;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final myId = ref.watch(profileNotifierProvider).value?.id;
    if (myId == detail.id) return const SizedBox.shrink();

    final override = ref.watch(
      followOverridesProvider.select((m) => m[detail.id]),
    );
    final isFollowing = override ?? detail.isFollowing;

    Future<void> toggle() async {
      try {
        await ref
            .read(followActionsProvider)
            .setFollowing(detail.id, following: !isFollowing);
      } catch (e) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(resolveErrorMessage(e))));
      }
    }

    if (isFollowing) {
      return OutlinedButton.icon(
        onPressed: toggle,
        icon: const Icon(Icons.check, size: 18),
        label: const Text('フォロー中'),
      );
    }
    return FilledButton.icon(
      onPressed: toggle,
      icon: const Icon(Icons.person_add_alt, size: 18),
      label: const Text('フォロー'),
    );
  }
}

/// プロフィール右上のメニュー。ミュート・ブロックと Web で開く。
class _UserMenuButton extends ConsumerWidget {
  const _UserMenuButton({required this.detail});

  final UserDetailed detail;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final myId = ref.watch(profileNotifierProvider).value?.id;
    final isMe = myId == detail.id;
    final hidden = ref.watch(
      hiddenUserIdsProvider.select((ids) => ids.contains(detail.id)),
    );
    final isMuted = detail.isMuted || hidden;
    final isBlocking = detail.isBlocking;
    return PopupMenuButton<String>(
      onSelected: (value) => _select(context, ref, value),
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'browser',
          child: ListTile(
            leading: Icon(Icons.open_in_browser),
            title: Text('ブラウザで開く'),
          ),
        ),
        if (!isMe) ...[
          PopupMenuItem(
            value: 'mute',
            child: ListTile(
              leading: const Icon(Icons.volume_off_outlined),
              title: Text(isMuted ? 'ミュート解除' : 'ミュート'),
            ),
          ),
          PopupMenuItem(
            value: 'block',
            child: ListTile(
              leading: const Icon(Icons.block),
              title: Text(isBlocking ? 'ブロック解除' : 'ブロック'),
            ),
          ),
        ],
      ],
      child: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 12),
        child: Icon(Icons.more_vert),
      ),
    );
  }

  Future<void> _select(
    BuildContext context,
    WidgetRef ref,
    String value,
  ) async {
    final actions = ref.read(moderationActionsProvider);
    final hidden = ref.read(hiddenUserIdsProvider).contains(detail.id);
    final acct = '@${detail.username}';

    try {
      switch (value) {
        case 'browser':
          await openOnServer(
            ref,
            detail.host == null
                ? '/@${detail.username}'
                : '/@${detail.username}@${detail.host}',
          );
        case 'mute':
          final muted = detail.isMuted || hidden;
          await actions.setMuted(detail.id, muted: !muted);
          if (context.mounted) {
            _toast(context, muted ? '$acct のミュートを解除しました' : '$acct をミュートしました');
          }
        case 'block':
          await actions.setBlocked(detail.id, blocked: !detail.isBlocking);
          if (context.mounted) {
            _toast(
              context,
              detail.isBlocking ? '$acct のブロックを解除しました' : '$acct をブロックしました',
            );
          }
      }
    } catch (e) {
      if (!context.mounted) return;
      _toast(context, resolveErrorMessage(e));
    }
  }

  void _toast(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}
