import 'package:classpay/core/network/api_client.dart';
import 'package:classpay/core/network/pagination.dart';
import 'package:classpay/models/participant_payment.dart';
import 'package:classpay/services/participant_payment_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final participantPaymentServiceProvider = Provider<ParticipantPaymentService>(
  (ref) => ParticipantPaymentService(ref.watch(apiClientProvider)),
);
final participantPaymentRepositoryProvider =
    Provider<ParticipantPaymentRepository>(
      (ref) => ParticipantPaymentRepository(
        ref.watch(participantPaymentServiceProvider),
      ),
    );

class ParticipantPaymentRepository {
  const ParticipantPaymentRepository(this._service);
  final ParticipantPaymentService _service;
  Future<PaginatedResponse<ParticipantPaymentSchedule>> schedules(
    ParticipantRole role,
  ) => _service.schedules(role);
  Future<ParticipantPaymentSchedule> schedule(ParticipantRole role, int id) =>
      _service.schedule(role, id);
  Future<ParticipantPayment> makePayment(
    ParticipantRole role,
    int id, {
    required num additionalInfaq,
    required String paymentMethod,
  }) => _service.makePayment(
    role,
    id,
    additionalInfaq: additionalInfaq,
    paymentMethod: paymentMethod,
  );
  Future<PaginatedResponse<ParticipantPayment>> payments(
    ParticipantRole role, {
    Map<String, dynamic>? queryParameters,
  }) => _service.payments(role, queryParameters: queryParameters);
  Future<ParticipantPayment> payment(ParticipantRole role, int id) =>
      _service.payment(role, id);
}
