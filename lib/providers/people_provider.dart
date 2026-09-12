import 'package:classpay/core/network/pagination.dart';
import 'package:classpay/models/managed_user.dart';
import 'package:classpay/repositories/people_repository.dart';
import 'package:classpay/services/people_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PeopleFilter {
  const PeopleFilter({required this.kind, this.search = '', this.page = 1});
  final ManagedUserKind kind;
  final String search;
  final int page;
  Map<String, dynamic> get query => {
    if (search.isNotEmpty) 'search': search,
    'page': page,
  };
  @override
  bool operator ==(Object other) =>
      other is PeopleFilter &&
      other.kind == kind &&
      other.search == search &&
      other.page == page;
  @override
  int get hashCode => Object.hash(kind, search, page);
}

final peopleProvider = FutureProvider.autoDispose
    .family<PaginatedResponse<ManagedUser>, PeopleFilter>(
      (ref, filter) => ref
          .watch(peopleRepositoryProvider)
          .list(filter.kind, query: filter.query),
    );
final personProvider = FutureProvider.autoDispose
    .family<ManagedUser, ({ManagedUserKind kind, int id})>(
      (ref, value) =>
          ref.watch(peopleRepositoryProvider).get(value.kind, value.id),
    );
final participantsProvider = FutureProvider.autoDispose
    .family<List<ClassParticipant>, int>(
      (ref, id) => ref.watch(peopleRepositoryProvider).participants(id),
    );
final sponsorStudentsProvider = FutureProvider.autoDispose
    .family<List<SponsorStudentRelationship>, int>(
      (ref, id) => ref.watch(peopleRepositoryProvider).sponsorStudents(id),
    );
