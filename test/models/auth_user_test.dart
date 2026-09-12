import 'package:classpay/models/auth_user.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('derives a user role from the backend user_type', () {
    final user = AuthUser.fromJson({
      'id': 1,
      'name': 'Aina',
      'phone': '0123456789',
      'email': 'aina@example.test',
      'user_type': 'sponsor',
      'status': 'active',
      'phone_verified_at': null,
      'last_login_at': null,
    });

    expect(user.userType, UserType.sponsor);
  });
}
