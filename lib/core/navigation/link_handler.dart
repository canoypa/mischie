import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mischie/core/error/error_handler.dart';
import 'package:mischie/features/auth/domain/auth_notifier.dart';
import 'package:mischie/features/profile/domain/profile_notifier.dart';
import 'package:mischie/features/profile/presentation/user_profile_screen.dart';
import 'package:mischie/features/timeline/domain/note_actions.dart';
import 'package:mischie/features/timeline/presentation/note_detail_screen.dart';
import 'package:url_launcher/url_launcher.dart';

/// アプリに無い画面は、行き止まりにせずサーバーの Web 版で開く。
Future<void> openOnServer(WidgetRef ref, String path) async {
  final host = ref.read(currentHostProvider);
  if (host == null) return;
  await openExternal('https://$host$path');
}

Future<void> openExternal(String url) async {
  final uri = Uri.tryParse(url);
  if (uri == null) return;
  await launchUrl(uri, mode: LaunchMode.externalApplication);
}

Future<void> openLink(BuildContext context, WidgetRef ref, String url) async {
  final uri = Uri.tryParse(url);
  final host = ref.read(currentHostProvider);
  if (uri == null || host == null || uri.host != host.toLowerCase()) {
    await openExternal(url);
    return;
  }

  final segments = uri.pathSegments;
  if (segments.length == 2 && segments.first == 'notes') {
    await openNoteById(context, ref, segments[1]);
    return;
  }
  if (segments.length == 1 && segments.first.startsWith('@')) {
    final acct = segments.first.substring(1).split('@');
    await openUserByAcct(
      context,
      ref,
      username: acct.first,
      host: acct.length > 1 ? acct[1] : null,
    );
    return;
  }
  await openExternal(url);
}

Future<void> openUserByAcct(
  BuildContext context,
  WidgetRef ref, {
  required String username,
  String? host,
}) async {
  final repo = ref.read(profileRepositoryProvider);
  if (repo == null) return;
  try {
    final user = await repo.fetchUserByAcct(username, host: host);
    if (!context.mounted) return;
    openUserProfile(context, user.id);
  } catch (e) {
    if (!context.mounted) return;
    _notify(context, resolveErrorMessage(e));
  }
}

Future<void> openNoteById(
  BuildContext context,
  WidgetRef ref,
  String noteId,
) async {
  final repo = ref.read(noteRepositoryProvider);
  if (repo == null) return;
  try {
    final note = await repo.show(noteId);
    if (!context.mounted) return;
    openNoteDetail(context, note);
  } catch (e) {
    if (!context.mounted) return;
    _notify(context, resolveErrorMessage(e));
  }
}

void _notify(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}
