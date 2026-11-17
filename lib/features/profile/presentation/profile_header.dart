import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blurhash/flutter_blurhash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mischie/core/emoji/layered_emojis.dart';
import 'package:mischie/core/navigation/link_handler.dart';
import 'package:mischie/core/widgets/confirm_dialog.dart';
import 'package:mischie/core/widgets/decorated_avatar.dart';
import 'package:mischie/core/error/error_handler.dart';
import 'package:mischie/core/image/image_cache_managers.dart';
import 'package:mischie/core/widgets/mfm_text.dart';
import 'package:mischie/features/profile/domain/profile_notifier.dart';
import 'package:mischie/features/profile/domain/user_detailed.dart';
import 'package:mischie/features/profile/presentation/profile_parts.dart';
import 'package:mischie/features/profile/presentation/user_relations_screen.dart';
import 'package:mischie/features/timeline/domain/user.dart';

const _avatarSize = 96.0;
const _avatarOverhang = 40.0;

class ProfileHeader extends ConsumerWidget {
  const ProfileHeader({
    super.key,
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
          return MinimalHeader(user: initialUser!);
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
        final emojis = LayeredEmojis(
          base: serverEmojis,
          overlay: detail.emojis,
        );
        return FullHeader(detail: detail, emojis: emojis);
      },
    );
  }
}

class MinimalHeader extends StatelessWidget {
  const MinimalHeader({super.key, required this.user});

  final User user;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final handle = user.acct;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            SizedBox(
              height: 104,
              width: double.infinity,
              child: Container(color: colorScheme.surfaceContainerHighest),
            ),
            Positioned(
              left: 16,
              bottom: -_avatarOverhang,
              child: DecoratedAvatar(
                avatarUrl: user.avatarUrl,
                size: _avatarSize,
                isCat: user.isCat,
                decorations: user.avatarDecorations,
                borderColor: colorScheme.surface,
              ),
            ),
          ],
        ),
        const SizedBox(height: _avatarOverhang + 8),
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

class FullHeader extends StatelessWidget {
  const FullHeader({super.key, required this.detail, required this.emojis});

  final UserDetailed detail;
  final Map<String, String> emojis;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final handle = detail.acct;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            SizedBox(
              // バナーが無いときは、無地の帯で名前を押し下げないよう低くする。
              height: detail.bannerUrl != null ? 150 : 104,
              width: double.infinity,
              child: detail.bannerUrl != null
                  ? CachedNetworkImage(
                      imageUrl: detail.bannerUrl!,
                      cacheManager: MediaCacheManager.instance,
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
              bottom: -_avatarOverhang,
              child: DecoratedAvatar(
                avatarUrl: detail.avatarUrl,
                size: _avatarSize,
                isCat: detail.isCat,
                decorations: detail.avatarDecorations,
                borderColor: colorScheme.surface,
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          // 自分のプロフィールではボタンが消えるので、アイコンのはみ出し分の
          // 高さを下限で確保する。
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: _avatarOverhang),
            child: Align(
              alignment: Alignment.centerRight,
              child: FollowButton(detail: detail),
            ),
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
                    const CompactChip(icon: Icons.smart_toy, label: 'Bot'),
                  ],
                ],
              ),
              const SizedBox(height: 2),
              Text(
                handle,
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              if (detail.isFollowed) ...[
                const SizedBox(height: 8),
                const RelationshipChip(label: 'フォローされています'),
              ],
              if (detail.roles.isNotEmpty) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: detail.roles
                      .map((role) => RoleChip(role: role))
                      .toList(),
                ),
              ],
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  spacing: 12,
                  children: [
                    StatColumn(count: detail.notesCount, label: 'ノート'),
                    StatColumn(
                      count: detail.followingCount,
                      label: 'フォロー',
                      onTap: () => openUserRelations(
                        context,
                        userId: detail.id,
                        relation: UserRelation.following,
                      ),
                    ),
                    StatColumn(
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
                  child: MfmText(
                    detail.description!,
                    emojis: emojis,
                    host: detail.host,
                  ),
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
                MetaRow(icon: Icons.location_on, text: detail.location!),
              if (detail.birthday != null)
                MetaRow(
                  icon: Icons.cake,
                  text: _formatBirthday(detail.birthday!),
                ),
              if (detail.createdAt != null)
                MetaRow(
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

class FollowButton extends ConsumerWidget {
  const FollowButton({super.key, required this.detail});

  final UserDetailed detail;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final myId = ref.watch(profileNotifierProvider).value?.id;
    if (myId == detail.id) return const SizedBox.shrink();

    final followState =
        ref.watch(followOverridesProvider.select((m) => m[detail.id])) ??
        detail.followState;
    final actions = ref.read(followActionsProvider);

    Future<void> run(Future<void> Function() action) async {
      try {
        await action();
      } catch (e) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(resolveErrorMessage(e))));
      }
    }

    switch (followState) {
      case FollowState.following:
        return OutlinedButton.icon(
          onPressed: () async {
            final ok = await showConfirmDialog(
              context,
              title: 'フォロー解除',
              message: '${detail.acct} のフォローを解除しますか？',
              action: '解除',
            );
            if (ok) await run(() => actions.unfollow(detail.id));
          },
          icon: const Icon(Icons.check, size: 18),
          label: const Text('フォロー中'),
        );
      case FollowState.requested:
        return OutlinedButton.icon(
          onPressed: () async {
            final ok = await showConfirmDialog(
              context,
              title: 'フォロー申請の取り消し',
              message: '${detail.acct} へのフォロー申請を取り消しますか？',
              action: '取り消す',
            );
            if (ok) await run(() => actions.cancelRequest(detail.id));
          },
          icon: const Icon(Icons.hourglass_empty, size: 18),
          label: const Text('申請中'),
        );
      case FollowState.none:
        return FilledButton.icon(
          onPressed: () =>
              run(() => actions.follow(detail.id, locked: detail.isLocked)),
          icon: Icon(
            detail.isLocked ? Icons.lock_outline : Icons.person_add_alt,
            size: 18,
          ),
          label: Text(detail.isLocked ? 'フォロー申請' : 'フォロー'),
        );
    }
  }
}

class UserMenuButton extends ConsumerWidget {
  const UserMenuButton({super.key, required this.detail});

  final UserDetailed detail;

  bool _isMuted(UserModeration? override) => override?.muted ?? detail.isMuted;

  bool _isBlocking(UserModeration? override) =>
      override?.blocking ?? detail.isBlocking;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final myId = ref.watch(profileNotifierProvider).value?.id;
    final isMe = myId == detail.id;
    final moderation = ref.watch(
      moderationOverridesProvider.select((m) => m[detail.id]),
    );
    final isMuted = _isMuted(moderation);
    final isBlocking = _isBlocking(moderation);
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
    final moderation = ref.read(moderationOverridesProvider)[detail.id];
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
          final muted = _isMuted(moderation);
          await actions.setMuted(detail.id, muted: !muted);
          if (context.mounted) {
            _toast(context, muted ? '$acct のミュートを解除しました' : '$acct をミュートしました');
          }
        case 'block':
          final blocking = _isBlocking(moderation);
          if (!blocking) {
            final ok = await showConfirmDialog(
              context,
              title: 'ブロック',
              message: '$acct をブロックしますか？相手からあなたのノートは見えなくなります。',
              action: 'ブロック',
            );
            if (!ok || !context.mounted) return;
          }
          await actions.setBlocked(detail.id, blocked: !blocking);
          if (context.mounted) {
            _toast(
              context,
              blocking ? '$acct のブロックを解除しました' : '$acct をブロックしました',
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
