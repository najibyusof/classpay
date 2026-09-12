import 'package:classpay/core/network/api_client.dart';
import 'package:classpay/core/network/pagination.dart';
import 'package:classpay/models/participant_payment.dart';

class ParticipantPaymentService {
  const ParticipantPaymentService(this._client);
  final ApiClient _client;
  String _base(ParticipantRole role) => '/${role.name}';
  Future<PaginatedResponse<ParticipantPaymentSchedule>> schedules(
    ParticipantRole role,
  ) async {
    final response = await _client
        .get<PaginatedResponse<ParticipantPaymentSchedule>>(
          '${_base(role)}/payment-schedules',
          fromJson: (json) => PaginatedResponse.fromJson(
            json,
            itemFromJson: ParticipantPaymentSchedule.fromJson,
          ),
        );
    return response.data;
  }

  Future<ParticipantPaymentSchedule> schedule(
    ParticipantRole role,
    int id,
  ) async {
    final response = await _client.get<ParticipantPaymentSchedule>(
      '${_base(role)}/payment-schedules/$id',
      fromJson: ParticipantPaymentSchedule.fromJson,
    );
    return response.data;
  }

  Future<ParticipantPaymentSchedule> current(ParticipantRole role) async {
    final response = await _client.get<ParticipantPaymentSchedule>(
      '${_base(role)}/payment-schedules/current',
      fromJson: ParticipantPaymentSchedule.fromJson,
    );
    return response.data;
  }

  Future<ParticipantPayment> makePayment(
    ParticipantRole role,
    int scheduleId, {
    required num additionalInfaq,
    required String paymentMethod,
  }) async {
    final response = await _client.post<ParticipantPayment>(
      '${_base(role)}/payment-schedules/$scheduleId/payments',
      data: {
        'additional_infaq': additionalInfaq,
        'payment_method': paymentMethod,
      },
      fromJson: ParticipantPayment.fromJson,
    );
    return response.data;
  }

  Future<PaginatedResponse<ParticipantPayment>> payments(
    ParticipantRole role, {
    Map<String, dynamic>? queryParameters,
  }) async {
    final response = await _client.get<PaginatedResponse<ParticipantPayment>>(
      '${_base(role)}/payments',
      queryParameters: queryParameters,
      fromJson: (json) => PaginatedResponse.fromJson(
        json,
        itemFromJson: ParticipantPayment.fromJson,
      ),
    );
    return response.data;
  }

  Future<ParticipantPayment> payment(ParticipantRole role, int id) async {
    final response = await _client.get<ParticipantPayment>(
      '${_base(role)}/payments/$id',
      fromJson: ParticipantPayment.fromJson,
    );
    return response.data;
  }
}
