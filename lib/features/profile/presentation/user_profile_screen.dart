import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mischie/core/emoji/emoji_providers.dart';
import 'package:mischie/core/error/error_handler.dart';
import 'package:mischie/features/profile/domain/profile_notifier.dart';
import 'package:mischie/features/profile/presentation/profile_header.dart';
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
            child: ProfileHeader(
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
        actions: [if (detail != null) UserMenuButton(detail: detail)],
      ),
      body: UserProfileView(userId: userId, initialUser: initialUser),
    );
  }
}
