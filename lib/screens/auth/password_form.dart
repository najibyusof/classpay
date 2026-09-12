import 'package:classpay/core/widgets/app_button.dart';
import 'package:classpay/core/widgets/app_text_field.dart';
import 'package:flutter/material.dart';

class PasswordForm extends StatelessWidget {
  const PasswordForm({
    required this.title,
    required this.subtitle,
    required this.submitLabel,
    required this.onSubmit,
    super.key,
    this.includeCurrentPassword = false,
    this.isLoading = false,
    this.errorMessage,
  });

  final String title;
  final String subtitle;
  final String submitLabel;
  final Future<void> Function(String currentPassword, String newPassword)
  onSubmit;
  final bool includeCurrentPassword;
  final bool isLoading;
  final String? errorMessage;

  @override
  Widget build(BuildContext context) => _PasswordFormBody(
    title: title,
    subtitle: subtitle,
    submitLabel: submitLabel,
    onSubmit: onSubmit,
    includeCurrentPassword: includeCurrentPassword,
    isLoading: isLoading,
    errorMessage: errorMessage,
  );
}

class _PasswordFormBody extends StatefulWidget {
  const _PasswordFormBody({
    required this.title,
    required this.subtitle,
    required this.submitLabel,
    required this.onSubmit,
    required this.includeCurrentPassword,
    required this.isLoading,
    this.errorMessage,
  });

  final String title;
  final String subtitle;
  final String submitLabel;
  final Future<void> Function(String currentPassword, String newPassword)
  onSubmit;
  final bool includeCurrentPassword;
  final bool isLoading;
  final String? errorMessage;

  @override
  State<_PasswordFormBody> createState() => _PasswordFormBodyState();
}

class _PasswordFormBodyState extends State<_PasswordFormBody> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmationController = TextEditingController();

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmationController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    await widget.onSubmit(
      _currentPasswordController.text,
      _newPasswordController.text,
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(widget.title)),
    body: SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    widget.subtitle,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 24),
                  if (widget.includeCurrentPassword) ...[
                    AppTextField(
                      label: 'Current password',
                      controller: _currentPasswordController,
                      obscureText: true,
                      validator: (value) => value == null || value.isEmpty
                          ? 'Enter your current password.'
                          : null,
                    ),
                    const SizedBox(height: 16),
                  ],
                  AppTextField(
                    label: 'New password',
                    controller: _newPasswordController,
                    obscureText: true,
                    validator: (value) => value == null || value.length < 8
                        ? 'Use at least 8 characters.'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    label: 'Confirm new password',
                    controller: _confirmationController,
                    obscureText: true,
                    validator: (value) => value != _newPasswordController.text
                        ? 'Passwords do not match.'
                        : null,
                  ),
                  if (widget.errorMessage != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      widget.errorMessage!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  AppButton(
                    label: widget.submitLabel,
                    isLoading: widget.isLoading,
                    onPressed: _submit,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
