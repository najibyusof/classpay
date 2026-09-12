import 'package:classpay/core/errors/api_error_message.dart';
import 'package:classpay/core/widgets/async_states.dart';
import 'package:classpay/providers/class_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class AdminClassesScreen extends ConsumerStatefulWidget {
  const AdminClassesScreen({required this.organizationId, super.key});
  final int organizationId;
  @override
  ConsumerState<AdminClassesScreen> createState() => _AdminClassesScreenState();
}

class _AdminClassesScreenState extends ConsumerState<AdminClassesScreen> {
  var _page = 1;
  @override
  Widget build(BuildContext context) {
    final filter = ClassListFilter(
      organizationId: widget.organizationId,
      page: _page,
    );
    final classes = ref.watch(classesProvider(filter));
    return Scaffold(
      appBar: AppBar(title: const Text('Classes')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(
          '/admin/organizations/${widget.organizationId}/classes/new',
        ),
        icon: const Icon(Icons.add),
        label: const Text('Add'),
      ),
      body: classes.when(
        loading: () => const AppLoadingIndicator(message: 'Loading classes...'),
        error: (error, stackTrace) => AppErrorState(
          message: apiErrorMessage(error),
          onRetry: () => ref.invalidate(classesProvider(filter)),
        ),
        data: (result) => result.items.isEmpty
            ? const AppEmptyState(
                title: 'No classes',
                message: 'Add a class to get started.',
                icon: Icons.class_outlined,
              )
            : RefreshIndicator(
                onRefresh: () async => ref.invalidate(classesProvider(filter)),
                child: ListView(
                  children: [
                    for (final classRecord in result.items)
                      ListTile(
                        leading: const CircleAvatar(
                          child: Icon(Icons.class_outlined),
                        ),
                        title: Text(classRecord.name),
                        subtitle: Text(
                          '${classRecord.teacherName.isEmpty ? 'No teacher' : classRecord.teacherName}\n${_dateRange(context, classRecord.startDate, classRecord.endDate)} | ${classRecord.participantCount} participants',
                        ),
                        isThreeLine: true,
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Chip(label: Text(classRecord.status)),
                            Icon(
                              classRecord.hasPaymentConfiguration
                                  ? Icons.payments_outlined
                                  : Icons.payments_outlined,
                              color: classRecord.hasPaymentConfiguration
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(context).colorScheme.outline,
                            ),
                          ],
                        ),
                        onTap: () =>
                            context.push('/admin/classes/${classRecord.id}'),
                      ),
                    if (result.lastPage > 1)
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            OutlinedButton(
                              onPressed: _page > 1
                                  ? () => setState(() => _page--)
                                  : null,
                              child: const Text('Previous'),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              child: Text('Page $_page of ${result.lastPage}'),
                            ),
                            OutlinedButton(
                              onPressed: result.hasNextPage
                                  ? () => setState(() => _page++)
                                  : null,
                              child: const Text('Next'),
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

  String _dateRange(BuildContext context, DateTime? start, DateTime? end) =>
      start == null || end == null
      ? 'Dates not set'
      : '${MaterialLocalizations.of(context).formatShortDate(start)} - ${MaterialLocalizations.of(context).formatShortDate(end)}';
}
