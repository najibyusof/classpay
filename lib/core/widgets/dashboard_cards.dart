import 'package:classpay/core/utils/currency_formatter.dart';
import 'package:classpay/core/widgets/app_card.dart';
import 'package:classpay/models/dashboard_model.dart';
import 'package:flutter/material.dart';

class SummaryCard extends StatelessWidget {
  const SummaryCard({
    required this.label,
    required this.value,
    required this.icon,
    super.key,
  });
  final String label;
  final int value;
  final IconData icon;

  @override
  Widget build(BuildContext context) => AppCard(
    child: Row(
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label),
              const SizedBox(height: 4),
              Text('$value', style: Theme.of(context).textTheme.headlineSmall),
            ],
          ),
        ),
      ],
    ),
  );
}

class FinancialCard extends StatelessWidget {
  const FinancialCard({
    required this.label,
    required this.amount,
    required this.color,
    super.key,
  });
  final String label;
  final num amount;
  final Color color;

  @override
  Widget build(BuildContext context) => AppCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        const SizedBox(height: 8),
        Text(
          formatMyCurrency(amount),
          style: Theme.of(context).textTheme.titleLarge?.copyWith(color: color),
        ),
      ],
    ),
  );
}

class PaymentStatusCard extends StatelessWidget {
  const PaymentStatusCard({
    required this.label,
    required this.value,
    super.key,
    this.color,
  });
  final String label;
  final int value;
  final Color? color;

  @override
  Widget build(BuildContext context) => AppCard(
    padding: const EdgeInsets.all(12),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 4),
        Text(
          '$value',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(color: color),
        ),
      ],
    ),
  );
}

class RecentPaymentTile extends StatelessWidget {
  const RecentPaymentTile({required this.payment, super.key});
  final RecentPayment payment;

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(context, payment.status);
    final date = payment.date == null
        ? '-'
        : MaterialLocalizations.of(context).formatShortDate(payment.date!);
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: CircleAvatar(
        child: Text(
          payment.payerName.isEmpty ? '?' : payment.payerName[0].toUpperCase(),
        ),
      ),
      title: Text(
        payment.payerName.isEmpty ? 'Unknown payer' : payment.payerName,
      ),
      subtitle: Text(
        '${payment.className.isEmpty ? 'No class' : payment.className} | ${payment.paymentMethod.isEmpty ? 'No method' : payment.paymentMethod}\n$date',
      ),
      isThreeLine: true,
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            formatMyCurrency(payment.amount),
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 4),
          Text(
            payment.status.isEmpty ? 'Unknown' : payment.status,
            style: Theme.of(
              context,
            ).textTheme.labelSmall?.copyWith(color: color),
          ),
        ],
      ),
    );
  }

  Color _statusColor(BuildContext context, String status) =>
      switch (status.toLowerCase()) {
        'paid' => Colors.green.shade700,
        'overdue' || 'failed' => Theme.of(context).colorScheme.error,
        _ => Theme.of(context).colorScheme.primary,
      };
}
