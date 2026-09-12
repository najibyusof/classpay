import 'package:classpay/models/app_notification.dart';
import 'package:flutter/material.dart';

class NotificationTile extends StatelessWidget {
  const NotificationTile({
    required this.notification,
    required this.onTap,
    required this.onReadStateChanged,
    super.key,
  });
  final AppNotification notification;
  final VoidCallback onTap;
  final VoidCallback onReadStateChanged;
  @override
  Widget build(BuildContext context) => ListTile(
    onTap: onTap,
    leading: Icon(
      notification.isRead ? Icons.notifications_none : Icons.notifications,
      color: notification.isRead ? null : Theme.of(context).colorScheme.primary,
    ),
    title: Text(
      notification.title,
      style: notification.isRead
          ? null
          : const TextStyle(fontWeight: FontWeight.w700),
    ),
    subtitle: Text(
      '${notification.message}\n${notification.createdAt == null ? '-' : MaterialLocalizations.of(context).formatShortDate(notification.createdAt!)}',
    ),
    isThreeLine: true,
    trailing: IconButton(
      tooltip: notification.isRead ? 'Mark unread' : 'Mark read',
      onPressed: onReadStateChanged,
      icon: Icon(
        notification.isRead
            ? Icons.mark_email_unread_outlined
            : Icons.mark_email_read_outlined,
      ),
    ),
  );
}
