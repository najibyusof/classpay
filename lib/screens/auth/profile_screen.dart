import 'package:classpay/providers/session_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(sessionManagerProvider).state.user;
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        children: [
          ListTile(
            title: Text(user?.name ?? ''),
            subtitle: Text(user?.email ?? user?.phone ?? ''),
          ),
          ListTile(
            title: const Text('Change password'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/change-password'),
          ),
          ListTile(
            title: const Text('Sign out'),
            onTap: () async => ref.read(sessionManagerProvider).logout(),
          ),
        ],
      ),
    );
  }
}
