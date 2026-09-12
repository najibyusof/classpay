class PaymentSetting {
  const PaymentSetting({
    required this.requiredAmount,
    required this.currency,
    required this.paymentFrequency,
    required this.bankName,
    required this.bankAccountName,
    required this.bankAccountNumber,
    required this.allowAdditionalInfaq,
    required this.minimumInfaq,
    required this.maximumInfaq,
    required this.reminderEnabled,
    required this.reminderDaysBefore,
    required this.reminderDaysAfter,
    this.qrCodeUrl,
  });
  final num requiredAmount;
  final String currency;
  final String paymentFrequency;
  final String bankName;
  final String bankAccountName;
  final String bankAccountNumber;
  final bool allowAdditionalInfaq;
  final num? minimumInfaq;
  final num? maximumInfaq;
  final bool reminderEnabled;
  final int? reminderDaysBefore;
  final int? reminderDaysAfter;
  final String? qrCodeUrl;
  factory PaymentSetting.fromJson(Object? json) {
    final map = json as Map<String, dynamic>;
    return PaymentSetting(
      requiredAmount: _num(map['required_amount']),
      currency: map['currency'] as String? ?? 'MYR',
      paymentFrequency: map['payment_frequency'] as String? ?? 'monthly',
      bankName: map['bank_name'] as String? ?? '',
      bankAccountName: map['bank_account_name'] as String? ?? '',
      bankAccountNumber: map['bank_account_number'] as String? ?? '',
      allowAdditionalInfaq: map['allow_additional_infaq'] == true,
      minimumInfaq: map['minimum_infaq'] == null
          ? null
          : _num(map['minimum_infaq']),
      maximumInfaq: map['maximum_infaq'] == null
          ? null
          : _num(map['maximum_infaq']),
      reminderEnabled: map['reminder_enabled'] == true,
      reminderDaysBefore: _intOrNull(map['reminder_days_before']),
      reminderDaysAfter: _intOrNull(map['reminder_days_after']),
      qrCodeUrl: map['qr_code_url'] as String?,
    );
  }
  Map<String, dynamic> toRequestJson() => {
    'required_amount': requiredAmount,
    'currency': currency,
    'payment_frequency': paymentFrequency,
    'bank_name': bankName,
    'bank_account_name': bankAccountName,
    'bank_account_number': bankAccountNumber,
    'allow_additional_infaq': allowAdditionalInfaq,
    if (allowAdditionalInfaq) 'minimum_infaq': minimumInfaq,
    if (allowAdditionalInfaq) 'maximum_infaq': maximumInfaq,
    'reminder_enabled': reminderEnabled,
    'reminder_days_before': reminderDaysBefore,
    'reminder_days_after': reminderDaysAfter,
  };
}

num _num(Object? value) => value is num ? value : num.tryParse('$value') ?? 0;
int? _intOrNull(Object? value) =>
    value is num ? value.toInt() : int.tryParse('$value');
