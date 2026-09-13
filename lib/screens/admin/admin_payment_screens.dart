import 'package:classpay/core/errors/api_error_message.dart';
import 'package:classpay/core/utils/currency_formatter.dart';
import 'package:classpay/core/widgets/async_states.dart';
import 'package:classpay/core/widgets/dashboard_back_button.dart';
import 'package:classpay/models/participant_payment.dart';
import 'package:classpay/providers/admin_payment_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AdminPaymentsScreen extends ConsumerWidget {
  const AdminPaymentsScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const filter = AdminPaymentFilter();
    final data = ref.watch(adminPaymentsProvider(filter));
    return Scaffold(
      appBar: AppBar(
        leading: const DashboardBackButton(),
        title: const Text('Payments'),
      ),
      body: data.when(
        loading: () => const AppLoadingIndicator(),
        error: (error, stack) => AppErrorState(message: apiErrorMessage(error)),
        data: (page) => page.items.isEmpty
            ? const AppEmptyState(
                title: 'No payments',
                message: 'No payments were returned.',
              )
            : ListView(
                children: [
                  for (final payment in page.items)
                    ListTile(
                      title: Text(payment.referenceNumber ?? 'Payment'),
                      subtitle: Text(
                        '${payment.className ?? '-'} | ${formatMyCurrency(payment.totalAmount ?? 0)}',
                      ),
                      trailing: Chip(label: Text(payment.status)),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              AdminPaymentDetailScreen(payment: payment),
                        ),
                      ),
                    ),
                ],
              ),
      ),
    );
  }
}

class AdminPaymentDetailScreen extends StatelessWidget {
  const AdminPaymentDetailScreen({required this.payment, super.key});
  final ParticipantPayment payment;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      leading: const DashboardBackButton(),
      title: const Text('Payment detail'),
    ),
    body: ListView(
      children: [
        ListTile(
          title: const Text('Reference'),
          subtitle: Text(payment.referenceNumber ?? '-'),
        ),
        ListTile(
          title: const Text('Total amount'),
          subtitle: Text(formatMyCurrency(payment.totalAmount ?? 0)),
        ),
        ListTile(title: const Text('Status'), subtitle: Text(payment.status)),
        ListTile(
          title: const Text('Payment method'),
          subtitle: Text(payment.paymentMethod ?? '-'),
        ),
      ],
    ),
  );
}

class PaymentSummaryReportScreen extends ConsumerWidget {
  const PaymentSummaryReportScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const filter = AdminPaymentFilter();
    return Scaffold(
      appBar: AppBar(
        leading: const DashboardBackButton(),
        title: const Text('Payment summary'),
      ),
      body: ref
          .watch(paymentSummaryReportProvider(filter))
          .when(
            loading: () => const AppLoadingIndicator(),
            error: (error, stack) =>
                AppErrorState(message: apiErrorMessage(error)),
            data: (r) => ListView(
              children: [
                ListTile(
                  title: const Text('Total payments'),
                  trailing: Text('${r.totalPayments}'),
                ),
                ListTile(
                  title: const Text('Successful payments'),
                  trailing: Text('${r.successfulPayments}'),
                ),
                ListTile(
                  title: const Text('Pending payments'),
                  trailing: Text('${r.pendingPayments}'),
                ),
                ListTile(
                  title: const Text('Failed payments'),
                  trailing: Text('${r.failedPayments}'),
                ),
                ListTile(
                  title: const Text('Refunded payments'),
                  trailing: Text('${r.refundedPayments}'),
                ),
                ListTile(
                  title: const Text('Total collected'),
                  trailing: Text(formatMyCurrency(r.totalCollected)),
                ),
                ListTile(
                  title: const Text('Total outstanding'),
                  trailing: Text(formatMyCurrency(r.totalOutstanding)),
                ),
                ListTile(
                  title: const Text('Total overdue'),
                  trailing: Text(formatMyCurrency(r.totalOverdue)),
                ),
              ],
            ),
          ),
    );
  }
}

class OutstandingReportScreen extends ConsumerWidget {
  const OutstandingReportScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const filter = AdminPaymentFilter();
    return Scaffold(
      appBar: AppBar(
        leading: const DashboardBackButton(),
        title: const Text('Outstanding report'),
      ),
      body: ref
          .watch(outstandingReportProvider(filter))
          .when(
            loading: () => const AppLoadingIndicator(),
            error: (error, stack) =>
                AppErrorState(message: apiErrorMessage(error)),
            data: (page) => ListView(
              children: [
                for (final r in page.items)
                  ListTile(
                    title: Text('${r.organization} | ${r.className}'),
                    subtitle: Text(
                      '${r.participant} | ${r.period}\n${formatMyCurrency(r.outstandingAmount)}',
                    ),
                    trailing: Chip(label: Text(r.status)),
                    isThreeLine: true,
                  ),
              ],
            ),
          ),
    );
  }
}

class OverdueReportScreen extends ConsumerWidget {
  const OverdueReportScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const filter = AdminPaymentFilter();
    return Scaffold(
      appBar: AppBar(
        leading: const DashboardBackButton(),
        title: const Text('Overdue report'),
      ),
      body: ref
          .watch(overdueReportProvider(filter))
          .when(
            loading: () => const AppLoadingIndicator(),
            error: (error, stack) =>
                AppErrorState(message: apiErrorMessage(error)),
            data: (page) => ListView(
              children: [
                for (final r in page.items)
                  ListTile(
                    title: Text('${r.organization} | ${r.className}'),
                    subtitle: Text(
                      '${r.participant} | ${formatMyCurrency(r.outstandingAmount)}',
                    ),
                    trailing: Text('${r.daysOverdue ?? 0} days'),
                    isThreeLine: true,
                  ),
              ],
            ),
          ),
    );
  }
}
