import 'package:classpay/core/network/api_client.dart';
import 'package:classpay/core/network/pagination.dart';
import 'package:classpay/models/organization.dart';
import 'package:classpay/services/organization_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final organizationServiceProvider = Provider<OrganizationService>(
  (ref) => OrganizationService(ref.watch(apiClientProvider)),
);
final organizationRepositoryProvider = Provider<OrganizationRepository>(
  (ref) => OrganizationRepository(ref.watch(organizationServiceProvider)),
);

class OrganizationRepository {
  const OrganizationRepository(this._service);
  final OrganizationService _service;
  Future<PaginatedResponse<Organization>> list({
    Map<String, dynamic>? queryParameters,
  }) => _service.list(queryParameters: queryParameters);
  Future<Organization> get(int organizationId) => _service.get(organizationId);
  Future<Organization> create(Organization organization) =>
      _service.create(organization);
  Future<Organization> update(Organization organization) =>
      _service.update(organization);
  Future<void> delete(int organizationId) => _service.delete(organizationId);
  Future<List<OrganizationAdministrator>> listAdministrators(
    int organizationId,
  ) => _service.listAdministrators(organizationId);
  Future<void> addAdministrator(int organizationId, int userId) =>
      _service.addAdministrator(organizationId, userId);
  Future<void> updateAdministrator(
    int organizationId,
    int userId,
    Map<String, dynamic> data,
  ) => _service.updateAdministrator(organizationId, userId, data);
  Future<void> removeAdministrator(int organizationId, int userId) =>
      _service.removeAdministrator(organizationId, userId);
}
