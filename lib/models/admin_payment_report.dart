class PaymentSummaryReport {
  const PaymentSummaryReport({
    required this.totalPayments,
    required this.successfulPayments,
    required this.pendingPayments,
    required this.failedPayments,
    required this.refundedPayments,
    required this.totalCollected,
    required this.totalOutstanding,
    required this.totalOverdue,
  });
  final int totalPayments;
  final int successfulPayments;
  final int pendingPayments;
  final int failedPayments;
  final int refundedPayments;
  final num totalCollected;
  final num totalOutstanding;
  final num totalOverdue;
  factory PaymentSummaryReport.fromJson(Object? json) {
    final map = json as Map<String, dynamic>;
    return PaymentSummaryReport(
      totalPayments: _int(map['total_payments']),
      successfulPayments: _int(map['successful_payments']),
      pendingPayments: _int(map['pending_payments']),
      failedPayments: _int(map['failed_payments']),
      refundedPayments: _int(map['refunded_payments']),
      totalCollected: _num(map['total_collected']),
      totalOutstanding: _num(map['total_outstanding']),
      totalOverdue: _num(map['total_overdue']),
    );
  }
}

class OutstandingReportItem {
  const OutstandingReportItem({
    required this.organization,
    required this.className,
    required this.participant,
    required this.period,
    required this.dueDate,
    required this.requiredAmount,
    required this.amountPaid,
    required this.outstandingAmount,
    required this.status,
    this.daysOverdue,
  });
  final String organization;
  final String className;
  final String participant;
  final String period;
  final DateTime? dueDate;
  final num requiredAmount;
  final num amountPaid;
  final num outstandingAmount;
  final String status;
  final int? daysOverdue;
  factory OutstandingReportItem.fromJson(Object? json) {
    final map = json as Map<String, dynamic>;
    return OutstandingReportItem(
      organization: map['organization_name'] as String? ?? '',
      className: map['class_name'] as String? ?? '',
      participant: map['participant_name'] as String? ?? '',
      period: map['period'] as String? ?? '',
      dueDate: map['due_date'] is String
          ? DateTime.tryParse(map['due_date'] as String)
          : null,
      requiredAmount: _num(map['required_amount']),
      amountPaid: _num(map['amount_paid']),
      outstandingAmount: _num(map['outstanding_amount']),
      status: map['status'] as String? ?? '',
      daysOverdue: map['days_overdue'] as int?,
    );
  }
}

int _int(Object? value) =>
    value is num ? value.toInt() : int.tryParse('$value') ?? 0;
num _num(Object? value) => value is num ? value : num.tryParse('$value') ?? 0;
