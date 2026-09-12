import 'package:classpay/models/dashboard_model.dart';
import 'package:classpay/repositories/dashboard_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DashboardFilter {
  const DashboardFilter({this.startDate, this.endDate, this.recentLimit = 5});
  final DateTime? startDate;
  final DateTime? endDate;
  final int recentLimit;

  Map<String, dynamic> toQueryParameters() => {
    if (startDate != null) 'date_from': _formatDate(startDate!),
    if (endDate != null) 'date_to': _formatDate(endDate!),
    'recent_limit': recentLimit,
  };

  static String _formatDate(DateTime value) =>
      '${value.year.toString().padLeft(4, '0')}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')}';

  @override
  bool operator ==(Object other) =>
      other is DashboardFilter &&
      other.startDate == startDate &&
      other.endDate == endDate &&
      other.recentLimit == recentLimit;

  @override
  int get hashCode => Object.hash(startDate, endDate, recentLimit);
}

final adminDashboardProvider = FutureProvider.autoDispose
    .family<DashboardModel, DashboardFilter>((ref, filter) {
      return ref
          .watch(dashboardRepositoryProvider)
          .getAdminDashboard(queryParameters: filter.toQueryParameters());
    });
