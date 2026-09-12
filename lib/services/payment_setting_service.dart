import 'package:classpay/core/network/api_client.dart';
import 'package:classpay/models/payment_setting.dart';
import 'package:dio/dio.dart';

class PaymentSettingService {
  const PaymentSettingService(this._client);
  final ApiClient _client;
  String _path(int id) => '/classes/$id/payment-setting';
  Future<PaymentSetting> get(int id) async {
    final response = await _client.get<PaymentSetting>(
      _path(id),
      fromJson: PaymentSetting.fromJson,
    );
    return response.data;
  }

  Future<PaymentSetting> save(
    int id,
    PaymentSetting setting, {
    required bool exists,
  }) async {
    final response = exists
        ? await _client.put<PaymentSetting>(
            _path(id),
            data: setting.toRequestJson(),
            fromJson: PaymentSetting.fromJson,
          )
        : await _client.post<PaymentSetting>(
            _path(id),
            data: setting.toRequestJson(),
            fromJson: PaymentSetting.fromJson,
          );
    return response.data;
  }

  Future<void> delete(int id) =>
      _client.delete<void>(_path(id), fromJson: (_) {});
  Future<String> uploadQr(int id, List<int> bytes, String filename) async {
    final response = await _client.post<void>(
      '${_path(id)}/qr-code',
      data: FormData.fromMap({
        'qr_code': MultipartFile.fromBytes(bytes, filename: filename),
      }),
      fromJson: (_) {},
    );
    return response.message;
  }
}
