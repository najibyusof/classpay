import 'package:classpay/core/network/pagination.dart';
import 'package:classpay/models/admin_payment_report.dart';
import 'package:classpay/models/participant_payment.dart';
import 'package:classpay/repositories/admin_payment_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AdminPaymentFilter {
  const AdminPaymentFilter({
    this.organizationId,
    this.classId,
    this.participantId,
    this.studentId,
    this.sponsorId,
    this.status,
    this.paymentMethod,
    this.dateFrom,
    this.dateTo,
    this.page = 1,
  });
  final int? organizationId;
  final int? classId;
  final int? participantId;
  final int? studentId;
  final int? sponsorId;
  final String? status;
  final String? paymentMethod;
  final DateTime? dateFrom;
  final DateTime? dateTo;
  final int page;
  Map<String, dynamic> get query => {
    if (organizationId != null) 'organization_id': organizationId,
    if (classId != null) 'class_id': classId,
    if (participantId != null) 'participant_id': participantId,
    if (studentId != null) 'student_id': studentId,
    if (sponsorId != null) 'sponsor_id': sponsorId,
    if (status != null) 'status': status,
    if (paymentMethod != null) 'payment_method': paymentMethod,
    if (dateFrom != null) 'date_from': _date(dateFrom!),
    if (dateTo != null) 'date_to': _date(dateTo!),
    'page': page,
  };
  @override
  bool operator ==(Object other) =>
      other is AdminPaymentFilter && other.query.toString() == query.toString();
  @override
  int get hashCode => query.toString().hashCode;
}

String _date(DateTime value) =>
    '${value.year.toString().padLeft(4, '0')}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')}';
final adminPaymentsProvider = FutureProvider.autoDispose
    .family<PaginatedResponse<ParticipantPayment>, AdminPaymentFilter>(
      (ref, filter) => ref
          .watch(adminPaymentRepositoryProvider)
          .payments(query: filter.query),
    );
final paymentSummaryReportProvider = FutureProvider.autoDispose
    .family<PaymentSummaryReport, AdminPaymentFilter>(
      (ref, filter) => ref
          .watch(adminPaymentRepositoryProvider)
          .summary(query: filter.query),
    );
final outstandingReportProvider = FutureProvider.autoDispose
    .family<PaginatedResponse<OutstandingReportItem>, AdminPaymentFilter>(
      (ref, filter) => ref
          .watch(adminPaymentRepositoryProvider)
          .outstanding(query: filter.query),
    );
final overdueReportProvider = FutureProvider.autoDispose
    .family<PaginatedResponse<OutstandingReportItem>, AdminPaymentFilter>(
      (ref, filter) => ref
          .watch(adminPaymentRepositoryProvider)
          .overdue(query: filter.query),
    );
