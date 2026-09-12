import 'package:classpay/models/dashboard_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parses dashboard aggregates and recent payments from the API data', () {
    final dashboard = DashboardModel.fromJson({
      'organizations': 4,
      'active_organizations': 3,
      'classes': 12,
      'active_classes': 10,
      'students': 200,
      'sponsors': 50,
      'participants': 250,
      'payment_schedules': {
        'total': 20,
        'upcoming': 5,
        'pending': 4,
        'overdue': 2,
        'paid': 9,
      },
      'payments': {
        'total': 100,
        'paid': 80,
        'pending': 10,
        'overdue': 5,
        'failed': 3,
        'refunded': 2,
      },
      'financial': {'collected': '1234.5', 'outstanding': 220, 'overdue': 20},
      'recent_payments': [
        {
          'payer_name': 'Aina',
          'class_name': 'Year 6 Amanah',
          'amount': 50,
          'payment_method': 'FPX',
          'status': 'paid',
          'paid_at': '2026-09-12T10:00:00Z',
        },
      ],
    });

    expect(dashboard.activeClasses, 10);
    expect(dashboard.financial.collected, 1234.5);
    expect(dashboard.recentPayments.single.payerName, 'Aina');
    expect(dashboard.recentPayments.single.amount, 50);
  });
}
