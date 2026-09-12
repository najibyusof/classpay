import 'package:classpay/models/admin_payment_report.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parses backend aggregated payment reports', () {
    final summary = PaymentSummaryReport.fromJson({
      'total_payments': 10,
      'successful_payments': 5,
      'pending_payments': 2,
      'failed_payments': 1,
      'refunded_payments': 1,
      'total_collected': '100.50',
      'total_outstanding': 20,
      'total_overdue': 10,
    });
    final outstanding = OutstandingReportItem.fromJson({
      'organization_name': 'School',
      'class_name': 'Year 6',
      'participant_name': 'Aina',
      'period': 'Sep',
      'due_date': '2026-09-30',
      'required_amount': 100,
      'amount_paid': 50,
      'outstanding_amount': 50,
      'status': 'pending',
      'days_overdue': 3,
    });
    expect(summary.totalCollected, 100.50);
    expect(outstanding.daysOverdue, 3);
  });
}
