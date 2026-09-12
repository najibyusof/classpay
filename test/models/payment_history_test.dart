import 'package:classpay/models/participant_payment.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parses payment history and detail fields without credentials', () {
    final payment = ParticipantPayment.fromJson({
      'id': 2,
      'reference_number': 'CP-100',
      'class_name': 'Year 6',
      'payer_name': 'Aina',
      'required_amount': 50,
      'additional_infaq': 5,
      'total_amount': 55,
      'currency': 'MYR',
      'status': 'paid',
      'payment_method': 'qr',
      'paid_at': '2026-09-12T10:00:00Z',
      'created_at': '2026-09-11T10:00:00Z',
      'verified_at': '2026-09-12T11:00:00Z',
      'notes': 'Received',
    });
    expect(payment.referenceNumber, 'CP-100');
    expect(payment.totalAmount, 55);
    expect(payment.status, 'paid');
  });
}
