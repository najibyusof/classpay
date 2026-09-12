import 'package:classpay/providers/session_manager.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthenticatedAreaScreen extends ConsumerWidget {
  const AuthenticatedAreaScreen({required this.title, super.key});
  final String title;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionManagerProvider);
    final user = session.state.user;
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) async {
              if (value == 'logout') {
                await session.logout();
              } else if (context.mounted) {
                context.push(value);
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: '/set-password',
                child: Text('Set password'),
              ),
              PopupMenuItem(
                value: '/change-password',
                child: Text('Change password'),
              ),
              PopupMenuItem(value: 'logout', child: Text('Sign out')),
            ],
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'Signed in as ${user?.name ?? ''}.',
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
      ),
    );
  }
}
