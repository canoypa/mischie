import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mischie/core/error/error_handler.dart';
import 'package:mischie/features/profile/domain/profile_notifier.dart';
import 'package:mischie/features/profile/presentation/user_profile_screen.dart';

/// 自分のプロフィールタブ。表示は他人のプロフィールと同じものを使う。
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref
        .watch(profileNotifierProvider)
        .when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(resolveErrorMessage(e)),
                const SizedBox(height: 8),
                FilledButton(
                  onPressed: () =>
                      ref.read(profileNotifierProvider.notifier).refresh(),
                  child: const Text('再試行'),
                ),
              ],
            ),
          ),
          data: (user) => user == null
              ? const SizedBox.shrink()
              : UserProfileView(userId: user.id, initialUser: user),
        );
  }
}
