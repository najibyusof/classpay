import 'package:classpay/core/network/api_client.dart';
import 'package:classpay/models/dashboard_model.dart';

class DashboardService {
  const DashboardService(this._apiClient);
  final ApiClient _apiClient;

  Future<DashboardModel> fetchAdminDashboard({
    Map<String, dynamic>? queryParameters,
  }) async {
    final response = await _apiClient.get<DashboardModel>(
      '/admin/dashboard',
      queryParameters: queryParameters,
      fromJson: DashboardModel.fromJson,
    );
    return response.data;
  }
}
