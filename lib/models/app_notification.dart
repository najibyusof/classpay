class AppNotification {
  const AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.createdAt,
    required this.isRead,
    this.relatedType,
    this.relatedId,
    this.data,
  });
  final String id;
  final String type;
  final String title;
  final String message;
  final DateTime? createdAt;
  final bool isRead;
  final String? relatedType;
  final String? relatedId;
  final Map<String, dynamic>? data;

  factory AppNotification.fromJson(Object? json) {
    final map = json as Map<String, dynamic>;
    final data = map['data'] as Map<String, dynamic>?;
    return AppNotification(
      id: '${map['id']}',
      type: map['type'] as String? ?? 'system.notification',
      title: (map['title'] ?? data?['title'] ?? '').toString(),
      message: (map['message'] ?? data?['message'] ?? '').toString(),
      createdAt: _date(map['created_at']),
      isRead: map['read_at'] != null || map['is_read'] == true,
      relatedType: (map['related_type'] ?? data?['related_type']) as String?,
      relatedId: (map['related_id'] ?? data?['related_id'])?.toString(),
      data: data,
    );
  }
}

DateTime? _date(Object? value) =>
    value is String ? DateTime.tryParse(value) : null;
