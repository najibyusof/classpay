import 'package:classpay/core/network/api_client.dart';
import 'package:classpay/core/network/pagination.dart';
import 'package:classpay/models/app_notification.dart';
import 'package:classpay/services/notification_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final notificationServiceProvider = Provider<NotificationService>(
  (ref) => NotificationService(ref.watch(apiClientProvider)),
);
final notificationRepositoryProvider = Provider<NotificationRepository>(
  (ref) => NotificationRepository(ref.watch(notificationServiceProvider)),
);

class NotificationRepository {
  const NotificationRepository(this._service);
  final NotificationService _service;
  Future<PaginatedResponse<AppNotification>> list({
    Map<String, dynamic>? query,
  }) => _service.list(query: query);
  Future<int> unreadCount() => _service.unreadCount();
  Future<AppNotification> get(String id) => _service.get(id);
  Future<void> markRead(String id) => _service.markRead(id);
  Future<void> markUnread(String id) => _service.markUnread(id);
  Future<void> markAllRead() => _service.markAllRead();
}
