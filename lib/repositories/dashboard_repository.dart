import 'package:classpay/core/network/api_client.dart';
import 'package:classpay/models/dashboard_model.dart';
import 'package:classpay/services/dashboard_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final dashboardServiceProvider = Provider<DashboardService>(
  (ref) => DashboardService(ref.watch(apiClientProvider)),
);
final dashboardRepositoryProvider = Provider<DashboardRepository>(
  (ref) => DashboardRepository(ref.watch(dashboardServiceProvider)),
);

class DashboardRepository {
  const DashboardRepository(this._service);
  final DashboardService _service;

  Future<DashboardModel> getAdminDashboard({
    Map<String, dynamic>? queryParameters,
  }) => _service.fetchAdminDashboard(queryParameters: queryParameters);
}
