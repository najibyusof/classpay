class ManagedUser {
  const ManagedUser({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.status,
  });
  final int id;
  final String name;
  final String phone;
  final String? email;
  final String status;

  factory ManagedUser.fromJson(Object? json) {
    final map = json as Map<String, dynamic>;
    return ManagedUser(
      id: map['id'] as int,
      name: map['name'] as String? ?? '',
      phone: map['phone'] as String? ?? '',
      email: map['email'] as String?,
      status: map['status'] as String? ?? '',
    );
  }
  Map<String, dynamic> toRequestJson() => {
    'name': name,
    'phone': phone,
    'email': email,
    'status': status,
  };
}

class ClassParticipant {
  const ClassParticipant({
    required this.id,
    required this.user,
    required this.participantType,
    required this.status,
  });
  final int id;
  final ManagedUser user;
  final String participantType;
  final String status;
  factory ClassParticipant.fromJson(Object? json) {
    final map = json as Map<String, dynamic>;
    return ClassParticipant(
      id: map['id'] as int,
      user: ManagedUser.fromJson(map['user'] ?? map),
      participantType: map['participant_type'] as String? ?? '',
      status: map['status'] as String? ?? '',
    );
  }
}

class SponsorStudentRelationship {
  const SponsorStudentRelationship({
    required this.student,
    required this.relationshipType,
    required this.status,
  });
  final ManagedUser student;
  final String relationshipType;
  final String status;
  factory SponsorStudentRelationship.fromJson(Object? json) {
    final map = json as Map<String, dynamic>;
    return SponsorStudentRelationship(
      student: ManagedUser.fromJson(map['student'] ?? map),
      relationshipType: map['relationship_type'] as String? ?? '',
      status: map['status'] as String? ?? '',
    );
  }
}
