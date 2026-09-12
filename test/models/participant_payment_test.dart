import 'package:classpay/models/participant_payment.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parses schedule payment options without calculating totals', () {
    final schedule = ParticipantPaymentSchedule.fromJson({
      'id': 1,
      'class_name': 'Year 6',
      'required_amount': '50.00',
      'payment_status': 'pending',
      'payment_options': {
        'currency': 'MYR',
        'allow_additional_infaq': true,
        'minimum_infaq': 1,
        'maximum_infaq': 10,
      },
    });
    expect(schedule.requiredAmount, 50);
    expect(schedule.options.maximumInfaq, 10);
  });
}
