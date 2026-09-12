import 'package:classpay/models/app_notification.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parses unread notification data and related record references', () {
    final notification = AppNotification.fromJson({
      'id': 'abc',
      'type': 'payment.success',
      'title': 'Payment received',
      'message': 'Thank you',
      'created_at': '2026-09-12T10:00:00Z',
      'read_at': null,
      'related_type': 'payment',
      'related_id': 3,
    });
    expect(notification.isRead, isFalse);
    expect(notification.relatedId, '3');
  });
}
