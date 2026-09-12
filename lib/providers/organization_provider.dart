import 'package:classpay/core/network/pagination.dart';
import 'package:classpay/models/organization.dart';
import 'package:classpay/repositories/organization_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OrganizationListFilter {
  const OrganizationListFilter({this.search = '', this.status, this.page = 1});
  final String search;
  final String? status;
  final int page;
  Map<String, dynamic> toQueryParameters() => {
    if (search.isNotEmpty) 'search': search,
    if (status != null) 'status': status,
    'page': page,
  };
  @override
  bool operator ==(Object other) =>
      other is OrganizationListFilter &&
      other.search == search &&
      other.status == status &&
      other.page == page;
  @override
  int get hashCode => Object.hash(search, status, page);
}

final organizationsProvider = FutureProvider.autoDispose
    .family<PaginatedResponse<Organization>, OrganizationListFilter>(
      (ref, filter) => ref
          .watch(organizationRepositoryProvider)
          .list(queryParameters: filter.toQueryParameters()),
    );
final organizationProvider = FutureProvider.autoDispose
    .family<Organization, int>(
      (ref, id) => ref.watch(organizationRepositoryProvider).get(id),
    );
final organizationAdministratorsProvider = FutureProvider.autoDispose
    .family<List<OrganizationAdministrator>, int>(
      (ref, id) =>
          ref.watch(organizationRepositoryProvider).listAdministrators(id),
    );
