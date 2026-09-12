import 'package:classpay/core/network/api_client.dart';
import 'package:classpay/core/network/pagination.dart';
import 'package:classpay/models/app_notification.dart';

class NotificationService {
  const NotificationService(this._client);
  final ApiClient _client;
  Future<PaginatedResponse<AppNotification>> list({
    Map<String, dynamic>? query,
  }) async {
    final response = await _client.get<PaginatedResponse<AppNotification>>(
      '/notifications',
      queryParameters: query,
      fromJson: (json) => PaginatedResponse.fromJson(
        json,
        itemFromJson: AppNotification.fromJson,
      ),
    );
    return response.data;
  }

  Future<int> unreadCount() async {
    final response = await _client.get<int>(
      '/notifications/unread-count',
      fromJson: (json) => json is Map<String, dynamic>
          ? (json['count'] as num?)?.toInt() ?? 0
          : (json as num?)?.toInt() ?? 0,
    );
    return response.data;
  }

  Future<AppNotification> get(String id) async {
    final response = await _client.get<AppNotification>(
      '/notifications/$id',
      fromJson: AppNotification.fromJson,
    );
    return response.data;
  }

  Future<void> markRead(String id) =>
      _client.post<void>('/notifications/$id/read', fromJson: (_) {});
  Future<void> markUnread(String id) =>
      _client.post<void>('/notifications/$id/unread', fromJson: (_) {});
  Future<void> markAllRead() =>
      _client.post<void>('/notifications/read-all', fromJson: (_) {});
}
