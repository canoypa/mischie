import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mischie/core/emoji/emoji_providers.dart';
import 'package:mischie/core/error/error_handler.dart';
import 'package:mischie/features/profile/data/profile_repository.dart';
import 'package:mischie/features/profile/domain/profile_notifier.dart';
import 'package:mischie/features/profile/presentation/profile_header.dart';
import 'package:mischie/features/timeline/domain/note.dart';
import 'package:mischie/features/timeline/domain/note_store.dart';
import 'package:mischie/features/timeline/domain/user.dart';
import 'package:mischie/features/timeline/presentation/note_card.dart';

/// 自分のタブと他人の画面で AppBar が違うので、Scaffold は呼び出し側が持つ。
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
  bool _hasMore = true;

  UserNotesFilter _filter = UserNotesFilter.notes;

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
      _hasMore = true;
    });
    try {
      final filter = _filter;
      final notes = await repo.fetchUserNotes(widget.userId, filter: filter);
      // 取得中に絞り込みを変えていたら、古い結果で上書きしない
      if (filter != _filter) return;
      if (!mounted) return;
      ref.read(noteOverridesProvider.notifier).evictFetched(notes);
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
      final filter = _filter;
      final notes = await repo.fetchUserNotes(
        widget.userId,
        untilId: _notes.last.id,
        filter: filter,
      );
      if (!mounted) return;
      if (filter != _filter) {
        setState(() => _loadingMore = false);
        return;
      }
      ref.read(noteOverridesProvider.notifier).evictFetched(notes);
      setState(() {
        _notes.addAll(notes);
        _hasMore = notes.isNotEmpty;
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
        _hasMore &&
        _notes.isNotEmpty) {
      _loadMore();
    }
  }

  Future<void> _refresh() async {
    ref.invalidate(userDetailProvider(widget.userId));
    await Future.wait([
      // ヘッダーの失敗はヘッダー自身が表示するので、ここでは待つだけ
      ref
          .read(userDetailProvider(widget.userId).future)
          .then<void>((_) {}, onError: (_) {}),
      _fetchInitial(),
    ]);
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
      child: RefreshIndicator(
        onRefresh: _refresh,
        child: CustomScrollView(
          controller: _scrollController,
          // 投稿が少なくても引っ張って更新できるようにする
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: ProfileHeader(
                detailAsync: detailAsync,
                initialUser: initialUser,
                serverEmojis: serverEmojis,
                userId: widget.userId,
              ),
            ),
            if ((detailAsync.value?.pinnedNotes ?? const []).isNotEmpty)
              SliverList(
                delegate: SliverChildListDelegate([
                  const _SectionLabel(icon: Icons.push_pin, label: 'ピン留め'),
                  for (final note in detailAsync.value!.pinnedNotes)
                    RepaintBoundary(
                      key: ValueKey('pinned-${note.id}'),
                      child: NoteCard(note: note, serverEmojis: serverEmojis),
                    ),
                  const Divider(height: 24),
                ]),
              ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: SegmentedButton<UserNotesFilter>(
                  segments: [
                    for (final filter in UserNotesFilter.values)
                      ButtonSegment(value: filter, label: Text(filter.label)),
                  ],
                  selected: {_filter},
                  showSelectedIcon: false,
                  onSelectionChanged: (selected) {
                    setState(() {
                      _filter = selected.first;
                      _notes.clear();
                    });
                    _fetchInitial();
                  },
                ),
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
            else if (_notes.isEmpty)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(child: Text('ノートはありません')),
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
      ),
    );
  }
}

/// initialUser を渡すと、詳細の取得中も名前とアイコンを出せる。
void openUserProfile(BuildContext context, String userId, {User? initialUser}) {
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) =>
          UserProfileScreen(userId: userId, initialUser: initialUser),
    ),
  );
}

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
        actions: [if (detail != null) UserMenuButton(detail: detail)],
      ),
      body: UserProfileView(userId: userId, initialUser: initialUser),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.onSurfaceVariant;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Row(
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}
