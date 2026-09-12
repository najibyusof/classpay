import 'package:classpay/core/network/api_client.dart';
import 'package:classpay/core/network/pagination.dart';
import 'package:classpay/models/admin_payment_report.dart';
import 'package:classpay/models/participant_payment.dart';

class AdminPaymentService {
  const AdminPaymentService(this._client);
  final ApiClient _client;
  Future<PaginatedResponse<ParticipantPayment>> payments({
    Map<String, dynamic>? query,
  }) async {
    final response = await _client.get<PaginatedResponse<ParticipantPayment>>(
      '/admin/payments',
      queryParameters: query,
      fromJson: (json) => PaginatedResponse.fromJson(
        json,
        itemFromJson: ParticipantPayment.fromJson,
      ),
    );
    return response.data;
  }

  Future<PaymentSummaryReport> summary({Map<String, dynamic>? query}) async {
    final response = await _client.get<PaymentSummaryReport>(
      '/admin/reports/payment-summary',
      queryParameters: query,
      fromJson: PaymentSummaryReport.fromJson,
    );
    return response.data;
  }

  Future<PaginatedResponse<OutstandingReportItem>> outstanding({
    Map<String, dynamic>? query,
  }) async {
    final response = await _client
        .get<PaginatedResponse<OutstandingReportItem>>(
          '/admin/reports/outstanding',
          queryParameters: query,
          fromJson: (json) => PaginatedResponse.fromJson(
            json,
            itemFromJson: OutstandingReportItem.fromJson,
          ),
        );
    return response.data;
  }

  Future<PaginatedResponse<OutstandingReportItem>> overdue({
    Map<String, dynamic>? query,
  }) async {
    final response = await _client
        .get<PaginatedResponse<OutstandingReportItem>>(
          '/admin/reports/overdue',
          queryParameters: query,
          fromJson: (json) => PaginatedResponse.fromJson(
            json,
            itemFromJson: OutstandingReportItem.fromJson,
          ),
        );
    return response.data;
  }
}
