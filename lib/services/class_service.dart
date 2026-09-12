import 'package:classpay/core/network/api_client.dart';
import 'package:classpay/core/network/pagination.dart';
import 'package:classpay/models/class_record.dart';

class ClassService {
  const ClassService(this._apiClient);
  final ApiClient _apiClient;

  Future<PaginatedResponse<ClassRecord>> list(
    int organizationId, {
    Map<String, dynamic>? queryParameters,
  }) async {
    final response = await _apiClient.get<PaginatedResponse<ClassRecord>>(
      '/organizations/$organizationId/classes',
      queryParameters: queryParameters,
      fromJson: (json) =>
          PaginatedResponse.fromJson(json, itemFromJson: ClassRecord.fromJson),
    );
    return response.data;
  }

  Future<ClassRecord> get(int classId) async {
    final response = await _apiClient.get<ClassRecord>(
      '/classes/$classId',
      fromJson: ClassRecord.fromJson,
    );
    return response.data;
  }

  Future<ClassRecord> create(
    int organizationId,
    ClassRecord classRecord,
  ) async {
    final response = await _apiClient.post<ClassRecord>(
      '/organizations/$organizationId/classes',
      data: classRecord.toRequestJson(),
      fromJson: ClassRecord.fromJson,
    );
    return response.data;
  }

  Future<ClassRecord> update(ClassRecord classRecord) async {
    final response = await _apiClient.put<ClassRecord>(
      '/classes/${classRecord.id}',
      data: classRecord.toRequestJson(),
      fromJson: ClassRecord.fromJson,
    );
    return response.data;
  }

  Future<void> patch(int classId, Map<String, dynamic> data) =>
      _apiClient.patch<void>('/classes/$classId', data: data, fromJson: (_) {});
  Future<void> delete(int classId) =>
      _apiClient.delete<void>('/classes/$classId', fromJson: (_) {});

  Future<List<ClassSchedule>> listSchedules(int classId) async {
    final response = await _apiClient.get<List<ClassSchedule>>(
      '/classes/$classId/schedules',
      fromJson: (json) => (json as List<dynamic>? ?? const [])
          .map(ClassSchedule.fromJson)
          .toList(growable: false),
    );
    return response.data;
  }

  Future<void> createSchedule(int classId, ClassSchedule schedule) =>
      _apiClient.post<void>(
        '/classes/$classId/schedules',
        data: schedule.toRequestJson(),
        fromJson: (_) {},
      );
  Future<void> updateSchedule(int scheduleId, ClassSchedule schedule) =>
      _apiClient.put<void>(
        '/class-schedules/$scheduleId',
        data: schedule.toRequestJson(),
        fromJson: (_) {},
      );
  Future<void> patchSchedule(int scheduleId, Map<String, dynamic> data) =>
      _apiClient.patch<void>(
        '/class-schedules/$scheduleId',
        data: data,
        fromJson: (_) {},
      );
  Future<void> deleteSchedule(int scheduleId) =>
      _apiClient.delete<void>('/class-schedules/$scheduleId', fromJson: (_) {});

  Future<String> activate(int classId) async {
    final response = await _apiClient.post<void>(
      '/admin/classes/$classId/activate',
      fromJson: (_) {},
    );
    return response.message;
  }
}
