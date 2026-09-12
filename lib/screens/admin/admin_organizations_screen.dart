import 'package:classpay/core/errors/api_error_message.dart';
import 'package:classpay/core/network/pagination.dart';
import 'package:classpay/core/widgets/async_states.dart';
import 'package:classpay/models/organization.dart';
import 'package:classpay/providers/organization_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class AdminOrganizationsScreen extends ConsumerStatefulWidget {
  const AdminOrganizationsScreen({super.key});
  @override
  ConsumerState<AdminOrganizationsScreen> createState() =>
      _AdminOrganizationsScreenState();
}

class _AdminOrganizationsScreenState
    extends ConsumerState<AdminOrganizationsScreen> {
  final _searchController = TextEditingController();
  OrganizationListFilter _filter = const OrganizationListFilter();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _updateFilter({String? status, int? page, bool replaceStatus = false}) =>
      setState(
        () => _filter = OrganizationListFilter(
          search: _searchController.text.trim(),
          status: replaceStatus ? status : _filter.status,
          page: page ?? 1,
        ),
      );

  @override
  Widget build(BuildContext context) {
    final organizations = ref.watch(organizationsProvider(_filter));
    return Scaffold(
      appBar: AppBar(title: const Text('Organizations')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/admin/organizations/new'),
        icon: const Icon(Icons.add),
        label: const Text('Add'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onSubmitted: (_) => _updateFilter(),
                    decoration: const InputDecoration(
                      labelText: 'Search organizations',
                      prefixIcon: Icon(Icons.search),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                DropdownButton<String?>(
                  value: _filter.status,
                  hint: const Text('Status'),
                  items: const [
                    DropdownMenuItem(value: null, child: Text('All')),
                    DropdownMenuItem(value: 'active', child: Text('Active')),
                    DropdownMenuItem(
                      value: 'inactive',
                      child: Text('Inactive'),
                    ),
                  ],
                  onChanged: (status) =>
                      _updateFilter(status: status, replaceStatus: true),
                ),
              ],
            ),
          ),
          Expanded(
            child: organizations.when(
              loading: () => const AppLoadingIndicator(
                message: 'Loading organizations...',
              ),
              error: (error, stackTrace) => AppErrorState(
                message: apiErrorMessage(error),
                onRetry: () => ref.invalidate(organizationsProvider(_filter)),
              ),
              data: (page) => RefreshIndicator(
                onRefresh: () async =>
                    ref.invalidate(organizationsProvider(_filter)),
                child: _OrganizationList(
                  page: page,
                  onPage: (page) => _updateFilter(page: page),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OrganizationList extends StatelessWidget {
  const _OrganizationList({required this.page, required this.onPage});
  final PaginatedResponse<Organization> page;
  final ValueChanged<int> onPage;
  @override
  Widget build(BuildContext context) {
    if (page.items.isEmpty)
      return const AppEmptyState(
        title: 'No organizations',
        message: 'Try changing the search or status filter.',
        icon: Icons.account_balance_outlined,
      );
    return ListView(
      children: [
        for (final organization in page.items)
          ListTile(
            leading: CircleAvatar(
              child: Text(
                organization.name.isEmpty
                    ? '?'
                    : organization.name[0].toUpperCase(),
              ),
            ),
            title: Text(organization.name),
            subtitle: Text(
              '${organization.code} | ${organization.administratorCount} administrators',
            ),
            trailing: Chip(label: Text(organization.status)),
            onTap: () =>
                context.push('/admin/organizations/${organization.id}'),
          ),
        if (page.lastPage > 1)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton(
                  onPressed: page.currentPage > 1
                      ? () => onPage(page.currentPage - 1)
                      : null,
                  child: const Text('Previous'),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text('Page ${page.currentPage} of ${page.lastPage}'),
                ),
                OutlinedButton(
                  onPressed: page.hasNextPage
                      ? () => onPage(page.currentPage + 1)
                      : null,
                  child: const Text('Next'),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
