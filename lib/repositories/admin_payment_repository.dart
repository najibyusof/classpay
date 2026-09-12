import 'package:classpay/core/network/api_client.dart';
import 'package:classpay/core/network/pagination.dart';
import 'package:classpay/models/admin_payment_report.dart';
import 'package:classpay/models/participant_payment.dart';
import 'package:classpay/services/admin_payment_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final adminPaymentServiceProvider = Provider<AdminPaymentService>(
  (ref) => AdminPaymentService(ref.watch(apiClientProvider)),
);
final adminPaymentRepositoryProvider = Provider<AdminPaymentRepository>(
  (ref) => AdminPaymentRepository(ref.watch(adminPaymentServiceProvider)),
);

class AdminPaymentRepository {
  const AdminPaymentRepository(this._service);
  final AdminPaymentService _service;
  Future<PaginatedResponse<ParticipantPayment>> payments({
    Map<String, dynamic>? query,
  }) => _service.payments(query: query);
  Future<PaymentSummaryReport> summary({Map<String, dynamic>? query}) =>
      _service.summary(query: query);
  Future<PaginatedResponse<OutstandingReportItem>> outstanding({
    Map<String, dynamic>? query,
  }) => _service.outstanding(query: query);
  Future<PaginatedResponse<OutstandingReportItem>> overdue({
    Map<String, dynamic>? query,
  }) => _service.overdue(query: query);
}
