class Organization {
  const Organization({
    required this.id,
    required this.name,
    required this.code,
    required this.description,
    required this.status,
    this.administratorCount = 0,
  });

  final int id;
  final String name;
  final String code;
  final String? description;
  final String status;
  final int administratorCount;

  bool get isActive => status.toLowerCase() == 'active';

  factory Organization.fromJson(Object? json) {
    final map = json as Map<String, dynamic>;
    return Organization(
      id: map['id'] as int,
      name: map['name'] as String? ?? '',
      code: map['code'] as String? ?? '',
      description: map['description'] as String?,
      status: map['status'] as String? ?? '',
      administratorCount: _toInt(
        map['administrator_count'] ?? map['admins_count'],
      ),
    );
  }

  Map<String, dynamic> toRequestJson() => {
    'name': name,
    'code': code,
    'description': description,
    'status': status,
  };
}

class OrganizationAdministrator {
  const OrganizationAdministrator({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.status,
    required this.isPrimary,
  });

  final int id;
  final String name;
  final String phone;
  final String? email;
  final String status;
  final bool isPrimary;

  factory OrganizationAdministrator.fromJson(Object? json) {
    final map = json as Map<String, dynamic>;
    return OrganizationAdministrator(
      id: map['id'] as int,
      name: map['name'] as String? ?? '',
      phone: map['phone'] as String? ?? '',
      email: map['email'] as String?,
      status: map['status'] as String? ?? '',
      isPrimary: map['is_primary'] == true,
    );
  }
}

int _toInt(Object? value) =>
    value is num ? value.toInt() : int.tryParse('$value') ?? 0;
