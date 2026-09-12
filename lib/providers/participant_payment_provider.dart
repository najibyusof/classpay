import 'package:classpay/core/network/pagination.dart';
import 'package:classpay/models/participant_payment.dart';
import 'package:classpay/repositories/participant_payment_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final paymentSchedulesProvider = FutureProvider.autoDispose
    .family<PaginatedResponse<ParticipantPaymentSchedule>, ParticipantRole>(
      (ref, role) =>
          ref.watch(participantPaymentRepositoryProvider).schedules(role),
    );
final paymentScheduleProvider = FutureProvider.autoDispose
    .family<ParticipantPaymentSchedule, ({ParticipantRole role, int id})>(
      (ref, value) => ref
          .watch(participantPaymentRepositoryProvider)
          .schedule(value.role, value.id),
    );

class PaymentHistoryFilter {
  const PaymentHistoryFilter({
    required this.role,
    this.status,
    this.paymentMethod,
    this.classId,
    this.dateFrom,
    this.dateTo,
    this.perPage = 15,
  });
  final ParticipantRole role;
  final String? status;
  final String? paymentMethod;
  final int? classId;
  final DateTime? dateFrom;
  final DateTime? dateTo;
  final int perPage;
  Map<String, dynamic> get queryParameters => {
    if (status != null) 'status': status,
    if (paymentMethod != null) 'payment_method': paymentMethod,
    if (classId != null) 'class_id': classId,
    if (dateFrom != null) 'date_from': _date(dateFrom!),
    if (dateTo != null) 'date_to': _date(dateTo!),
    'per_page': perPage,
  };
  @override
  bool operator ==(Object other) =>
      other is PaymentHistoryFilter &&
      other.role == role &&
      other.status == status &&
      other.paymentMethod == paymentMethod &&
      other.classId == classId &&
      other.dateFrom == dateFrom &&
      other.dateTo == dateTo &&
      other.perPage == perPage;
  @override
  int get hashCode => Object.hash(
    role,
    status,
    paymentMethod,
    classId,
    dateFrom,
    dateTo,
    perPage,
  );
}

String _date(DateTime value) =>
    '${value.year.toString().padLeft(4, '0')}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')}';
final paymentHistoryProvider = FutureProvider.autoDispose
    .family<PaginatedResponse<ParticipantPayment>, PaymentHistoryFilter>(
      (ref, filter) => ref
          .watch(participantPaymentRepositoryProvider)
          .payments(filter.role, queryParameters: filter.queryParameters),
    );
final paymentProvider = FutureProvider.autoDispose
    .family<ParticipantPayment, ({ParticipantRole role, int id})>(
      (ref, value) => ref
          .watch(participantPaymentRepositoryProvider)
          .payment(value.role, value.id),
    );
