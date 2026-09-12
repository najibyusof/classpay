import 'package:classpay/models/payment_setting.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'parses backend payment setting values and excludes infaq bounds when disabled',
    () {
      final setting = PaymentSetting.fromJson({
        'required_amount': '100.50',
        'currency': 'MYR',
        'payment_frequency': 'monthly',
        'bank_name': 'Bank',
        'bank_account_name': 'ClassPay',
        'bank_account_number': '123',
        'allow_additional_infaq': false,
        'minimum_infaq': 1,
        'maximum_infaq': 10,
        'reminder_enabled': true,
        'reminder_days_before': 3,
        'reminder_days_after': 1,
      });
      expect(setting.requiredAmount, 100.50);
      expect(setting.toRequestJson().containsKey('minimum_infaq'), isFalse);
    },
  );
}
