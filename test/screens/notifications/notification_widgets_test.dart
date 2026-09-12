import 'package:classpay/core/widgets/notification_tile.dart';
import 'package:classpay/models/app_notification.dart';
import 'package:classpay/providers/notification_provider.dart';
import 'package:classpay/screens/notifications/notification_screens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const unread = AppNotification(
    id: '1',
    type: 'payment.reminder',
    title: 'Payment due',
    message: 'Please pay by Friday.',
    createdAt: null,
    isRead: false,
  );
  const read = AppNotification(
    id: '2',
    type: 'system.notification',
    title: 'System',
    message: 'Update complete.',
    createdAt: null,
    isRead: true,
  );

  testWidgets('renders unread notification list content and mark-read action', (
    tester,
  ) async {
    var actionPressed = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: NotificationTile(
            notification: unread,
            onTap: () {},
            onReadStateChanged: () => actionPressed = true,
          ),
        ),
      ),
    );
    expect(find.text('Payment due'), findsOneWidget);
    expect(find.textContaining('Please pay by Friday.'), findsOneWidget);
    await tester.tap(find.byTooltip('Mark read'));
    expect(actionPressed, isTrue);
  });

  testWidgets('shows unread count in notification badge', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          unreadNotificationCountProvider.overrideWith((ref) async => 3),
        ],
        child: const MaterialApp(
          home: Scaffold(body: NotificationUnreadBadge()),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('3'), findsOneWidget);
  });

  testWidgets('offers mark-unread action for a read notification', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: NotificationTile(
            notification: read,
            onTap: () {},
            onReadStateChanged: () {},
          ),
        ),
      ),
    );
    expect(find.byTooltip('Mark unread'), findsOneWidget);
  });
}
