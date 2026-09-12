import 'package:classpay/models/payment_setting.dart';
import 'package:classpay/repositories/payment_setting_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final paymentSettingProvider = FutureProvider.autoDispose
    .family<PaymentSetting, int>(
      (ref, id) => ref.watch(paymentSettingRepositoryProvider).get(id),
    );
