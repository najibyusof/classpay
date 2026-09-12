import 'package:classpay/core/network/api_client.dart';
import 'package:classpay/core/network/pagination.dart';
import 'package:classpay/models/class_record.dart';
import 'package:classpay/services/class_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final classServiceProvider = Provider<ClassService>(
  (ref) => ClassService(ref.watch(apiClientProvider)),
);
final classRepositoryProvider = Provider<ClassRepository>(
  (ref) => ClassRepository(ref.watch(classServiceProvider)),
);

class ClassRepository {
  const ClassRepository(this._service);
  final ClassService _service;
  Future<PaginatedResponse<ClassRecord>> list(
    int organizationId, {
    Map<String, dynamic>? queryParameters,
  }) => _service.list(organizationId, queryParameters: queryParameters);
  Future<ClassRecord> get(int classId) => _service.get(classId);
  Future<ClassRecord> create(int organizationId, ClassRecord classRecord) =>
      _service.create(organizationId, classRecord);
  Future<ClassRecord> update(ClassRecord classRecord) =>
      _service.update(classRecord);
  Future<void> patch(int classId, Map<String, dynamic> data) =>
      _service.patch(classId, data);
  Future<void> delete(int classId) => _service.delete(classId);
  Future<List<ClassSchedule>> listSchedules(int classId) =>
      _service.listSchedules(classId);
  Future<void> createSchedule(int classId, ClassSchedule schedule) =>
      _service.createSchedule(classId, schedule);
  Future<void> updateSchedule(int scheduleId, ClassSchedule schedule) =>
      _service.updateSchedule(scheduleId, schedule);
  Future<void> patchSchedule(int scheduleId, Map<String, dynamic> data) =>
      _service.patchSchedule(scheduleId, data);
  Future<void> deleteSchedule(int scheduleId) =>
      _service.deleteSchedule(scheduleId);
  Future<String> activate(int classId) => _service.activate(classId);
}
