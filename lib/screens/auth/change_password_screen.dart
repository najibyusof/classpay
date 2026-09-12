import 'package:classpay/providers/session_manager.dart';
import 'package:classpay/screens/auth/password_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChangePasswordScreen extends ConsumerWidget {
  const ChangePasswordScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionManagerProvider);
    return PasswordForm(
      title: 'Change password',
      subtitle: 'Choose a new password for your ClassPay account.',
      submitLabel: 'Update password',
      includeCurrentPassword: true,
      isLoading: session.state.isLoading,
      errorMessage: session.state.errorMessage,
      onSubmit: (currentPassword, newPassword) async {
        final changed = await session.changePassword(
          currentPassword: currentPassword,
          newPassword: newPassword,
        );
        if (changed && context.mounted) Navigator.of(context).pop();
      },
    );
  }
}
