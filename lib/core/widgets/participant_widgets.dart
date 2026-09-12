import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:classpay/providers/notification_provider.dart';

class ParticipantBottomNavigation extends StatelessWidget {
  const ParticipantBottomNavigation({
    required this.currentIndex,
    required this.onTap,
    super.key,
  });
  final int currentIndex;
  final ValueChanged<int> onTap;
  @override
  Widget build(BuildContext context) => NavigationBar(
    selectedIndex: currentIndex,
    onDestinationSelected: onTap,
    destinations: const [
      NavigationDestination(
        icon: Icon(Icons.home_outlined),
        selectedIcon: Icon(Icons.home),
        label: 'Home',
      ),
      NavigationDestination(
        icon: Icon(Icons.receipt_long_outlined),
        selectedIcon: Icon(Icons.receipt_long),
        label: 'Payments',
      ),
      NavigationDestination(
        icon: Icon(Icons.person_outline),
        selectedIcon: Icon(Icons.person),
        label: 'Account',
      ),
    ],
  );
}

class NotificationBadge extends ConsumerWidget {
  const NotificationBadge({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(unreadNotificationCountProvider);
    return count.when(
      loading: () => const Icon(Icons.notifications_none),
      error: (_, __) => const Icon(Icons.notifications_none),
      data: (value) => Badge(
        isLabelVisible: value > 0,
        label: Text('$value'),
        child: const Icon(Icons.notifications_none),
      ),
    );
  }
}

class ParticipantAppBar extends StatelessWidget implements PreferredSizeWidget {
  const ParticipantAppBar({
    required this.title,
    required this.onNotificationsPressed,
    super.key,
  });
  final String title;
  final VoidCallback? onNotificationsPressed;
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
  @override
  Widget build(BuildContext context) => AppBar(
    title: Text(title),
    actions: [
      IconButton(
        tooltip: 'Notifications',
        onPressed: onNotificationsPressed,
        icon: const NotificationBadge(),
      ),
    ],
  );
}

class ClassCard extends StatelessWidget {
  const ClassCard({
    required this.name,
    required this.onTap,
    super.key,
    this.organization,
    this.teacher,
    this.schedule,
    this.participantStatus,
  });
  final String name;
  final String? organization;
  final String? teacher;
  final String? schedule;
  final String? participantStatus;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) => Card(
    child: ListTile(
      onTap: onTap,
      leading: const Icon(Icons.class_outlined),
      title: Text(name),
      subtitle: Text(
        [
          organization,
          teacher,
          schedule,
        ].whereType<String>().where((item) => item.isNotEmpty).join('\n'),
      ),
      isThreeLine: true,
      trailing: participantStatus == null
          ? null
          : Chip(label: Text(participantStatus!)),
    ),
  );
}

class PaymentSummaryCard extends StatelessWidget {
  const PaymentSummaryCard({
    required this.title,
    required this.message,
    super.key,
    this.onTap,
  });
  final String title;
  final String message;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) => Card(
    child: ListTile(
      onTap: onTap,
      leading: const Icon(Icons.account_balance_wallet_outlined),
      title: Text(title),
      subtitle: Text(message),
      trailing: onTap == null ? null : const Icon(Icons.chevron_right),
    ),
  );
}
