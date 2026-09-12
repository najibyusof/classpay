import 'package:classpay/models/participant_payment.dart';
import 'package:classpay/providers/participant_payment_provider.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('serializes documented payment history filters', () {
    final filter = PaymentHistoryFilter(
      role: ParticipantRole.sponsor,
      status: 'paid',
      paymentMethod: 'qr',
      classId: 4,
      dateFrom: DateTime(2026, 1, 1),
      dateTo: DateTime(2026, 1, 31),
      perPage: 20,
    );
    expect(filter.queryParameters, {
      'status': 'paid',
      'payment_method': 'qr',
      'class_id': 4,
      'date_from': '2026-01-01',
      'date_to': '2026-01-31',
      'per_page': 20,
    });
  });
}
