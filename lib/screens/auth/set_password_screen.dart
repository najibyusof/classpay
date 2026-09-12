import 'package:classpay/providers/session_manager.dart';
import 'package:classpay/screens/auth/password_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SetPasswordScreen extends ConsumerWidget {
  const SetPasswordScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionManagerProvider);
    return PasswordForm(
      title: 'Set password',
      subtitle: 'Set a password to secure your ClassPay account.',
      submitLabel: 'Set password',
      isLoading: session.state.isLoading,
      errorMessage: session.state.errorMessage,
      onSubmit: (currentPassword, newPassword) async {
        final saved = await session.setPassword(password: newPassword);
        if (saved && context.mounted) Navigator.of(context).pop();
      },
    );
  }
}
