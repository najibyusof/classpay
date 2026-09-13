import 'package:classpay/core/errors/api_error_message.dart';
import 'package:classpay/core/utils/currency_formatter.dart';
import 'package:classpay/core/widgets/async_states.dart';
import 'package:classpay/core/widgets/dashboard_back_button.dart';
import 'package:classpay/models/participant_payment.dart';
import 'package:classpay/providers/participant_payment_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PaymentHistoryScreen extends ConsumerStatefulWidget {
  const PaymentHistoryScreen({required this.role, super.key});
  final ParticipantRole role;
  @override
  ConsumerState<PaymentHistoryScreen> createState() =>
      _PaymentHistoryScreenState();
}

class _PaymentHistoryScreenState extends ConsumerState<PaymentHistoryScreen> {
  late PaymentHistoryFilter _filter = PaymentHistoryFilter(role: widget.role);
  @override
  Widget build(BuildContext context) {
    final history = ref.watch(paymentHistoryProvider(_filter));
    return Scaffold(
      appBar: AppBar(
        leading: const DashboardBackButton(),
        actions: [
          IconButton(
            tooltip: 'Filter payments',
            icon: const Icon(Icons.filter_list),
            onPressed: () async {
              final filter = await showModalBottomSheet<PaymentHistoryFilter>(
                context: context,
                builder: (_) => PaymentFilterSheet(initialFilter: _filter),
              );
              if (filter != null) setState(() => _filter = filter);
            },
          ),
        ],
        title: const Text('Payment history'),
      ),
      body: history.when(
        loading: () => const AppLoadingIndicator(),
        error: (error, stack) => AppErrorState(
          message: apiErrorMessage(error),
          onRetry: () => ref.invalidate(paymentHistoryProvider(_filter)),
        ),
        data: (page) => page.items.isEmpty
            ? const AppEmptyState(
                title: 'No payments',
                message: 'Payments matching your filters will appear here.',
              )
            : RefreshIndicator(
                onRefresh: () async =>
                    ref.invalidate(paymentHistoryProvider(_filter)),
                child: ListView(
                  children: [
                    for (final payment in page.items)
                      ListTile(
                        title: Text(payment.referenceNumber ?? 'Payment'),
                        subtitle: Text(
                          '${payment.className ?? 'Class'} | ${_money(payment.totalAmount, payment.currency)}',
                        ),
                        trailing: Chip(label: Text(payment.status)),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PaymentDetailScreen(
                              role: widget.role,
                              paymentId: payment.id,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
      ),
    );
  }
}

class PaymentDetailScreen extends ConsumerWidget {
  const PaymentDetailScreen({
    required this.role,
    required this.paymentId,
    super.key,
  });
  final ParticipantRole role;
  final int paymentId;
  @override
  Widget build(BuildContext context, WidgetRef ref) => ref
      .watch(paymentProvider((role: role, id: paymentId)))
      .when(
        loading: () => const Scaffold(body: AppLoadingIndicator()),
        error: (error, stack) =>
            Scaffold(body: AppErrorState(message: apiErrorMessage(error))),
        data: (payment) => Scaffold(
          appBar: AppBar(
            leading: const DashboardBackButton(),
            title: const Text('Payment detail'),
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _row('Payment reference', payment.referenceNumber ?? '-'),
              _row(
                'Schedule',
                payment.scheduleName ?? payment.className ?? '-',
              ),
              _row('Payer', payment.payerName ?? '-'),
              _row(
                'Required amount',
                _money(payment.requiredAmount, payment.currency),
              ),
              _row(
                'Additional infaq',
                _money(payment.additionalInfaq, payment.currency),
              ),
              _row(
                'Total amount',
                _money(payment.totalAmount, payment.currency),
              ),
              _row('Payment method', payment.paymentMethod ?? '-'),
              _row('Status', payment.status),
              _row('Paid date', _date(context, payment.paidAt)),
              _row('Created date', _date(context, payment.createdAt)),
              _row('Verified date', _date(context, payment.verifiedAt)),
              _row('Notes', payment.notes ?? '-'),
            ],
          ),
        ),
      );
}

class PaymentFilterSheet extends StatefulWidget {
  const PaymentFilterSheet({required this.initialFilter, super.key});
  final PaymentHistoryFilter initialFilter;
  @override
  State<PaymentFilterSheet> createState() => _PaymentFilterSheetState();
}

class _PaymentFilterSheetState extends State<PaymentFilterSheet> {
  late String? _status = widget.initialFilter.status;
  late String? _method = widget.initialFilter.paymentMethod;
  @override
  Widget build(BuildContext context) => SafeArea(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Filter payments',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          DropdownButtonFormField<String>(
            initialValue: _status,
            hint: const Text('All statuses'),
            items: const [
              DropdownMenuItem(value: 'paid', child: Text('Paid')),
              DropdownMenuItem(value: 'pending', child: Text('Pending')),
              DropdownMenuItem(value: 'initiated', child: Text('Initiated')),
              DropdownMenuItem(value: 'failed', child: Text('Failed')),
              DropdownMenuItem(value: 'refunded', child: Text('Refunded')),
              DropdownMenuItem(value: 'overdue', child: Text('Overdue')),
            ],
            onChanged: (value) => setState(() => _status = value),
          ),
          DropdownButtonFormField<String>(
            initialValue: _method,
            hint: const Text('All payment methods'),
            items: const [
              DropdownMenuItem(value: 'manual', child: Text('Manual')),
              DropdownMenuItem(
                value: 'bank_transfer',
                child: Text('Bank transfer'),
              ),
              DropdownMenuItem(value: 'qr', child: Text('QR')),
              DropdownMenuItem(value: 'merchant', child: Text('Merchant')),
            ],
            onChanged: (value) => setState(() => _method = value),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(
              context,
              PaymentHistoryFilter(
                role: widget.initialFilter.role,
                status: _status,
                paymentMethod: _method,
                classId: widget.initialFilter.classId,
                dateFrom: widget.initialFilter.dateFrom,
                dateTo: widget.initialFilter.dateTo,
                perPage: widget.initialFilter.perPage,
              ),
            ),
            child: const Text('Apply filters'),
          ),
        ],
      ),
    ),
  );
}

Widget _row(String label, String value) =>
    ListTile(title: Text(label), subtitle: Text(value));
String _money(num? amount, String? currency) =>
    currency == null || currency == 'MYR'
    ? formatMyCurrency(amount ?? 0)
    : '$currency ${(amount ?? 0).toStringAsFixed(2)}';
String _date(BuildContext context, DateTime? value) => value == null
    ? '-'
    : MaterialLocalizations.of(context).formatShortDate(value);
