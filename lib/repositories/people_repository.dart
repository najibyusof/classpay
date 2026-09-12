import 'package:classpay/core/network/api_client.dart';
import 'package:classpay/core/network/pagination.dart';
import 'package:classpay/models/managed_user.dart';
import 'package:classpay/services/people_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final peopleServiceProvider = Provider<PeopleService>(
  (ref) => PeopleService(ref.watch(apiClientProvider)),
);
final peopleRepositoryProvider = Provider<PeopleRepository>(
  (ref) => PeopleRepository(ref.watch(peopleServiceProvider)),
);

class PeopleRepository {
  const PeopleRepository(this._service);
  final PeopleService _service;
  Future<PaginatedResponse<ManagedUser>> list(
    ManagedUserKind kind, {
    Map<String, dynamic>? query,
  }) => _service.list(kind, query: query);
  Future<ManagedUser> get(ManagedUserKind kind, int id) =>
      _service.get(kind, id);
  Future<ManagedUser> create(ManagedUserKind kind, ManagedUser user) =>
      _service.create(kind, user);
  Future<ManagedUser> update(ManagedUserKind kind, ManagedUser user) =>
      _service.update(kind, user);
  Future<void> delete(ManagedUserKind kind, int id) =>
      _service.delete(kind, id);
  Future<List<ClassParticipant>> participants(int id) =>
      _service.participants(id);
  Future<void> addParticipant(
    int id, {
    required int userId,
    required String participantType,
  }) => _service.addParticipant(
    id,
    userId: userId,
    participantType: participantType,
  );
  Future<void> updateParticipant(
    int id,
    int participantId, {
    required String status,
  }) => _service.updateParticipant(id, participantId, status: status);
  Future<void> removeParticipant(int id, int participantId) =>
      _service.removeParticipant(id, participantId);
  Future<List<SponsorStudentRelationship>> sponsorStudents(int id) =>
      _service.sponsorStudents(id);
  Future<void> addSponsorStudent(
    int id, {
    required int studentId,
    required String relationshipType,
  }) => _service.addSponsorStudent(
    id,
    studentId: studentId,
    relationshipType: relationshipType,
  );
  Future<void> removeSponsorStudent(int id, int studentId) =>
      _service.removeSponsorStudent(id, studentId);
}
