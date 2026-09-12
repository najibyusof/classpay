import 'package:classpay/core/widgets/async_states.dart';
import 'package:classpay/core/widgets/participant_widgets.dart';
import 'package:classpay/core/widgets/role_navigation_drawer.dart';
import 'package:classpay/models/auth_user.dart';
import 'package:classpay/providers/session_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class StudentHomeScreen extends ConsumerWidget {
  const StudentHomeScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(sessionManagerProvider).state.user;
    return Scaffold(
      drawer: const RoleNavigationDrawer(userType: UserType.student),
      appBar: ParticipantAppBar(
        title: 'ClassPay',
        onNotificationsPressed: () =>
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Notifications are not available yet.'),
              ),
            ),
      ),
      bottomNavigationBar: ParticipantBottomNavigation(
        currentIndex: 0,
        onTap: (_) {},
      ),
      body: RefreshIndicator(
        onRefresh: () async {},
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'Hello, ${user?.name ?? ''}',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 20),
            PaymentSummaryCard(
              title: 'Current payment',
              message: 'View your payment schedules and payment history.',
              onTap: () => context.push('/student/payment-schedules'),
            ),
            const SizedBox(height: 24),
            Text('Your classes', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            const SizedBox(
              height: 180,
              child: AppEmptyState(
                title: 'No classes to display',
                message: 'Classes available to your account will appear here.',
                icon: Icons.class_outlined,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
