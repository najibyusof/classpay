import 'package:classpay/core/network/api_client.dart';
import 'package:classpay/models/payment_setting.dart';
import 'package:classpay/services/payment_setting_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final paymentSettingServiceProvider = Provider<PaymentSettingService>(
  (ref) => PaymentSettingService(ref.watch(apiClientProvider)),
);
final paymentSettingRepositoryProvider = Provider<PaymentSettingRepository>(
  (ref) => PaymentSettingRepository(ref.watch(paymentSettingServiceProvider)),
);

class PaymentSettingRepository {
  const PaymentSettingRepository(this._service);
  final PaymentSettingService _service;
  Future<PaymentSetting> get(int id) => _service.get(id);
  Future<PaymentSetting> save(
    int id,
    PaymentSetting value, {
    required bool exists,
  }) => _service.save(id, value, exists: exists);
  Future<String> uploadQr(int id, List<int> bytes, String filename) =>
      _service.uploadQr(id, bytes, filename);
}
