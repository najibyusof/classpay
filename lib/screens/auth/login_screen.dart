import 'package:classpay/core/widgets/app_button.dart';
import 'package:classpay/core/widgets/app_text_field.dart';
import 'package:classpay/providers/session_manager.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  var _isPasswordVisible = false;
  var _selectedAudience = 'admin';

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    await ref
        .read(sessionManagerProvider)
        .login(
          phone: _phoneController.text.trim(),
          password: _passwordController.text,
          deviceName: _deviceName,
        );
  }

  String get _deviceName => switch (defaultTargetPlatform) {
    TargetPlatform.android => 'Android Phone',
    TargetPlatform.iOS => 'iPhone',
    _ => 'ClassPay App',
  };

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(sessionManagerProvider).state;
    return Scaffold(
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
                      'ClassPay',
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Sign in to manage your education payments.',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 32),
                    SegmentedButton<String>(
                      segments: const [
                        ButtonSegment(
                          value: 'admin',
                          label: Text('Admin'),
                          icon: Icon(Icons.admin_panel_settings_outlined),
                        ),
                        ButtonSegment(
                          value: 'student-sponsor',
                          label: Text('Student-Sponsor'),
                          icon: Icon(Icons.person_outline),
                        ),
                      ],
                      selected: {_selectedAudience},
                      onSelectionChanged: (selection) =>
                          setState(() => _selectedAudience = selection.first),
                    ),
                    const SizedBox(height: 24),
                    AppTextField(
                      label: 'Phone number',
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      validator: (value) =>
                          value == null || value.trim().isEmpty
                          ? 'Enter your phone number.'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      label: 'Password',
                      controller: _passwordController,
                      obscureText: !_isPasswordVisible,
                      validator: (value) => value == null || value.isEmpty
                          ? 'Enter your password.'
                          : null,
                      suffixIcon: IconButton(
                        tooltip: _isPasswordVisible
                            ? 'Hide password'
                            : 'Show password',
                        icon: Icon(
                          _isPasswordVisible
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                        ),
                        onPressed: () => setState(
                          () => _isPasswordVisible = !_isPasswordVisible,
                        ),
                      ),
                    ),
                    if (authState.errorMessage != null) ...[
                      const SizedBox(height: 16),
                      Text(
                        authState.errorMessage!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                    AppButton(
                      label: 'Sign in',
                      isLoading: authState.isLoading,
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
}
