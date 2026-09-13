import 'package:classpay/core/errors/api_error_message.dart';
import 'package:classpay/core/errors/api_exception.dart';
import 'package:classpay/core/widgets/app_button.dart';
import 'package:classpay/core/widgets/app_text_field.dart';
import 'package:classpay/core/widgets/async_states.dart';
import 'package:classpay/core/widgets/dashboard_back_button.dart';
import 'package:classpay/models/class_record.dart';
import 'package:classpay/providers/class_provider.dart';
import 'package:classpay/repositories/class_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ClassFormScreen extends ConsumerWidget {
  const ClassFormScreen({
    required this.organizationId,
    super.key,
    this.classId,
  });
  final int organizationId;
  final int? classId;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (classId == null) return _ClassForm(organizationId: organizationId);
    return ref
        .watch(classProvider(classId!))
        .when(
          loading: () => const Scaffold(body: AppLoadingIndicator()),
          error: (error, stackTrace) =>
              Scaffold(body: AppErrorState(message: apiErrorMessage(error))),
          data: (item) =>
              _ClassForm(organizationId: organizationId, classRecord: item),
        );
  }
}

class _ClassForm extends ConsumerStatefulWidget {
  const _ClassForm({required this.organizationId, this.classRecord});
  final int organizationId;
  final ClassRecord? classRecord;
  @override
  ConsumerState<_ClassForm> createState() => _ClassFormState();
}

class _ClassFormState extends ConsumerState<_ClassForm> {
  final _formKey = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.classRecord?.name);
  late final _description = TextEditingController(
    text: widget.classRecord?.description,
  );
  late final _teacher = TextEditingController(
    text: widget.classRecord?.teacherName,
  );
  late DateTime? _start = widget.classRecord?.startDate;
  late DateTime? _end = widget.classRecord?.endDate;
  late String _status = widget.classRecord?.status.isNotEmpty == true
      ? widget.classRecord!.status
      : 'inactive';
  ApiException? _error;
  var _loading = false;
  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    _teacher.dispose();
    super.dispose();
  }

  Future<void> _pickDate(bool isStart) async {
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      initialDate: (isStart ? _start : _end) ?? DateTime.now(),
    );
    if (picked == null) return;
    setState(() {
      if (isStart) {
        _start = picked;
      } else {
        _end = picked;
      }
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    final value = ClassRecord(
      id: widget.classRecord?.id ?? 0,
      organizationId: widget.organizationId,
      name: _name.text.trim(),
      description: _description.text.trim().isEmpty
          ? null
          : _description.text.trim(),
      teacherName: _teacher.text.trim(),
      startDate: _start,
      endDate: _end,
      status: _status,
      participantCount: 0,
      hasPaymentConfiguration: false,
    );
    try {
      if (widget.classRecord == null) {
        await ref
            .read(classRepositoryProvider)
            .create(widget.organizationId, value);
      } else {
        await ref.read(classRepositoryProvider).update(value);
      }
      if (mounted) Navigator.pop(context);
    } on ApiException catch (error) {
      if (mounted) setState(() => _error = error);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      leading: const DashboardBackButton(),
      title: Text(widget.classRecord == null ? 'Add class' : 'Edit class'),
    ),
    body: ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppTextField(
                label: 'Name',
                controller: _name,
                errorText: validationErrorFor(_error, 'name'),
                validator: (v) => v == null || v.trim().isEmpty
                    ? 'Enter the class name.'
                    : null,
              ),
              const SizedBox(height: 16),
              AppTextField(
                label: 'Description',
                controller: _description,
                maxLines: 3,
                errorText: validationErrorFor(_error, 'description'),
              ),
              const SizedBox(height: 16),
              AppTextField(
                label: 'Teacher name',
                controller: _teacher,
                errorText: validationErrorFor(_error, 'teacher_name'),
                validator: (v) => v == null || v.trim().isEmpty
                    ? 'Enter the teacher name.'
                    : null,
              ),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: () => _pickDate(true),
                child: Text(
                  _start == null
                      ? 'Select start date'
                      : MaterialLocalizations.of(
                          context,
                        ).formatShortDate(_start!),
                ),
              ),
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: () => _pickDate(false),
                child: Text(
                  _end == null
                      ? 'Select end date'
                      : MaterialLocalizations.of(
                          context,
                        ).formatShortDate(_end!),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _status,
                decoration: InputDecoration(
                  labelText: 'Status',
                  errorText: validationErrorFor(_error, 'status'),
                ),
                items: const [
                  DropdownMenuItem(value: 'inactive', child: Text('Inactive')),
                  DropdownMenuItem(value: 'active', child: Text('Active')),
                ],
                onChanged: (value) => setState(() => _status = value!),
              ),
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Text(
                    _error!.message,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
              const SizedBox(height: 24),
              AppButton(
                label: widget.classRecord == null
                    ? 'Create class'
                    : 'Save changes',
                isLoading: _loading,
                onPressed: _submit,
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
