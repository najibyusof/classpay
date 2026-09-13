import 'package:classpay/core/errors/api_error_message.dart';
import 'package:classpay/core/widgets/async_states.dart';
import 'package:classpay/core/widgets/app_card.dart';
import 'package:classpay/core/widgets/dashboard_back_button.dart';
import 'package:classpay/models/organization.dart';
import 'package:classpay/providers/organization_provider.dart';
import 'package:classpay/repositories/organization_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class OrganizationDetailScreen extends ConsumerWidget {
  const OrganizationDetailScreen({required this.organizationId, super.key});
  final int organizationId;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final organization = ref.watch(organizationProvider(organizationId));
    return Scaffold(
      body: organization.when(
        loading: () =>
            const AppLoadingIndicator(message: 'Loading organization...'),
        error: (error, stackTrace) => Scaffold(
          appBar: AppBar(),
          body: AppErrorState(
            message: apiErrorMessage(error),
            onRetry: () => ref.invalidate(organizationProvider(organizationId)),
          ),
        ),
        data: (data) => _OrganizationDetail(organization: data),
      ),
    );
  }
}

class _OrganizationDetail extends ConsumerWidget {
  const _OrganizationDetail({required this.organization});
  final Organization organization;
  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
    appBar: AppBar(
      leading: const DashboardBackButton(),
      title: Text(organization.name),
      actions: [
        IconButton(
          tooltip: 'Edit organization',
          icon: const Icon(Icons.edit_outlined),
          onPressed: () async {
            final message = await context.push<String>(
              '/admin/organizations/${organization.id}/edit',
            );
            if (!context.mounted || message == null) return;
            ref.invalidate(organizationProvider(organization.id));
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(message)));
          },
        ),
      ],
    ),
    body: ListView(
      padding: const EdgeInsets.all(16),
      children: [
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                organization.name,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text('Code: ${organization.code}'),
              const SizedBox(height: 8),
              Text(
                organization.description?.isNotEmpty == true
                    ? organization.description!
                    : 'No description',
              ),
              const SizedBox(height: 16),
              Chip(label: Text(organization.status)),
            ],
          ),
        ),
        const SizedBox(height: 16),
        AppCard(
          child: ListTile(
            title: const Text('Administrators'),
            subtitle: Text('${organization.administratorCount} assigned'),
            leading: const Icon(Icons.admin_panel_settings_outlined),
            trailing: const Icon(Icons.chevron_right),
            onTap: () =>
                context.push('/admin/organizations/${organization.id}/admins'),
          ),
        ),
        const SizedBox(height: 8),
        AppCard(
          child: ListTile(
            leading: const Icon(Icons.class_outlined),
            title: const Text('Classes'),
            subtitle: const Text('Manage organization classes'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () =>
                context.push('/admin/organizations/${organization.id}/classes'),
          ),
        ),
        const SizedBox(height: 24),
        OutlinedButton.icon(
          icon: Icon(
            Icons.delete_outline,
            color: Theme.of(context).colorScheme.error,
          ),
          label: const Text('Delete organization'),
          onPressed: () async {
            final confirmed = await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Delete organization?'),
                content: const Text('This action cannot be undone.'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Cancel'),
                  ),
                  FilledButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('Delete'),
                  ),
                ],
              ),
            );
            if (confirmed != true) return;
            try {
              await ref
                  .read(organizationRepositoryProvider)
                  .delete(organization.id);
              if (context.mounted) {
                context.go('/admin/organizations');
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Organization deleted')),
                );
              }
            } on Exception catch (error) {
              if (context.mounted)
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(apiErrorMessage(error))));
            }
          },
        ),
      ],
    ),
  );
}
