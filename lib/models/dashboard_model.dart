class DashboardModel {
  const DashboardModel({
    required this.organizations,
    required this.activeOrganizations,
    required this.classes,
    required this.activeClasses,
    required this.students,
    required this.sponsors,
    required this.participants,
    required this.paymentSchedules,
    required this.payments,
    required this.financial,
    required this.recentPayments,
  });

  final int organizations;
  final int activeOrganizations;
  final int classes;
  final int activeClasses;
  final int students;
  final int sponsors;
  final int participants;
  final PaymentScheduleSummary paymentSchedules;
  final PaymentStatusSummary payments;
  final FinancialSummary financial;
  final List<RecentPayment> recentPayments;

  factory DashboardModel.fromJson(Object? json) {
    final map = json as Map<String, dynamic>;
    return DashboardModel(
      organizations: _toInt(map['organizations']),
      activeOrganizations: _toInt(map['active_organizations']),
      classes: _toInt(map['classes']),
      activeClasses: _toInt(map['active_classes']),
      students: _toInt(map['students']),
      sponsors: _toInt(map['sponsors']),
      participants: _toInt(map['participants']),
      paymentSchedules: PaymentScheduleSummary.fromJson(
        map['payment_schedules'],
      ),
      payments: PaymentStatusSummary.fromJson(map['payments']),
      financial: FinancialSummary.fromJson(map['financial']),
      recentPayments: (map['recent_payments'] as List<dynamic>? ?? const [])
          .map(RecentPayment.fromJson)
          .toList(growable: false),
    );
  }
}

class PaymentScheduleSummary {
  const PaymentScheduleSummary({
    required this.total,
    required this.upcoming,
    required this.pending,
    required this.overdue,
    required this.paid,
  });
  final int total;
  final int upcoming;
  final int pending;
  final int overdue;
  final int paid;

  factory PaymentScheduleSummary.fromJson(Object? json) {
    final map = json as Map<String, dynamic>? ?? const {};
    return PaymentScheduleSummary(
      total: _toInt(map['total']),
      upcoming: _toInt(map['upcoming']),
      pending: _toInt(map['pending']),
      overdue: _toInt(map['overdue']),
      paid: _toInt(map['paid']),
    );
  }
}

class PaymentStatusSummary {
  const PaymentStatusSummary({
    required this.total,
    required this.paid,
    required this.pending,
    required this.overdue,
    required this.failed,
    required this.refunded,
  });
  final int total;
  final int paid;
  final int pending;
  final int overdue;
  final int failed;
  final int refunded;

  factory PaymentStatusSummary.fromJson(Object? json) {
    final map = json as Map<String, dynamic>? ?? const {};
    return PaymentStatusSummary(
      total: _toInt(map['total']),
      paid: _toInt(map['paid']),
      pending: _toInt(map['pending']),
      overdue: _toInt(map['overdue']),
      failed: _toInt(map['failed']),
      refunded: _toInt(map['refunded']),
    );
  }
}

class FinancialSummary {
  const FinancialSummary({
    required this.collected,
    required this.outstanding,
    required this.overdue,
  });
  final num collected;
  final num outstanding;
  final num overdue;

  factory FinancialSummary.fromJson(Object? json) {
    final map = json as Map<String, dynamic>? ?? const {};
    return FinancialSummary(
      collected: _toNum(map['collected']),
      outstanding: _toNum(map['outstanding']),
      overdue: _toNum(map['overdue']),
    );
  }
}

class RecentPayment {
  const RecentPayment({
    required this.payerName,
    required this.className,
    required this.amount,
    required this.paymentMethod,
    required this.status,
    this.date,
  });
  final String payerName;
  final String className;
  final num amount;
  final String paymentMethod;
  final String status;
  final DateTime? date;

  factory RecentPayment.fromJson(Object? json) {
    final map = json as Map<String, dynamic>;
    return RecentPayment(
      payerName: _toString(map['payer_name'] ?? map['payer']?['name']),
      className: _toString(map['class_name'] ?? map['class']?['name']),
      amount: _toNum(map['amount']),
      paymentMethod: _toString(map['payment_method']),
      status: _toString(map['status']),
      date: _toDate(map['date'] ?? map['paid_at'] ?? map['created_at']),
    );
  }
}

int _toInt(Object? value) =>
    value is num ? value.toInt() : int.tryParse('$value') ?? 0;
num _toNum(Object? value) => value is num ? value : num.tryParse('$value') ?? 0;
String _toString(Object? value) => value?.toString() ?? '';
DateTime? _toDate(Object? value) =>
    value is String ? DateTime.tryParse(value) : null;
