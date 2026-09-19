import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mischie/core/emoji/emoji_providers.dart';
import 'package:mischie/core/emoji/layered_emojis.dart';
import 'package:mischie/core/error/error_handler.dart';
import 'package:mischie/core/widgets/custom_emoji_image.dart';
import 'package:mischie/core/widgets/decorated_avatar.dart';
import 'package:mischie/core/widgets/mfm_text.dart';
import 'package:mischie/features/profile/presentation/user_profile_screen.dart';
import 'package:mischie/features/notification/domain/notification_item.dart';
import 'package:mischie/features/notification/domain/notification_label.dart';
import 'package:mischie/features/notification/domain/notification_notifier.dart';
import 'package:mischie/features/timeline/domain/user.dart';
import 'package:mischie/features/timeline/presentation/note_detail_screen.dart';
import 'package:timeago/timeago.dart' as timeago;

/// `:name:` / `:name@server.tld:` 形式のリアクションキーから絵文字名を取る。
///
/// note/reactions.dart にも同じ判定があるが、通知一覧はこちらの
/// ファイル群だけで完結させたいので、小さな正規表現ひとつをここでも持つ。
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

class NotificationScreen extends ConsumerStatefulWidget {
  const NotificationScreen({super.key});

  @override
  ConsumerState<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends ConsumerState<NotificationScreen> {
  bool _loadingMore = false;

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
      error: (e, _) => Center(
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
      data: (items) => RefreshIndicator(
        onRefresh: () =>
            ref.read(notificationNotifierProvider.notifier).refresh(),
        child: items.isEmpty
            ? const Center(child: Text('通知はありません'))
            : NotificationListener<ScrollUpdateNotification>(
                onNotification: (n) {
                  final pos = n.metrics;
                  if (pos.pixels >= pos.maxScrollExtent - 200) _loadMore();
                  return false;
                },
                child: ListView.builder(
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

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({required this.item, required this.serverEmojis});

  final NotificationItem item;
  final Map<String, String> serverEmojis;

  /// まとめ通知に載っている相手。新しい順。
  List<User> get _groupActors => switch (item.type) {
    'reaction:grouped' =>
      (item.reactions ?? const []).map((r) => r.user).toList(),
    'renote:grouped' => item.users ?? const [],
    _ => const [],
  };

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final label = notificationLabel(item.type);
    final isGrouped =
        item.type == 'reaction:grouped' || item.type == 'renote:grouped';
    final groupActors = _groupActors;
    // まとめ通知には単発の user が無い（サーバーが送ってこない）ので、
    // 先頭（最新）の相手をリーディングアイコンに立てる。
    final leadUser = isGrouped
        ? (groupActors.isNotEmpty ? groupActors.first : null)
        : item.user;
    // 種類の区別はアイコンで付ける。色は Material 3 のカラーロールから
    // 取り、seed から導かれた調和の中に収める。
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
      // 相手のいない通知（投票の終了・実績など）では名前を出さない。
      // 付けると「Cano が 投票が終了しました」のように文が壊れる。
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
          if (item.note?.text != null)
            MfmText(
              item.note!.text!,
              emojis: noteEmojis,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          if (!isGrouped && item.reaction != null)
            MfmText(
              item.reaction!,
              emojis: noteEmojis,
              style: Theme.of(context).textTheme.bodySmall,
            ),
        ],
      ),
      trailing: Text(time, style: Theme.of(context).textTheme.bodySmall),
      // 通知は「開けて当然」なので、ノートがあればノートへ、
      // なければ相手のプロフィールへ飛ぶ
      onTap: () {
        final note = item.note;
        if (note != null) {
          openNoteDetail(context, note);
          return;
        }
        if (leadUser != null) {
          openUserProfile(context, leadUser.id, initialUser: leadUser);
        }
      },
    );
  }
}

/// まとめ通知の見出し。「Cano ほか 3 人がリアクション」のように、単発行
/// （「Cano @cano がリアクション」）と揃えて「さん」は付けない。
/// 最新の相手の名前だけを個別に出し、残りは人数でまとめる。
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

/// まとめ通知の本文側。重ねた相手のアイコンを最大 6 件並べる。
/// リアクションのまとめは、誰が何のリアクションを付けたかをその人の
/// アイコンにバッジで乗せる（Misskey Web と同じ見せ方）。
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

/// 重ねて並べた相手のアイコン。最大 6 人までに残りは "+N" でまとめ、
/// アイコンをタップすればその人のプロフィールへ飛ぶ。
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

  // 一覧の行に収まりつつ、誰が絡んだか見て取れる大きさ・数。
  static const _size = 28.0;
  static const _max = 6;

  @override
  Widget build(BuildContext context) {
    final shown = users.take(_max).toList();
    if (shown.isEmpty) return const SizedBox.shrink();
    final overflow = users.length - shown.length;
    const size = _size;
    // 3 分の 1 ほど重ねる。
    final step = size * 2 / 3;
    final slots = shown.length + (overflow > 0 ? 1 : 0);
    final width = size + step * (slots - 1);

    return SizedBox(
      width: width,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // 先頭（最新）を一番手前・左に置きたいので、後ろのアイコンから
          // 先に描く。
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

/// スタック 1 個ぶん。アイコン本体と、あれば右下のリアクションバッジ。
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

    // タップ領域はアイコン本体と同じ大きさ（重ねているため、隣と揃えて
    // 40dp を確保すると隣同士の判定が被って押し分けられなくなる）。
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => openUserProfile(context, user.id, initialUser: user),
      child: content,
    );
  }
}

/// スタックに乗らなかった残り人数。"+3" のように出す。
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
