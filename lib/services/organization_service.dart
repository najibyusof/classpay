import 'package:classpay/core/network/api_client.dart';
import 'package:classpay/core/network/pagination.dart';
import 'package:classpay/models/organization.dart';

class OrganizationService {
  const OrganizationService(this._apiClient);
  final ApiClient _apiClient;
  static const _basePath = '/admin/organizations';

  Future<PaginatedResponse<Organization>> list({
    Map<String, dynamic>? queryParameters,
  }) async {
    final response = await _apiClient.get<PaginatedResponse<Organization>>(
      _basePath,
      queryParameters: queryParameters,
      fromJson: (json) =>
          PaginatedResponse.fromJson(json, itemFromJson: Organization.fromJson),
    );
    return response.data;
  }

  Future<Organization> get(int organizationId) async {
    final response = await _apiClient.get<Organization>(
      '$_basePath/$organizationId',
      fromJson: Organization.fromJson,
    );
    return response.data;
  }

  Future<Organization> create(Organization organization) async {
    final response = await _apiClient.post<Organization>(
      _basePath,
      data: organization.toRequestJson(),
      fromJson: Organization.fromJson,
    );
    return response.data;
  }

  Future<Organization> update(Organization organization) async {
    final response = await _apiClient.put<Organization>(
      '$_basePath/${organization.id}',
      data: organization.toRequestJson(),
      fromJson: Organization.fromJson,
    );
    return response.data;
  }

  Future<void> delete(int organizationId) =>
      _apiClient.delete<void>('$_basePath/$organizationId', fromJson: (_) {});
  Future<List<OrganizationAdministrator>> listAdministrators(
    int organizationId,
  ) async {
    final response = await _apiClient.get<List<OrganizationAdministrator>>(
      '$_basePath/$organizationId/admins',
      fromJson: (json) => (json as List<dynamic>? ?? const [])
          .map(OrganizationAdministrator.fromJson)
          .toList(growable: false),
    );
    return response.data;
  }

  Future<void> addAdministrator(int organizationId, int userId) =>
      _apiClient.post<void>(
        '$_basePath/$organizationId/admins',
        data: {'user_id': userId},
        fromJson: (_) {},
      );
  Future<void> updateAdministrator(
    int organizationId,
    int userId,
    Map<String, dynamic> data,
  ) => _apiClient.put<void>(
    '$_basePath/$organizationId/admins/$userId',
    data: data,
    fromJson: (_) {},
  );
  Future<void> removeAdministrator(int organizationId, int userId) =>
      _apiClient.delete<void>(
        '$_basePath/$organizationId/admins/$userId',
        fromJson: (_) {},
      );
}
