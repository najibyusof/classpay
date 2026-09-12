import 'package:classpay/core/theme/app_theme.dart';
import 'package:classpay/models/participant_payment.dart';
import 'package:classpay/repositories/participant_payment_repository.dart';
import 'package:classpay/screens/participant/payment_screens.dart';
import 'package:classpay/services/participant_payment_service.dart';
import 'package:classpay/core/network/api_client.dart';
import 'package:classpay/core/errors/api_exception.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const schedule = ParticipantPaymentSchedule(
    id: 1,
    className: 'Year 6 Amanah',
    periodStart: null,
    periodEnd: null,
    dueDate: null,
    requiredAmount: 50,
    status: 'pending',
    options: PaymentOptions(
      currency: 'MYR',
      allowAdditionalInfaq: true,
      minimumInfaq: 1,
      maximumInfaq: 10,
      bankName: 'Bank',
      bankAccountName: 'ClassPay',
      bankAccountNumber: '123',
    ),
  );
  Widget app() => ProviderScope(
    child: MaterialApp(
      theme: AppTheme.light(),
      home: const MakePaymentScreen(
        role: ParticipantRole.student,
        schedule: schedule,
      ),
    ),
  );

  testWidgets('displays backend required amount and payment methods', (
    tester,
  ) async {
    await tester.pumpWidget(app());
    expect(find.text('RM 50.00'), findsOneWidget);
    await tester.tap(find.text('Manual'));
    await tester.pumpAndSettle();
    expect(find.text('Bank transfer'), findsOneWidget);
    expect(find.text('QR'), findsOneWidget);
    expect(find.text('Merchant'), findsOneWidget);
  });

  testWidgets('rejects negative additional infaq before submission', (
    tester,
  ) async {
    await tester.pumpWidget(app());
    await tester.enterText(find.byType(TextFormField), '-1');
    await tester.tap(find.text('Continue'));
    await tester.pump();
    expect(find.text('Enter a non-negative amount.'), findsOneWidget);
  });

  testWidgets('shows the backend payment result after successful creation', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          participantPaymentRepositoryProvider.overrideWithValue(
            _SuccessRepository(),
          ),
        ],
        child: MaterialApp(
          theme: AppTheme.light(),
          home: const MakePaymentScreen(
            role: ParticipantRole.student,
            schedule: schedule,
          ),
        ),
      ),
    );
    await tester.enterText(find.byType(TextFormField), '1');
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    expect(find.text('Payment pending'), findsOneWidget);
  });

  testWidgets('shows backend failure after rejected payment creation', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          participantPaymentRepositoryProvider.overrideWithValue(
            _FailureRepository(),
          ),
        ],
        child: MaterialApp(
          theme: AppTheme.light(),
          home: const MakePaymentScreen(
            role: ParticipantRole.student,
            schedule: schedule,
          ),
        ),
      ),
    );
    await tester.enterText(find.byType(TextFormField), '1');
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    expect(find.text('Payment could not be created.'), findsOneWidget);
  });
}

class _SuccessRepository extends ParticipantPaymentRepository {
  _SuccessRepository() : super(ParticipantPaymentService(ApiClient(Dio())));
  @override
  Future<ParticipantPayment> makePayment(
    ParticipantRole role,
    int id, {
    required num additionalInfaq,
    required String paymentMethod,
  }) async => const ParticipantPayment(
    id: 3,
    status: 'pending',
    message: 'Payment submitted.',
  );
}

class _FailureRepository extends ParticipantPaymentRepository {
  _FailureRepository() : super(ParticipantPaymentService(ApiClient(Dio())));
  @override
  Future<ParticipantPayment> makePayment(
    ParticipantRole role,
    int id, {
    required num additionalInfaq,
    required String paymentMethod,
  }) => Future.error(
    const ApiException(
      message: 'Payment could not be created.',
      statusCode: 422,
    ),
  );
}
