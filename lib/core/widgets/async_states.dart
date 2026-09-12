import 'package:flutter/material.dart';

class AppLoadingIndicator extends StatelessWidget {
  const AppLoadingIndicator({super.key, this.message});
  final String? message;

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const CircularProgressIndicator(),
        if (message != null) ...[const SizedBox(height: 12), Text(message!)],
      ],
    ),
  );
}

class AppEmptyState extends StatelessWidget {
  const AppEmptyState({
    required this.title,
    required this.message,
    super.key,
    this.icon = Icons.inbox_outlined,
  });
  final String title;
  final String message;
  final IconData icon;

  @override
  Widget build(BuildContext context) =>
      _StateBody(icon: icon, title: title, message: message);
}

class AppErrorState extends StatelessWidget {
  const AppErrorState({required this.message, super.key, this.onRetry});
  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) => _StateBody(
    icon: Icons.error_outline,
    title: 'Unable to load',
    message: message,
    action: onRetry == null
        ? null
        : OutlinedButton(onPressed: onRetry, child: const Text('Try again')),
  );
}

class _StateBody extends StatelessWidget {
  const _StateBody({
    required this.icon,
    required this.title,
    required this.message,
    this.action,
  });
  final IconData icon;
  final String title;
  final String message;
  final Widget? action;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 48, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 16),
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(message, textAlign: TextAlign.center),
          if (action != null) ...[const SizedBox(height: 16), action!],
        ],
      ),
    ),
  );
}
