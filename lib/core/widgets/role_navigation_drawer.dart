import 'package:classpay/models/auth_user.dart';
import 'package:classpay/core/widgets/app_brand.dart';
import 'package:classpay/core/widgets/participant_widgets.dart';
import 'package:classpay/providers/session_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class RoleNavigationDrawer extends ConsumerWidget {
  const RoleNavigationDrawer({required this.userType, super.key});
  final UserType userType;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = switch (userType) {
      UserType.admin => const [
        ('Dashboard', '/admin', Icons.dashboard_outlined),
        (
          'Organizations',
          '/admin/organizations',
          Icons.account_balance_outlined,
        ),
        ('Classes', '/admin/organizations', Icons.class_outlined),
        ('Payments', '/admin/payments', Icons.payments_outlined),
        (
          'Reports',
          '/admin/reports/payment-summary',
          Icons.assessment_outlined,
        ),
      ],
      UserType.student => const [
        ('Home', '/student', Icons.home_outlined),
        ('Classes', '/student', Icons.class_outlined),
        ('Payments', '/student/payment-schedules', Icons.payments_outlined),
      ],
      UserType.sponsor => const [
        ('Home', '/sponsor', Icons.home_outlined),
        ('Classes', '/sponsor', Icons.class_outlined),
        ('Payments', '/sponsor/payment-schedules', Icons.payments_outlined),
      ],
      UserType.unknown => const <(String, String, IconData)>[],
    };
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 12),
              child: Align(
                alignment: Alignment.centerLeft,
                child: AppBrand(logoSize: 40),
              ),
            ),
            for (final item in items)
              ListTile(
                leading: Icon(item.$3),
                title: Text(item.$1),
                onTap: () {
                  Navigator.pop(context);
                  context.go(item.$2);
                },
              ),
            const Divider(),
            ListTile(
              leading: const NotificationBadge(),
              title: const Text('Notifications'),
              onTap: () {
                Navigator.pop(context);
                context.go('/notifications');
              },
            ),
            ListTile(
              leading: const Icon(Icons.person_outline),
              title: const Text('Profile'),
              onTap: () {
                Navigator.pop(context);
                context.go('/profile');
              },
            ),
            const Spacer(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Sign out'),
              onTap: () async {
                await ref.read(sessionManagerProvider).logout();
              },
            ),
          ],
        ),
      ),
    );
  }
}
