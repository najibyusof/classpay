import 'package:classpay/core/errors/api_error_message.dart';
import 'package:classpay/core/errors/api_exception.dart';
import 'package:classpay/core/widgets/async_states.dart';
import 'package:classpay/core/widgets/dashboard_back_button.dart';
import 'package:classpay/models/class_record.dart';
import 'package:classpay/providers/class_provider.dart';
import 'package:classpay/repositories/class_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ClassScheduleScreen extends ConsumerWidget {
  const ClassScheduleScreen({required this.classId, super.key});
  final int classId;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final schedules = ref.watch(classSchedulesProvider(classId));
    return Scaffold(
      appBar: AppBar(
        leading: const DashboardBackButton(),
        title: const Text('Class schedules'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _editSchedule(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Add'),
      ),
      body: schedules.when(
        loading: () =>
            const AppLoadingIndicator(message: 'Loading schedules...'),
        error: (error, stackTrace) => AppErrorState(
          message: apiErrorMessage(error),
          onRetry: () => ref.invalidate(classSchedulesProvider(classId)),
        ),
        data: (items) => items.isEmpty
            ? const AppEmptyState(
                title: 'No schedules',
                message: 'Add a day and time for this class.',
                icon: Icons.schedule_outlined,
              )
            : RefreshIndicator(
                onRefresh: () async =>
                    ref.invalidate(classSchedulesProvider(classId)),
                child: ListView(
                  children: [
                    for (final item in items)
                      ListTile(
                        title: Text(_capitalize(item.day)),
                        subtitle: Text('${item.startTime} - ${item.endTime}'),
                        trailing: PopupMenuButton<String>(
                          onSelected: (action) => action == 'edit'
                              ? _editSchedule(context, ref, item)
                              : _deleteSchedule(context, ref, item),
                          itemBuilder: (context) => const [
                            PopupMenuItem(value: 'edit', child: Text('Edit')),
                            PopupMenuItem(
                              value: 'delete',
                              child: Text('Delete'),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
      ),
    );
  }

  static String _capitalize(String value) => value.isEmpty
      ? 'Day not set'
      : '${value[0].toUpperCase()}${value.substring(1)}';
  Future<void> _editSchedule(
    BuildContext context,
    WidgetRef ref, [
    ClassSchedule? schedule,
  ]) async {
    final result = await showDialog<ClassSchedule>(
      context: context,
      builder: (context) => _ScheduleDialog(schedule: schedule),
    );
    if (result == null) return;
    try {
      final repository = ref.read(classRepositoryProvider);
      if (schedule == null) {
        await repository.createSchedule(classId, result);
      } else {
        await repository.updateSchedule(schedule.id, result);
      }
      ref.invalidate(classSchedulesProvider(classId));
    } on ApiException catch (error) {
      if (context.mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.message)));
    }
  }

  Future<void> _deleteSchedule(
    BuildContext context,
    WidgetRef ref,
    ClassSchedule schedule,
  ) async {
    try {
      await ref.read(classRepositoryProvider).deleteSchedule(schedule.id);
      ref.invalidate(classSchedulesProvider(classId));
    } on ApiException catch (error) {
      if (context.mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.message)));
    }
  }
}

class _ScheduleDialog extends StatefulWidget {
  const _ScheduleDialog({this.schedule});
  final ClassSchedule? schedule;
  @override
  State<_ScheduleDialog> createState() => _ScheduleDialogState();
}

class _ScheduleDialogState extends State<_ScheduleDialog> {
  late String _day = widget.schedule?.day ?? 'monday';
  late final _start = TextEditingController(
    text: widget.schedule?.startTime ?? '09:00',
  );
  late final _end = TextEditingController(
    text: widget.schedule?.endTime ?? '10:00',
  );
  @override
  void dispose() {
    _start.dispose();
    _end.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(widget.schedule == null ? 'Add schedule' : 'Edit schedule'),
    content: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        DropdownButtonFormField<String>(
          initialValue: _day,
          decoration: const InputDecoration(labelText: 'Day'),
          items: const [
            DropdownMenuItem(value: 'monday', child: Text('Monday')),
            DropdownMenuItem(value: 'tuesday', child: Text('Tuesday')),
            DropdownMenuItem(value: 'wednesday', child: Text('Wednesday')),
            DropdownMenuItem(value: 'thursday', child: Text('Thursday')),
            DropdownMenuItem(value: 'friday', child: Text('Friday')),
            DropdownMenuItem(value: 'saturday', child: Text('Saturday')),
            DropdownMenuItem(value: 'sunday', child: Text('Sunday')),
          ],
          onChanged: (value) => setState(() => _day = value!),
        ),
        TextField(
          controller: _start,
          decoration: const InputDecoration(labelText: 'Start time'),
        ),
        TextField(
          controller: _end,
          decoration: const InputDecoration(labelText: 'End time'),
        ),
      ],
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancel'),
      ),
      FilledButton(
        onPressed: () => Navigator.pop(
          context,
          ClassSchedule(
            id: widget.schedule?.id ?? 0,
            day: _day,
            startTime: _start.text,
            endTime: _end.text,
          ),
        ),
        child: const Text('Save'),
      ),
    ],
  );
}
