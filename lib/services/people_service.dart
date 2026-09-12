import 'package:classpay/core/network/api_client.dart';
import 'package:classpay/core/network/pagination.dart';
import 'package:classpay/models/managed_user.dart';

enum ManagedUserKind { student, sponsor }

class PeopleService {
  const PeopleService(this._apiClient);
  final ApiClient _apiClient;
  String _path(ManagedUserKind kind) => '/admin/${kind.name}s';

  Future<PaginatedResponse<ManagedUser>> list(
    ManagedUserKind kind, {
    Map<String, dynamic>? query,
  }) async {
    final response = await _apiClient.get<PaginatedResponse<ManagedUser>>(
      _path(kind),
      queryParameters: query,
      fromJson: (json) =>
          PaginatedResponse.fromJson(json, itemFromJson: ManagedUser.fromJson),
    );
    return response.data;
  }

  Future<ManagedUser> get(ManagedUserKind kind, int id) async {
    final response = await _apiClient.get<ManagedUser>(
      '${_path(kind)}/$id',
      fromJson: ManagedUser.fromJson,
    );
    return response.data;
  }

  Future<ManagedUser> create(ManagedUserKind kind, ManagedUser user) async {
    final response = await _apiClient.post<ManagedUser>(
      _path(kind),
      data: user.toRequestJson(),
      fromJson: ManagedUser.fromJson,
    );
    return response.data;
  }

  Future<ManagedUser> update(ManagedUserKind kind, ManagedUser user) async {
    final response = await _apiClient.put<ManagedUser>(
      '${_path(kind)}/${user.id}',
      data: user.toRequestJson(),
      fromJson: ManagedUser.fromJson,
    );
    return response.data;
  }

  Future<void> delete(ManagedUserKind kind, int id) =>
      _apiClient.delete<void>('${_path(kind)}/$id', fromJson: (_) {});

  Future<List<ClassParticipant>> participants(int classId) async {
    final response = await _apiClient.get<List<ClassParticipant>>(
      '/admin/classes/$classId/participants',
      fromJson: (json) => (json as List<dynamic>? ?? const [])
          .map(ClassParticipant.fromJson)
          .toList(growable: false),
    );
    return response.data;
  }

  Future<void> addParticipant(
    int classId, {
    required int userId,
    required String participantType,
  }) => _apiClient.post<void>(
    '/admin/classes/$classId/participants',
    data: {'user_id': userId, 'participant_type': participantType},
    fromJson: (_) {},
  );
  Future<void> updateParticipant(
    int classId,
    int participantId, {
    required String status,
  }) => _apiClient.put<void>(
    '/admin/classes/$classId/participants/$participantId',
    data: {'status': status},
    fromJson: (_) {},
  );
  Future<void> removeParticipant(int classId, int participantId) =>
      _apiClient.delete<void>(
        '/admin/classes/$classId/participants/$participantId',
        fromJson: (_) {},
      );

  Future<List<SponsorStudentRelationship>> sponsorStudents(
    int sponsorId,
  ) async {
    final response = await _apiClient.get<List<SponsorStudentRelationship>>(
      '/admin/sponsors/$sponsorId/students',
      fromJson: (json) => (json as List<dynamic>? ?? const [])
          .map(SponsorStudentRelationship.fromJson)
          .toList(growable: false),
    );
    return response.data;
  }

  Future<void> addSponsorStudent(
    int sponsorId, {
    required int studentId,
    required String relationshipType,
  }) => _apiClient.post<void>(
    '/admin/sponsors/$sponsorId/students',
    data: {'student_id': studentId, 'relationship_type': relationshipType},
    fromJson: (_) {},
  );
  Future<void> removeSponsorStudent(int sponsorId, int studentId) =>
      _apiClient.delete<void>(
        '/admin/sponsors/$sponsorId/students/$studentId',
        fromJson: (_) {},
      );
}
