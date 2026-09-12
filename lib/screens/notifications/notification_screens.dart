import 'package:classpay/core/errors/api_error_message.dart';
import 'package:classpay/core/errors/api_exception.dart';
import 'package:classpay/core/widgets/async_states.dart';
import 'package:classpay/core/widgets/notification_tile.dart';
import 'package:classpay/models/app_notification.dart';
import 'package:classpay/models/auth_user.dart';
import 'package:classpay/providers/notification_provider.dart';
import 'package:classpay/providers/session_manager.dart';
import 'package:classpay/repositories/notification_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});
  @override
  ConsumerState<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  var _filter = const NotificationFilter();
  @override
  Widget build(BuildContext context) {
    final notifications = ref.watch(notificationsProvider(_filter));
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          IconButton(
            tooltip: 'Filter notifications',
            icon: const Icon(Icons.filter_list),
            onPressed: () async {
              final filter = await showModalBottomSheet<NotificationFilter>(
                context: context,
                builder: (_) => _FilterSheet(initial: _filter),
              );
              if (filter != null) setState(() => _filter = filter);
            },
          ),
          TextButton(
            onPressed: () => _markAllRead(context),
            child: const Text('Read all'),
          ),
        ],
      ),
      body: notifications.when(
        loading: () => const AppLoadingIndicator(),
        error: (error, stack) => AppErrorState(
          message: apiErrorMessage(error),
          onRetry: () => ref.invalidate(notificationsProvider(_filter)),
        ),
        data: (page) => page.items.isEmpty
            ? const AppEmptyState(
                title: 'No notifications',
                message: 'New account updates will appear here.',
              )
            : RefreshIndicator(
                onRefresh: () async => _refresh(),
                child: ListView(
                  children: [
                    for (final notification in page.items)
                      NotificationTile(
                        notification: notification,
                        onTap: () =>
                            context.push('/notifications/${notification.id}'),
                        onReadStateChanged: () =>
                            _changeReadState(context, notification),
                      ),
                    if (page.lastPage > 1)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          OutlinedButton(
                            onPressed: _filter.page > 1
                                ? () => setState(
                                    () => _filter = NotificationFilter(
                                      unreadOnly: _filter.unreadOnly,
                                      type: _filter.type,
                                      page: _filter.page - 1,
                                    ),
                                  )
                                : null,
                            child: const Text('Previous'),
                          ),
                          Text(' ${_filter.page}/${page.lastPage} '),
                          OutlinedButton(
                            onPressed: page.hasNextPage
                                ? () => setState(
                                    () => _filter = NotificationFilter(
                                      unreadOnly: _filter.unreadOnly,
                                      type: _filter.type,
                                      page: _filter.page + 1,
                                    ),
                                  )
                                : null,
                            child: const Text('Next'),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
      ),
    );
  }

  Future<void> _refresh() async {
    ref.invalidate(notificationsProvider(_filter));
    ref.invalidate(unreadNotificationCountProvider);
  }

  Future<void> _changeReadState(
    BuildContext context,
    AppNotification notification,
  ) async {
    try {
      final repository = ref.read(notificationRepositoryProvider);
      if (notification.isRead)
        await repository.markUnread(notification.id);
      else
        await repository.markRead(notification.id);
      await _refresh();
    } on ApiException catch (error) {
      if (context.mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.message)));
    }
  }

  Future<void> _markAllRead(BuildContext context) async {
    try {
      await ref.read(notificationRepositoryProvider).markAllRead();
      await _refresh();
    } on ApiException catch (error) {
      if (context.mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.message)));
    }
  }
}

class NotificationDetailScreen extends ConsumerWidget {
  const NotificationDetailScreen({required this.notificationId, super.key});
  final String notificationId;
  @override
  Widget build(BuildContext context, WidgetRef ref) => ref
      .watch(notificationDetailProvider(notificationId))
      .when(
        loading: () => const Scaffold(body: AppLoadingIndicator()),
        error: (error, stack) =>
            Scaffold(body: AppErrorState(message: apiErrorMessage(error))),
        data: (notification) => Scaffold(
          appBar: AppBar(title: const Text('Notification')),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  notification.title,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 12),
                Text(notification.message),
                const SizedBox(height: 12),
                Text(notification.type),
                const Spacer(),
                if (_isPaymentNotification(notification) &&
                    _participantRole(ref) != null)
                  FilledButton(
                    onPressed: () => context.go(
                      '/${_participantRole(ref)!.name}/payment-schedules',
                    ),
                    child: const Text('View payment schedules'),
                  ),
              ],
            ),
          ),
        ),
      );
}

bool _isPaymentNotification(AppNotification value) =>
    value.type.startsWith('payment.');
UserType? _participantRole(WidgetRef ref) {
  final type = ref.watch(sessionManagerProvider).state.user?.userType;
  return type == UserType.student || type == UserType.sponsor ? type : null;
}

class NotificationUnreadBadge extends ConsumerWidget {
  const NotificationUnreadBadge({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(unreadNotificationCountProvider);
    return count.when(
      loading: () => const Icon(Icons.notifications_none),
      error: (_, __) => const Icon(Icons.notifications_none),
      data: (value) => Badge(
        isLabelVisible: value > 0,
        label: Text('$value'),
        child: const Icon(Icons.notifications_none),
      ),
    );
  }
}

class _FilterSheet extends StatefulWidget {
  const _FilterSheet({required this.initial});
  final NotificationFilter initial;
  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  late bool _unread = widget.initial.unreadOnly;
  late String? _type = widget.initial.type;
  @override
  Widget build(BuildContext context) => SafeArea(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SwitchListTile(
            title: const Text('Unread only'),
            value: _unread,
            onChanged: (value) => setState(() => _unread = value),
          ),
          DropdownButtonFormField<String>(
            initialValue: _type,
            hint: const Text('All notification types'),
            items: const [
              DropdownMenuItem(
                value: 'payment.reminder',
                child: Text('Payment reminder'),
              ),
              DropdownMenuItem(
                value: 'payment.success',
                child: Text('Payment success'),
              ),
              DropdownMenuItem(
                value: 'payment.failed',
                child: Text('Payment failed'),
              ),
              DropdownMenuItem(
                value: 'payment.overdue',
                child: Text('Payment overdue'),
              ),
              DropdownMenuItem(
                value: 'payment.pending',
                child: Text('Payment pending'),
              ),
              DropdownMenuItem(
                value: 'class.added',
                child: Text('Class added'),
              ),
              DropdownMenuItem(
                value: 'class.removed',
                child: Text('Class removed'),
              ),
              DropdownMenuItem(
                value: 'system.notification',
                child: Text('System'),
              ),
            ],
            onChanged: (value) => setState(() => _type = value),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () => Navigator.pop(
              context,
              NotificationFilter(unreadOnly: _unread, type: _type),
            ),
            child: const Text('Apply filters'),
          ),
        ],
      ),
    ),
  );
}
