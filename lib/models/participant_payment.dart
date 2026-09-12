enum ParticipantRole { student, sponsor }

class PaymentOptions {
  const PaymentOptions({
    required this.currency,
    required this.allowAdditionalInfaq,
    this.minimumInfaq,
    this.maximumInfaq,
    this.bankName,
    this.bankAccountName,
    this.bankAccountNumber,
    this.qrCodeUrl,
    this.merchantDetails,
  });
  final String currency;
  final bool allowAdditionalInfaq;
  final num? minimumInfaq;
  final num? maximumInfaq;
  final String? bankName;
  final String? bankAccountName;
  final String? bankAccountNumber;
  final String? qrCodeUrl;
  final Map<String, dynamic>? merchantDetails;
  factory PaymentOptions.fromJson(Object? json) {
    final map = json as Map<String, dynamic>? ?? const {};
    return PaymentOptions(
      currency: map['currency'] as String? ?? 'MYR',
      allowAdditionalInfaq: map['allow_additional_infaq'] == true,
      minimumInfaq: _value(map['minimum_infaq']),
      maximumInfaq: _value(map['maximum_infaq']),
      bankName: map['bank_name'] as String?,
      bankAccountName: map['bank_account_name'] as String?,
      bankAccountNumber: map['bank_account_number'] as String?,
      qrCodeUrl: map['qr_code_url'] as String?,
      merchantDetails: map['merchant_details'] as Map<String, dynamic>?,
    );
  }
}

class ParticipantPaymentSchedule {
  const ParticipantPaymentSchedule({
    required this.id,
    required this.className,
    required this.periodStart,
    required this.periodEnd,
    required this.dueDate,
    required this.requiredAmount,
    required this.status,
    required this.options,
  });
  final int id;
  final String className;
  final DateTime? periodStart;
  final DateTime? periodEnd;
  final DateTime? dueDate;
  final num requiredAmount;
  final String status;
  final PaymentOptions options;
  bool get isPaid => status.toLowerCase() == 'paid';
  factory ParticipantPaymentSchedule.fromJson(Object? json) {
    final map = json as Map<String, dynamic>;
    return ParticipantPaymentSchedule(
      id: map['id'] as int,
      className:
          (map['class_name'] ??
                  (map['class'] as Map<String, dynamic>?)?['name'] ??
                  '')
              .toString(),
      periodStart: _date(map['period_start']),
      periodEnd: _date(map['period_end']),
      dueDate: _date(map['due_date']),
      requiredAmount: _value(map['required_amount']) ?? 0,
      status:
          map['payment_status'] as String? ?? map['status'] as String? ?? '',
      options: PaymentOptions.fromJson(
        map['payment_options'] ?? map['payment_setting'],
      ),
    );
  }
}

class ParticipantPayment {
  const ParticipantPayment({
    required this.id,
    required this.status,
    this.message,
    this.merchantData,
    this.referenceNumber,
    this.classId,
    this.className,
    this.scheduleName,
    this.payerName,
    this.requiredAmount,
    this.additionalInfaq,
    this.totalAmount,
    this.currency,
    this.paymentMethod,
    this.paidAt,
    this.createdAt,
    this.verifiedAt,
    this.notes,
  });
  final int id;
  final String status;
  final String? message;
  final Map<String, dynamic>? merchantData;
  final String? referenceNumber;
  final int? classId;
  final String? className;
  final String? scheduleName;
  final String? payerName;
  final num? requiredAmount;
  final num? additionalInfaq;
  final num? totalAmount;
  final String? currency;
  final String? paymentMethod;
  final DateTime? paidAt;
  final DateTime? createdAt;
  final DateTime? verifiedAt;
  final String? notes;
  factory ParticipantPayment.fromJson(Object? json) {
    final map = json as Map<String, dynamic>;
    final classData = map['class'] as Map<String, dynamic>?;
    return ParticipantPayment(
      id: map['id'] as int,
      status: map['status'] as String? ?? '',
      message: map['message'] as String?,
      merchantData:
          map['merchant'] as Map<String, dynamic>? ??
          map['merchant_data'] as Map<String, dynamic>?,
      referenceNumber: (map['reference_number'] ?? map['reference']) as String?,
      classId: (map['class_id'] ?? classData?['id']) as int?,
      className: (map['class_name'] ?? classData?['name']) as String?,
      scheduleName:
          (map['schedule_name'] ??
                  (map['payment_schedule'] as Map<String, dynamic>?)?['name'])
              as String?,
      payerName:
          (map['payer_name'] ??
                  (map['payer'] as Map<String, dynamic>?)?['name'])
              as String?,
      requiredAmount: _value(map['required_amount']),
      additionalInfaq: _value(map['additional_infaq']),
      totalAmount: _value(map['total_amount']),
      currency: map['currency'] as String?,
      paymentMethod: map['payment_method'] as String?,
      paidAt: _date(map['paid_at']),
      createdAt: _date(map['created_at']),
      verifiedAt: _date(map['verified_at']),
      notes: map['notes'] as String?,
    );
  }
}

num? _value(Object? value) => value is num ? value : num.tryParse('$value');
DateTime? _date(Object? value) =>
    value is String ? DateTime.tryParse(value) : null;
