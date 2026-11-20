import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mischie/core/emoji/emoji_providers.dart';
import 'package:mischie/core/emoji/layered_emojis.dart';
import 'package:mischie/core/navigation/link_handler.dart';
import 'package:mischie/core/widgets/scrollable_message.dart';
import 'package:mischie/core/error/error_handler.dart';
import 'package:mischie/core/widgets/custom_emoji_image.dart';
import 'package:mischie/core/widgets/decorated_avatar.dart';
import 'package:mischie/core/widgets/mfm_text.dart';
import 'package:mischie/features/drive/presentation/drive_screen.dart';
import 'package:mischie/features/profile/presentation/user_profile_screen.dart';
import 'package:mischie/features/notification/domain/notification_item.dart';
import 'package:mischie/features/notification/domain/notification_label.dart';
import 'package:mischie/features/notification/domain/notification_notifier.dart';
import 'package:mischie/features/timeline/domain/user.dart';
import 'package:mischie/features/timeline/presentation/note_detail_screen.dart';
import 'package:timeago/timeago.dart' as timeago;

/// `:name:` / `:name@host:` 形式のリアクションキーから絵文字名を取る。
final _customEmojiKeyPattern = RegExp(r'^:([^:]+):$');

String? _lookupGroupedEmojiUrl(Map<String, String> emojis, String key) {
  final match = _customEmojiKeyPattern.firstMatch(key);
  final identifier = match?.group(1) ?? key;
  final url = emojis[identifier];
  if (url != null) return url;
  final atIndex = identifier.indexOf('@');
  if (atIndex <= 0) return null;
  return emojis[identifier.substring(0, atIndex)];
}

/// HomeScreen から scrollToTop() を呼ぶための GlobalKey。
final notificationScreenKey = GlobalKey<NotificationScreenState>();

class NotificationScreen extends ConsumerStatefulWidget {
  NotificationScreen() : super(key: notificationScreenKey);

  @override
  ConsumerState<NotificationScreen> createState() => NotificationScreenState();
}

class NotificationScreenState extends ConsumerState<NotificationScreen> {
  bool _loadingMore = false;
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void scrollToTop() {
    if (!_scrollController.hasClients) return;
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
    );
  }

  Future<void> _loadMore() async {
    if (_loadingMore) return;
    setState(() => _loadingMore = true);
    try {
      await ref.read(notificationNotifierProvider.notifier).loadMore();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(resolveErrorMessage(e))));
      }
    } finally {
      if (mounted) setState(() => _loadingMore = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final asyncState = ref.watch(notificationNotifierProvider);
    final serverEmojis = ref.watch(emojiCacheProvider).value ?? {};

    return asyncState.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => RefreshIndicator(
        onRefresh: () =>
            ref.read(notificationNotifierProvider.notifier).refresh(),
        child: ScrollableMessage(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(resolveErrorMessage(e)),
              const SizedBox(height: 8),
              FilledButton(
                onPressed: () => ref.invalidate(notificationNotifierProvider),
                child: const Text('再試行'),
              ),
            ],
          ),
        ),
      ),
      data: (items) => RefreshIndicator(
        onRefresh: () =>
            ref.read(notificationNotifierProvider.notifier).refresh(),
        child: items.isEmpty
            ? const ScrollableMessage(child: Text('通知はありません'))
            : NotificationListener<ScrollUpdateNotification>(
                onNotification: (n) {
                  final pos = n.metrics;
                  if (pos.pixels >= pos.maxScrollExtent - 200) _loadMore();
                  return false;
                },
                child: ListView.builder(
                  controller: _scrollController,
                  itemCount: items.length + 1,
                  itemBuilder: (context, index) {
                    if (index == items.length) {
                      return _loadingMore
                          ? const Padding(
                              padding: EdgeInsets.all(16),
                              child: Center(child: CircularProgressIndicator()),
                            )
                          : const SizedBox(height: 80);
                    }
                    return _NotificationTile(
                      item: items[index],
                      serverEmojis: serverEmojis,
                    );
                  },
                ),
              ),
      ),
    );
  }
}

class _NotificationTile extends ConsumerWidget {
  const _NotificationTile({required this.item, required this.serverEmojis});

  final NotificationItem item;
  final Map<String, String> serverEmojis;

