import 'package:classpay/core/network/pagination.dart';
import 'package:classpay/models/class_record.dart';
import 'package:classpay/repositories/class_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ClassListFilter {
  const ClassListFilter({required this.organizationId, this.page = 1});
  final int organizationId;
  final int page;
  @override
  bool operator ==(Object other) =>
      other is ClassListFilter &&
      other.organizationId == organizationId &&
      other.page == page;
  @override
  int get hashCode => Object.hash(organizationId, page);
}

final classesProvider = FutureProvider.autoDispose
    .family<PaginatedResponse<ClassRecord>, ClassListFilter>(
      (ref, filter) => ref
          .watch(classRepositoryProvider)
          .list(filter.organizationId, queryParameters: {'page': filter.page}),
    );
final classProvider = FutureProvider.autoDispose.family<ClassRecord, int>(
  (ref, id) => ref.watch(classRepositoryProvider).get(id),
);
final classSchedulesProvider = FutureProvider.autoDispose
    .family<List<ClassSchedule>, int>(
      (ref, id) => ref.watch(classRepositoryProvider).listSchedules(id),
    );
