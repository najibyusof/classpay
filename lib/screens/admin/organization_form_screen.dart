import 'package:classpay/core/errors/api_error_message.dart';
import 'package:classpay/core/errors/api_exception.dart';
import 'package:classpay/core/widgets/app_button.dart';
import 'package:classpay/core/widgets/app_text_field.dart';
import 'package:classpay/core/widgets/async_states.dart';
import 'package:classpay/models/organization.dart';
import 'package:classpay/providers/organization_provider.dart';
import 'package:classpay/repositories/organization_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OrganizationFormScreen extends ConsumerWidget {
  const OrganizationFormScreen({super.key, this.organizationId});
  final int? organizationId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (organizationId == null) return const _OrganizationForm();
    return ref
        .watch(organizationProvider(organizationId!))
        .when(
          loading: () => const Scaffold(
            body: AppLoadingIndicator(message: 'Loading organization...'),
          ),
          error: (error, stackTrace) => Scaffold(
            appBar: AppBar(),
            body: AppErrorState(message: apiErrorMessage(error)),
          ),
          data: (organization) => _OrganizationForm(organization: organization),
        );
  }
}

class _OrganizationForm extends ConsumerStatefulWidget {
  const _OrganizationForm({this.organization});
  final Organization? organization;
  @override
  ConsumerState<_OrganizationForm> createState() => _OrganizationFormState();
}

class _OrganizationFormState extends ConsumerState<_OrganizationForm> {
  final _formKey = GlobalKey<FormState>();
  late final _nameController = TextEditingController(
    text: widget.organization?.name,
  );
  late final _codeController = TextEditingController(
    text: widget.organization?.code,
  );
  late final _descriptionController = TextEditingController(
    text: widget.organization?.description,
  );
  late String _status = widget.organization?.status.isNotEmpty == true
      ? widget.organization!.status
      : 'active';
  ApiException? _error;
  var _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _error = null;
      _isSubmitting = true;
    });
    final organization = Organization(
      id: widget.organization?.id ?? 0,
      name: _nameController.text.trim(),
      code: _codeController.text.trim(),
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      status: _status,
    );
    try {
      final repository = ref.read(organizationRepositoryProvider);
      if (widget.organization == null) {
        await repository.create(organization);
      } else {
        await repository.update(organization);
      }
      if (mounted) Navigator.of(context).pop();
    } on ApiException catch (error) {
      if (mounted) setState(() => _error = error);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(
        widget.organization == null ? 'Add organization' : 'Edit organization',
      ),
    ),
    body: SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppTextField(
                    label: 'Name',
                    controller: _nameController,
                    errorText: validationErrorFor(_error, 'name'),
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'Enter the organization name.'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    label: 'Code',
                    controller: _codeController,
                    errorText: validationErrorFor(_error, 'code'),
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'Enter the organization code.'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    label: 'Description',
                    controller: _descriptionController,
                    maxLines: 3,
                    errorText: validationErrorFor(_error, 'description'),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: _status,
                    decoration: InputDecoration(
                      labelText: 'Status',
                      errorText: validationErrorFor(_error, 'status'),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'active', child: Text('Active')),
                      DropdownMenuItem(
                        value: 'inactive',
                        child: Text('Inactive'),
                      ),
                    ],
                    onChanged: (value) => setState(() => _status = value!),
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      _error!.message,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  AppButton(
                    label: widget.organization == null
                        ? 'Create organization'
                        : 'Save changes',
                    isLoading: _isSubmitting,
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