  List<User> get _groupActors => switch (item.type) {
    'reaction:grouped' =>
      (item.reactions ?? const []).map((r) => r.user).toList(),
    'renote:grouped' => item.users ?? const [],
    _ => const [],
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final label = notificationLabel(item.type);
    final isGrouped =
        item.type == 'reaction:grouped' || item.type == 'renote:grouped';
    final groupActors = _groupActors;
    // まとめ通知には user が無いので、先頭（最新）の相手をアイコンに出す。
    final leadUser = isGrouped
        ? (groupActors.isNotEmpty ? groupActors.first : null)
        : item.user;
    final (badgeColor, onBadgeColor) = switch (label.role) {
      NotificationRole.primary => (colorScheme.primary, colorScheme.onPrimary),
      NotificationRole.secondary => (
        colorScheme.secondary,
        colorScheme.onSecondary,
      ),
      NotificationRole.tertiary => (
        colorScheme.tertiary,
        colorScheme.onTertiary,
      ),
      NotificationRole.neutral => (
        colorScheme.surfaceContainerHighest,
        colorScheme.onSurfaceVariant,
      ),
    };

    final username = leadUser?.name ?? leadUser?.username ?? '不明';
    final handle = leadUser?.acct;
    final time = timeago.format(DateTime.parse(item.createdAt), locale: 'ja');
    final noteEmojis = LayeredEmojis(
      base: serverEmojis,
      overlay: {...?item.note?.emojis, ...?item.note?.reactionEmojis},
    );

    return ListTile(
      leading: SizedBox(
        width: 48,
        height: 48,
        child: Stack(
          children: [
            // アイコンからは相手のプロフィールへ。通知そのもののタップ先
            // （ノート）とは期待される行き先が違う。
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: leadUser == null
                    ? null
                    : () => openUserProfile(
                        context,
                        leadUser.id,
                        initialUser: leadUser,
                      ),
                child: DecoratedAvatar(
                  size: 48,
                  avatarUrl: leadUser?.avatarUrl,
                  isCat: leadUser?.isCat ?? false,
                  avatarBlurhash: leadUser?.avatarBlurhash,
                  decorations: leadUser?.avatarDecorations ?? const [],
                ),
              ),
            ),
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: badgeColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: colorScheme.surface, width: 1.5),
                ),
                child: Icon(label.icon, size: 12, color: onBadgeColor),
              ),
            ),
          ],
        ),
      ),
      title: isGrouped
          ? _GroupedTitle(
              actors: groupActors,
              label: label,
              serverEmojis: serverEmojis,
            )
          : label.hasActor
          ? Row(
              children: [
                Flexible(
                  child: MfmText(
                    username,
                    emojis: serverEmojis,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (handle != null)
                  Text(
                    ' $handle',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                Text(
                  ' ${label.text}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            )
          : Text(label.text, style: Theme.of(context).textTheme.bodyMedium),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isGrouped) _GroupedAvatars(item: item, emojis: noteEmojis),
          // CW 付きのノートは、本文ではなく注意書きを出す（一覧で中身を見せない）
          if (item.note?.cw ?? item.note?.text case final summary?)
            MfmText(
              summary,
              emojis: noteEmojis,
              host: item.note!.user.host,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          if (!isGrouped && item.reaction != null)
            MfmText(
              item.reaction!,
              emojis: noteEmojis,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          if (item.type == 'receiveFollowRequest' && leadUser != null)
            _FollowRequestActions(userId: leadUser.id),
        ],
      ),
      trailing: Text(time, style: Theme.of(context).textTheme.bodySmall),
      onTap: () {
        final note = item.note;
        if (note != null) {
          openNoteDetail(context, note);
          return;
        }
        switch (item.type) {
          case 'chatRoomInvitationReceived':
            openOnServer(ref, '/chat');
            return;
          case 'achievementEarned':
            openOnServer(ref, '/my/achievements');
            return;
          case 'exportCompleted':
            Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const DriveScreen()));
            return;
        }
        if (leadUser != null) {
          openUserProfile(context, leadUser.id, initialUser: leadUser);
        }
      },
    );
  }
}

/// 単発行と揃えて「さん」は付けない。
class _GroupedTitle extends StatelessWidget {
  const _GroupedTitle({
    required this.actors,
    required this.label,
    required this.serverEmojis,
  });

  final List<User> actors;
  final NotificationLabel label;
  final Map<String, String> serverEmojis;

