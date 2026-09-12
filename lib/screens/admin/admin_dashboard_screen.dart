import 'package:classpay/core/widgets/async_states.dart';
import 'package:classpay/core/widgets/dashboard_cards.dart';
import 'package:classpay/core/widgets/participant_widgets.dart';
import 'package:classpay/core/widgets/role_navigation_drawer.dart';
import 'package:classpay/models/dashboard_model.dart';
import 'package:classpay/models/auth_user.dart';
import 'package:classpay/providers/dashboard_provider.dart';
import 'package:classpay/providers/session_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class AdminDashboardScreen extends ConsumerStatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  ConsumerState<AdminDashboardScreen> createState() =>
      _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends ConsumerState<AdminDashboardScreen> {
  DashboardFilter _filter = const DashboardFilter();

  Future<void> _selectDateRange() async {
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange: _filter.startDate == null || _filter.endDate == null
          ? null
          : DateTimeRange(start: _filter.startDate!, end: _filter.endDate!),
    );
    if (range != null)
      setState(
        () => _filter = DashboardFilter(
          startDate: range.start,
          endDate: range.end,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final dashboard = ref.watch(adminDashboardProvider(_filter));
    return Scaffold(
      drawer: const RoleNavigationDrawer(userType: UserType.admin),
      appBar: AppBar(
        title: const Text('ClassPay'),
        actions: [
          IconButton(
            tooltip: 'Organizations',
            onPressed: () => context.push('/admin/organizations'),
            icon: const Icon(Icons.account_balance_outlined),
          ),
          IconButton(
            tooltip: 'Notifications',
            onPressed: () => context.push('/notifications'),
            icon: const NotificationBadge(),
          ),
          PopupMenuButton<String>(
            tooltip: 'Account menu',
            onSelected: (value) async {
              if (value == 'logout')
                await ref.read(sessionManagerProvider).logout();
              if (value == 'change-password' && context.mounted)
                context.push('/change-password');
            },
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: 'change-password',
                child: Text('Change password'),
              ),
              PopupMenuItem(value: 'logout', child: Text('Sign out')),
            ],
          ),
        ],
      ),
      body: dashboard.when(
        loading: () =>
            const AppLoadingIndicator(message: 'Loading dashboard...'),
        error: (error, stackTrace) => AppErrorState(
          message: '$error',
          onRetry: () => ref.invalidate(adminDashboardProvider(_filter)),
        ),
        data: (data) => RefreshIndicator(
          onRefresh: () async =>
              ref.invalidate(adminDashboardProvider(_filter)),
          child: _DashboardContent(
            data: data,
            filter: _filter,
            onSelectDateRange: _selectDateRange,
            onClearDateRange: () =>
                setState(() => _filter = const DashboardFilter()),
          ),
        ),
      ),
    );
  }
}

