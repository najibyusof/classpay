enum UserType { admin, student, sponsor, unknown }

class AuthUser {
  const AuthUser({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.userType,
    required this.status,
    this.phoneVerifiedAt,
    this.lastLoginAt,
  });

  final int id;
  final String name;
  final String phone;
  final String? email;
  final UserType userType;
  final String status;
  final DateTime? phoneVerifiedAt;
  final DateTime? lastLoginAt;

  factory AuthUser.fromJson(Object? json) {
    final map = json as Map<String, dynamic>;
    return AuthUser(
      id: map['id'] as int,
      name: map['name'] as String? ?? '',
      phone: map['phone'] as String? ?? '',
      email: map['email'] as String?,
      userType: UserType.values.firstWhere(
        (type) => type.name == map['user_type'],
        orElse: () => UserType.unknown,
      ),
      status: map['status'] as String? ?? '',
      phoneVerifiedAt: _parseDate(map['phone_verified_at']),
      lastLoginAt: _parseDate(map['last_login_at']),
    );
  }

  static DateTime? _parseDate(Object? value) =>
      value is String ? DateTime.tryParse(value) : null;
}