  @override
  Widget build(BuildContext context) {
    if (actors.isEmpty) {
      return Text(label.text, style: Theme.of(context).textTheme.bodyMedium);
    }
    final first = actors.first;
    final firstName = first.name ?? first.username;
    final otherCount = actors.length - 1;

    return Row(
      children: [
        Flexible(
          child: MfmText(
            firstName,
            emojis: serverEmojis,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        Text(
          otherCount > 0 ? ' ほか $otherCount 人${label.text}' : ' ${label.text}',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }
}

class _GroupedAvatars extends StatelessWidget {
  const _GroupedAvatars({required this.item, required this.emojis});

  final NotificationItem item;
  final Map<String, String> emojis;

  @override
  Widget build(BuildContext context) {
    final reactions = item.reactions;
    final users = item.users;

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: reactions != null
          ? _AvatarStack(
              users: reactions.map((r) => r.user).toList(),
              reactions: reactions.map((r) => r.reaction).toList(),
              emojis: emojis,
            )
          : _AvatarStack(users: users ?? const [], emojis: emojis),
    );
  }
}

class _AvatarStack extends StatelessWidget {
  const _AvatarStack({
    required this.users,
    required this.emojis,
    this.reactions,
  });

  final List<User> users;
  final Map<String, String> emojis;

  /// [users] と同じ順・同じ長さ。バッジを乗せない（リノートのまとめ）
  /// なら null。
  final List<String>? reactions;

  static const _size = 28.0;
  static const _max = 6;

  @override
  Widget build(BuildContext context) {
    final shown = users.take(_max).toList();
    if (shown.isEmpty) return const SizedBox.shrink();
    final overflow = users.length - shown.length;
    const size = _size;
    final step = size * 2 / 3;
    final slots = shown.length + (overflow > 0 ? 1 : 0);
    final width = size + step * (slots - 1);

    return SizedBox(
      width: width,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // 先頭（最新）を手前に重ねるため、後ろから描く。
          for (var i = shown.length - 1; i >= 0; i--)
            Positioned(
              left: step * i,
              child: _StackedAvatar(
                user: shown[i],
                reaction: reactions?[i],
                emojis: emojis,
                size: size,
              ),
            ),
          if (overflow > 0)
            Positioned(
              left: step * shown.length,
              child: _OverflowCount(count: overflow, size: size),
            ),
        ],
      ),
    );
  }
}

class _StackedAvatar extends StatelessWidget {
  const _StackedAvatar({
    required this.user,
    required this.reaction,
    required this.emojis,
    required this.size,
  });

  final User user;
  final String? reaction;
  final Map<String, String> emojis;
  final double size;

  @override
  Widget build(BuildContext context) {
    final ringColor = Theme.of(context).colorScheme.surface;
    final avatar = Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: ringColor, width: 1.5),
      ),
      child: DecoratedAvatar(
        avatarUrl: user.avatarUrl,
        size: size,
        isCat: user.isCat,
        avatarBlurhash: user.avatarBlurhash,
      ),
    );

    final reaction = this.reaction;
    Widget content = avatar;
    if (reaction != null) {
      const badgeSize = 16.0;
      final url = _lookupGroupedEmojiUrl(emojis, reaction);
      content = SizedBox(
        width: size,
        height: size,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            avatar,
            Positioned(
              right: -2,
              bottom: -2,
              child: Container(
                width: badgeSize,
                height: badgeSize,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  shape: BoxShape.circle,
                  border: Border.all(color: ringColor, width: 1),
                ),
                child: url == null
                    ? FittedBox(child: Text(reaction))
                    : CustomEmojiImage(
                        url: url,
                        size: badgeSize - 4,
                        errorFallback: FittedBox(child: Text(reaction)),
                      ),
              ),
            ),
          ],
        ),
      );
    }

    // 重ねているので、タップ領域を 40dp に広げると隣と被る。
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => openUserProfile(context, user.id, initialUser: user),
      child: content,
    );
  }
}

class _OverflowCount extends StatelessWidget {
  const _OverflowCount({required this.count, required this.size});

  final int count;
  final double size;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        shape: BoxShape.circle,
        border: Border.all(color: colorScheme.surface, width: 1.5),
      ),
      child: FittedBox(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: Text(
            '+$count',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}

class _FollowRequestActions extends ConsumerStatefulWidget {
  const _FollowRequestActions({required this.userId});

  final String userId;

  @override
  ConsumerState<_FollowRequestActions> createState() =>
      _FollowRequestActionsState();
}

class _FollowRequestActionsState extends ConsumerState<_FollowRequestActions> {
  bool _busy = false;
  String? _result;

  Future<void> _answer({required bool accept}) async {
    final repo = ref.read(notificationRepositoryProvider);
    if (repo == null) return;
    setState(() => _busy = true);
    try {
      if (accept) {
        await repo.acceptFollowRequest(widget.userId);
      } else {
        await repo.rejectFollowRequest(widget.userId);
      }
      if (mounted) setState(() => _result = accept ? '承認しました' : '拒否しました');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(resolveErrorMessage(e))));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final result = _result;
    if (result != null) {
      return Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Text(result, style: Theme.of(context).textTheme.bodySmall),
      );
    }
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        spacing: 8,
        children: [
          FilledButton.tonal(
            onPressed: _busy ? null : () => _answer(accept: true),
            child: const Text('承認'),
          ),
          OutlinedButton(
            onPressed: _busy ? null : () => _answer(accept: false),
            child: const Text('拒否'),
          ),
        ],
      ),
    );
  }
}
