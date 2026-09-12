import 'package:classpay/core/theme/app_theme.dart';
import 'package:classpay/models/dashboard_model.dart';
import 'package:classpay/providers/dashboard_provider.dart';
import 'package:classpay/screens/admin/admin_dashboard_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
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
    'financial': {'collected': 1234.5, 'outstanding': 220, 'overdue': 20},
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

  testWidgets('renders API-backed admin dashboard summaries and payments', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          adminDashboardProvider(
            const DashboardFilter(),
          ).overrideWith((ref) async => dashboard),
        ],
        child: MaterialApp(
          theme: AppTheme.light(),
          home: const AdminDashboardScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Admin overview'), findsOneWidget);
    expect(find.text('Organizations'), findsOneWidget);
    expect(find.text('RM 1234.50'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Aina'),
      300,
      scrollable: find
          .descendant(
            of: find.byType(ListView),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    expect(find.text('Aina'), findsOneWidget);
    expect(find.textContaining('Year 6 Amanah | FPX'), findsOneWidget);
  });
}
