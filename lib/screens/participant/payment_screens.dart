import 'package:classpay/core/errors/api_error_message.dart';
import 'package:classpay/core/errors/api_exception.dart';
import 'package:classpay/core/utils/currency_formatter.dart';
import 'package:classpay/core/widgets/app_button.dart';
import 'package:classpay/core/widgets/async_states.dart';
import 'package:classpay/core/widgets/dashboard_back_button.dart';
import 'package:classpay/models/participant_payment.dart';
import 'package:classpay/providers/participant_payment_provider.dart';
import 'package:classpay/repositories/participant_payment_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PaymentSchedulesScreen extends ConsumerWidget {
  const PaymentSchedulesScreen({required this.role, super.key});
  final ParticipantRole role;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(paymentSchedulesProvider(role));
    return Scaffold(
      appBar: AppBar(
        leading: const DashboardBackButton(),
        title: const Text('Payment schedules'),
      ),
      body: data.when(
        loading: () => const AppLoadingIndicator(),
        error: (error, stack) => AppErrorState(
          message: apiErrorMessage(error),
          onRetry: () => ref.invalidate(paymentSchedulesProvider(role)),
        ),
        data: (page) => page.items.isEmpty
            ? const AppEmptyState(
                title: 'No payment schedules',
                message: 'Your available payment schedules will appear here.',
              )
            : RefreshIndicator(
                onRefresh: () async =>
                    ref.invalidate(paymentSchedulesProvider(role)),
                child: ListView(
                  children: [
                    for (final schedule in page.items)
                      ListTile(
                        title: Text(schedule.className),
                        subtitle: Text(
                          '${formatMyCurrency(schedule.requiredAmount)} | Due ${_date(context, schedule.dueDate)}',
                        ),
                        trailing: Chip(label: Text(schedule.status)),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PaymentScheduleDetailScreen(
                              role: role,
                              scheduleId: schedule.id,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
      ),
    );
  }
}

class PaymentScheduleDetailScreen extends ConsumerWidget {
  const PaymentScheduleDetailScreen({
    required this.role,
    required this.scheduleId,
    super.key,
  });
  final ParticipantRole role;
  final int scheduleId;
  @override
  Widget build(BuildContext context, WidgetRef ref) => ref
      .watch(paymentScheduleProvider((role: role, id: scheduleId)))
      .when(
        loading: () => const Scaffold(body: AppLoadingIndicator()),
        error: (error, stack) =>
            Scaffold(body: AppErrorState(message: apiErrorMessage(error))),
        data: (schedule) => Scaffold(
          appBar: AppBar(
            leading: const DashboardBackButton(),
            title: const Text('Payment schedule'),
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                schedule.className,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              ListTile(
                title: const Text('Required amount'),
                trailing: Text(formatMyCurrency(schedule.requiredAmount)),
              ),
              ListTile(
                title: const Text('Period'),
                subtitle: Text(
                  '${_date(context, schedule.periodStart)} - ${_date(context, schedule.periodEnd)}',
                ),
              ),
              ListTile(
                title: const Text('Due date'),
                trailing: Text(_date(context, schedule.dueDate)),
              ),
              ListTile(
                title: const Text('Status'),
                trailing: Chip(label: Text(schedule.status)),
              ),
              const SizedBox(height: 16),
              if (schedule.isPaid)
                const AppEmptyState(
                  title: 'Paid',
                  message: 'This payment schedule is already paid.',
                  icon: Icons.check_circle_outline,
                )
              else
                AppButton(
                  label: 'Make payment',
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          MakePaymentScreen(role: role, schedule: schedule),
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
}

class MakePaymentScreen extends ConsumerStatefulWidget {
  const MakePaymentScreen({
    required this.role,
    required this.schedule,
    super.key,
  });
  final ParticipantRole role;
  final ParticipantPaymentSchedule schedule;
  @override
  ConsumerState<MakePaymentScreen> createState() => _MakePaymentScreenState();
}

class _MakePaymentScreenState extends ConsumerState<MakePaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _infaq = TextEditingController(text: '0');
  var _method = 'manual';
  var _loading = false;
  String? _error;
  @override
  void dispose() {
    _infaq.dispose();
    super.dispose();
  }

  Future<void> _pay() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final payment = await ref
          .read(participantPaymentRepositoryProvider)
          .makePayment(
            widget.role,
            widget.schedule.id,
            additionalInfaq: num.parse(_infaq.text),
            paymentMethod: _method,
          );
      if (mounted)
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => PaymentResultScreen(payment: payment),
          ),
        );
    } on ApiException catch (error) {
      if (mounted) setState(() => _error = error.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final options = widget.schedule.options;
    return Scaffold(
      appBar: AppBar(
        leading: const DashboardBackButton(),
        title: const Text('Make payment'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            title: const Text('Required amount'),
            trailing: Text(formatMyCurrency(widget.schedule.requiredAmount)),
          ),
          const ListTile(
            title: Text('Total amount'),
            subtitle: Text('Calculated by the backend after submission.'),
          ),
          if (options.allowAdditionalInfaq)
            Form(
              key: _formKey,
              child: TextFormField(
                controller: _infaq,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(
                  labelText: 'Additional infaq (${options.currency})',
                  helperText:
                      'Allowed: ${options.minimumInfaq ?? 0} to ${options.maximumInfaq ?? 'no limit'}',
                ),
                validator: (value) {
                  final amount = num.tryParse(value ?? '');
                  if (amount == null || amount < 0)
                    return 'Enter a non-negative amount.';
                  if (options.minimumInfaq != null &&
                      amount < options.minimumInfaq!)
                    return 'Minimum infaq is ${options.minimumInfaq}.';
                  if (options.maximumInfaq != null &&
                      amount > options.maximumInfaq!)
                    return 'Maximum infaq is ${options.maximumInfaq}.';
                  return null;
                },
              ),
            )
          else
            const SizedBox(),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            initialValue: _method,
            decoration: const InputDecoration(labelText: 'Payment method'),
            items: const [
              DropdownMenuItem(value: 'manual', child: Text('Manual')),
              DropdownMenuItem(
                value: 'bank_transfer',
                child: Text('Bank transfer'),
              ),
              DropdownMenuItem(value: 'qr', child: Text('QR')),
              DropdownMenuItem(value: 'merchant', child: Text('Merchant')),
            ],
            onChanged: (value) => setState(() => _method = value!),
          ),
          const SizedBox(height: 12),
          _Instructions(method: _method, options: options),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(
                _error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          const SizedBox(height: 20),
          AppButton(label: 'Continue', isLoading: _loading, onPressed: _pay),
        ],
      ),
    );
  }
}

class _Instructions extends StatelessWidget {
  const _Instructions({required this.method, required this.options});
  final String method;
  final PaymentOptions options;
  @override
  Widget build(BuildContext context) => switch (method) {
    'bank_transfer' => Text(
      'Transfer to ${options.bankName ?? '-'}\n${options.bankAccountName ?? '-'}\n${options.bankAccountNumber ?? '-'}',
    ),
    'qr' => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Scan the QR code using your banking app.'),
        if (options.qrCodeUrl != null)
          Image.network(
            options.qrCodeUrl!,
            height: 180,
            errorBuilder: (_, __, ___) => const Text('QR image unavailable.'),
          ),
      ],
    ),
    'merchant' => const Text(
      'Your merchant payment will be initiated after submission.',
    ),
    _ => const Text('Submit payment details for confirmation.'),
  };
}

class PaymentConfirmationScreen extends StatelessWidget {
  const PaymentConfirmationScreen({
    required this.schedule,
    required this.paymentMethod,
    super.key,
  });
  final ParticipantPaymentSchedule schedule;
  final String paymentMethod;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      leading: const DashboardBackButton(),
      title: const Text('Confirm payment'),
    ),
    body: Center(child: Text('${schedule.className}\n$paymentMethod')),
  );
}

class PaymentResultScreen extends StatelessWidget {
  const PaymentResultScreen({required this.payment, super.key});
  final ParticipantPayment payment;
  @override
  Widget build(BuildContext context) {
    final initiated =
        payment.status == 'initiated' || payment.status == 'merchant';
    final pending =
        payment.status == 'pending' ||
        payment.status == 'manual' ||
        payment.status == 'bank_transfer' ||
        payment.status == 'qr';
    return Scaffold(
      appBar: AppBar(
        leading: const DashboardBackButton(),
        title: const Text('Payment result'),
      ),
      body: AppEmptyState(
        title: initiated
            ? 'Payment initiated'
            : pending
            ? 'Payment pending'
            : payment.status,
        message:
            payment.message ??
            (pending
                ? 'Your payment is awaiting confirmation.'
                : 'Payment status returned by the backend.'),
        icon: initiated ? Icons.open_in_new : Icons.pending_outlined,
      ),
    );
  }
}

String _date(BuildContext context, DateTime? value) => value == null
    ? '-'
    : MaterialLocalizations.of(context).formatShortDate(value);