class _DashboardContent extends StatelessWidget {
  const _DashboardContent({
    required this.data,
    required this.filter,
    required this.onSelectDateRange,
    required this.onClearDateRange,
  });
  final DashboardModel data;
  final DashboardFilter filter;
  final VoidCallback onSelectDateRange;
  final VoidCallback onClearDateRange;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final columns = constraints.maxWidth >= 900
          ? 4
          : constraints.maxWidth >= 600
          ? 2
          : 1;
      return ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Admin overview',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
              IconButton(
                tooltip: 'Select date range',
                onPressed: onSelectDateRange,
                icon: const Icon(Icons.date_range_outlined),
              ),
              if (filter.startDate != null)
                IconButton(
                  tooltip: 'Clear date range',
                  onPressed: onClearDateRange,
                  icon: const Icon(Icons.clear),
                ),
            ],
          ),
          if (filter.startDate != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text(
                '${MaterialLocalizations.of(context).formatShortDate(filter.startDate!)} - ${MaterialLocalizations.of(context).formatShortDate(filter.endDate!)}',
              ),
            ),
          _Grid(
            columns: columns,
            children: [
              SummaryCard(
                label: 'Organizations',
                value: data.organizations,
                icon: Icons.account_balance_outlined,
              ),
              SummaryCard(
                label: 'Active classes',
                value: data.activeClasses,
                icon: Icons.class_outlined,
              ),
              SummaryCard(
                label: 'Students',
                value: data.students,
                icon: Icons.school_outlined,
              ),
              SummaryCard(
                label: 'Sponsors',
                value: data.sponsors,
                icon: Icons.volunteer_activism_outlined,
              ),
            ],
          ),
          _Section(
            title: 'Financial summary',
            child: _Grid(
              columns: columns > 2 ? 3 : columns,
              children: [
                FinancialCard(
                  label: 'Collected',
                  amount: data.financial.collected,
                  color: Colors.green.shade700,
                ),
                FinancialCard(
                  label: 'Outstanding',
                  amount: data.financial.outstanding,
                  color: Colors.orange.shade800,
                ),
                FinancialCard(
                  label: 'Overdue',
                  amount: data.financial.overdue,
                  color: Theme.of(context).colorScheme.error,
                ),
              ],
            ),
          ),
          _Section(
            title: 'Payment schedules',
            child: _Grid(
              columns: columns > 2 ? 5 : 2,
              children: [
                PaymentStatusCard(
                  label: 'Total',
                  value: data.paymentSchedules.total,
                ),
                PaymentStatusCard(
                  label: 'Upcoming',
                  value: data.paymentSchedules.upcoming,
                ),
                PaymentStatusCard(
                  label: 'Pending',
                  value: data.paymentSchedules.pending,
                ),
                PaymentStatusCard(
                  label: 'Overdue',
                  value: data.paymentSchedules.overdue,
                  color: Theme.of(context).colorScheme.error,
                ),
                PaymentStatusCard(
                  label: 'Paid',
                  value: data.paymentSchedules.paid,
                  color: Colors.green.shade700,
                ),
              ],
            ),
          ),
          _Section(
            title: 'Payments',
            child: _Grid(
              columns: columns > 2 ? 3 : 2,
              children: [
                PaymentStatusCard(label: 'Total', value: data.payments.total),
                PaymentStatusCard(
                  label: 'Paid',
                  value: data.payments.paid,
                  color: Colors.green.shade700,
                ),
                PaymentStatusCard(
                  label: 'Pending',
                  value: data.payments.pending,
                ),
                PaymentStatusCard(
                  label: 'Overdue',
                  value: data.payments.overdue,
                  color: Theme.of(context).colorScheme.error,
                ),
                PaymentStatusCard(
                  label: 'Failed',
                  value: data.payments.failed,
                  color: Theme.of(context).colorScheme.error,
                ),
                PaymentStatusCard(
                  label: 'Refunded',
                  value: data.payments.refunded,
                ),
              ],
            ),
          ),
          _Section(
            title: 'Recent payments',
            child: data.recentPayments.isEmpty
                ? const SizedBox(
                    height: 160,
                    child: AppEmptyState(
                      title: 'No recent payments',
                      message:
                          'Payments matching this date range will appear here.',
                    ),
                  )
                : Card(
                    child: Column(
                      children: [
                        for (final payment in data.recentPayments)
                          RecentPaymentTile(payment: payment),
                      ],
                    ),
                  ),
          ),
        ],
      );
    },
  );
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});
  final String title;
  final Widget child;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 28),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        child,
      ],
    ),
  );
}

class _Grid extends StatelessWidget {
  const _Grid({required this.columns, required this.children});
  final int columns;
  final List<Widget> children;
  @override
  Widget build(BuildContext context) => GridView.count(
    crossAxisCount: columns,
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    mainAxisSpacing: 12,
    crossAxisSpacing: 12,
    childAspectRatio: columns == 1 ? 3.5 : 1.8,
    children: children,
  );
}
