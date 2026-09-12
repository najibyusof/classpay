import 'package:classpay/core/network/pagination.dart';
import 'package:classpay/models/app_notification.dart';
import 'package:classpay/repositories/notification_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NotificationFilter {
  const NotificationFilter({this.unreadOnly = false, this.type, this.page = 1});
  final bool unreadOnly;
  final String? type;
  final int page;
  Map<String, dynamic> get query => {
    if (unreadOnly) 'unread': true,
    if (type != null) 'type': type,
    'page': page,
  };
  @override
  bool operator ==(Object other) =>
      other is NotificationFilter &&
      other.unreadOnly == unreadOnly &&
      other.type == type &&
      other.page == page;
  @override
  int get hashCode => Object.hash(unreadOnly, type, page);
}

final notificationsProvider = FutureProvider.autoDispose
    .family<PaginatedResponse<AppNotification>, NotificationFilter>(
      (ref, filter) =>
          ref.watch(notificationRepositoryProvider).list(query: filter.query),
    );
final notificationDetailProvider = FutureProvider.autoDispose
    .family<AppNotification, String>(
      (ref, id) => ref.watch(notificationRepositoryProvider).get(id),
    );
final unreadNotificationCountProvider = FutureProvider.autoDispose<int>(
  (ref) => ref.watch(notificationRepositoryProvider).unreadCount(),
);
