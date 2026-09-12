import 'package:classpay/models/class_record.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parses a class and schedules from API data', () {
    final classRecord = ClassRecord.fromJson({
      'id': 6,
      'organization_id': 2,
      'name': 'Year 6 Amanah',
      'description': 'Morning class',
      'teacher_name': 'Cikgu Aina',
      'start_date': '2026-01-10',
      'end_date': '2026-12-10',
      'status': 'active',
      'participant_count': 31,
      'has_payment_configuration': true,
    });
    final schedule = ClassSchedule.fromJson({
      'id': 9,
      'day': 'monday',
      'start_time': '08:00',
      'end_time': '10:00',
    });

    expect(classRecord.participantCount, 31);
    expect(classRecord.hasPaymentConfiguration, isTrue);
    expect(classRecord.toRequestJson().containsKey('id'), isFalse);
    expect(schedule.toRequestJson(), {
      'day': 'monday',
      'start_time': '08:00',
      'end_time': '10:00',
    });
  });
}
