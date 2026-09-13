import 'package:classpay/providers/session_manager.dart';
import 'package:classpay/routes/auth_guard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class DashboardBackButton extends ConsumerWidget {
  const DashboardBackButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(sessionManagerProvider).state.user;
    if (user == null) return const SizedBox.shrink();

    return IconButton(
      tooltip: 'Back to dashboard',
      icon: const Icon(Icons.arrow_back),
      onPressed: () => context.go(AuthGuard.homeForUser(user)),
    );
  }
}
