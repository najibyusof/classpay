import 'package:classpay/core/errors/api_error_message.dart';
import 'package:classpay/core/errors/api_exception.dart';
import 'package:classpay/core/widgets/async_states.dart';
import 'package:classpay/models/organization.dart';
import 'package:classpay/providers/organization_provider.dart';
import 'package:classpay/repositories/organization_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OrganizationAdminsScreen extends ConsumerWidget {
  const OrganizationAdminsScreen({required this.organizationId, super.key});
  final int organizationId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final administrators = ref.watch(
      organizationAdministratorsProvider(organizationId),
    );
    return Scaffold(
      appBar: AppBar(title: const Text('Organization administrators')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addAdministrator(context, ref),
        icon: const Icon(Icons.person_add_alt_1),
        label: const Text('Add'),
      ),
      body: administrators.when(
        loading: () =>
            const AppLoadingIndicator(message: 'Loading administrators...'),
        error: (error, stackTrace) => AppErrorState(
          message: apiErrorMessage(error),
          onRetry: () => ref.invalidate(
            organizationAdministratorsProvider(organizationId),
          ),
        ),
        data: (admins) => admins.isEmpty
            ? const AppEmptyState(
                title: 'No administrators',
                message: 'Add an administrator to manage this organization.',
                icon: Icons.admin_panel_settings_outlined,
              )
            : RefreshIndicator(
                onRefresh: () async => ref.invalidate(
                  organizationAdministratorsProvider(organizationId),
                ),
                child: ListView(
                  children: [
                    for (final admin in admins)
                      _AdministratorTile(
                        organizationId: organizationId,
                        administrator: admin,
                      ),
                  ],
                ),
              ),
      ),
    );
  }

  Future<void> _addAdministrator(BuildContext context, WidgetRef ref) async {
    final controller = TextEditingController();
    final userId = await showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add administrator'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'User ID'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.pop(context, int.tryParse(controller.text)),
            child: const Text('Add'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (userId == null) return;
    try {
      await ref
          .read(organizationRepositoryProvider)
          .addAdministrator(organizationId, userId);
      ref.invalidate(organizationAdministratorsProvider(organizationId));
    } on ApiException catch (error) {
      if (context.mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.message)));
    }
  }
}

class _AdministratorTile extends ConsumerWidget {
  const _AdministratorTile({
    required this.organizationId,
    required this.administrator,
  });
  final int organizationId;
  final OrganizationAdministrator administrator;

  @override
  Widget build(BuildContext context, WidgetRef ref) => ListTile(
    leading: CircleAvatar(
      child: Text(
        administrator.name.isEmpty ? '?' : administrator.name[0].toUpperCase(),
      ),
    ),
    title: Text(administrator.name),
    subtitle: Text(
      '${administrator.phone}${administrator.email == null ? '' : '\n${administrator.email}'}',
    ),
    isThreeLine: administrator.email != null,
    trailing: PopupMenuButton<String>(
      onSelected: (action) => _performAction(context, ref, action),
      itemBuilder: (context) => [
        if (!administrator.isPrimary)
          const PopupMenuItem(
            value: 'primary',
            child: Text('Promote to primary'),
          ),
        PopupMenuItem(
          value: administrator.status == 'active' ? 'inactive' : 'active',
          child: Text(
            administrator.status == 'active' ? 'Deactivate' : 'Activate',
          ),
        ),
        const PopupMenuItem(value: 'remove', child: Text('Remove')),
      ],
    ),
  );

  Future<void> _performAction(
    BuildContext context,
    WidgetRef ref,
    String action,
  ) async {
    try {
      final repository = ref.read(organizationRepositoryProvider);
      if (action == 'remove') {
        await repository.removeAdministrator(organizationId, administrator.id);
      } else if (action == 'primary') {
        await repository.updateAdministrator(organizationId, administrator.id, {
          'is_primary': true,
        });
      } else {
        await repository.updateAdministrator(organizationId, administrator.id, {
          'status': action,
        });
      }
      ref.invalidate(organizationAdministratorsProvider(organizationId));
    } on ApiException catch (error) {
      if (context.mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.message)));
    }
  }
}
