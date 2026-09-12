class ClassRecord {
  const ClassRecord({
    required this.id,
    required this.organizationId,
    required this.name,
    required this.description,
    required this.teacherName,
    required this.startDate,
    required this.endDate,
    required this.status,
    required this.participantCount,
    required this.hasPaymentConfiguration,
  });

  final int id;
  final int organizationId;
  final String name;
  final String? description;
  final String teacherName;
  final DateTime? startDate;
  final DateTime? endDate;
  final String status;
  final int participantCount;
  final bool hasPaymentConfiguration;

  factory ClassRecord.fromJson(Object? json) {
    final map = json as Map<String, dynamic>;
    return ClassRecord(
      id: map['id'] as int,
      organizationId: _asInt(map['organization_id']),
      name: map['name'] as String? ?? '',
      description: map['description'] as String?,
      teacherName: map['teacher_name'] as String? ?? '',
      startDate: _asDate(map['start_date']),
      endDate: _asDate(map['end_date']),
      status: map['status'] as String? ?? '',
      participantCount: _asInt(
        map['participant_count'] ?? map['participants_count'],
      ),
      hasPaymentConfiguration:
          map['has_payment_configuration'] == true ||
          map['payment_configuration'] != null,
    );
  }

  Map<String, dynamic> toRequestJson() => {
    'name': name,
    'description': description,
    'teacher_name': teacherName,
    'start_date': _dateString(startDate),
    'end_date': _dateString(endDate),
    'status': status,
  };
}

class ClassSchedule {
  const ClassSchedule({
    required this.id,
    required this.day,
    required this.startTime,
    required this.endTime,
  });
  final int id;
  final String day;
  final String startTime;
  final String endTime;

  factory ClassSchedule.fromJson(Object? json) {
    final map = json as Map<String, dynamic>;
    return ClassSchedule(
      id: map['id'] as int,
      day: map['day'] as String? ?? '',
      startTime: map['start_time'] as String? ?? '',
      endTime: map['end_time'] as String? ?? '',
    );
  }

  Map<String, dynamic> toRequestJson() => {
    'day': day,
    'start_time': startTime,
    'end_time': endTime,
  };
}

int _asInt(Object? value) =>
    value is num ? value.toInt() : int.tryParse('$value') ?? 0;
DateTime? _asDate(Object? value) =>
    value is String ? DateTime.tryParse(value) : null;
String? _dateString(DateTime? date) => date == null
    ? null
    : '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
