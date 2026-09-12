import 'package:classpay/models/auth_user.dart';
import 'package:classpay/providers/auth_state.dart';
import 'package:classpay/routes/auth_guard.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const admin = AuthUser(
    id: 1,
    name: 'Admin',
    phone: '0123456789',
    email: null,
    userType: UserType.admin,
    status: 'active',
  );

  test(
    'routes an authenticated user only to their backend-authorized area',
    () {
      const state = AuthState.authenticated(admin);

      expect(AuthGuard.homeForUser(admin), '/admin');
      expect(AuthGuard.canAccess('/admin', state), isTrue);
      expect(AuthGuard.canAccess('/student', state), isFalse);
      expect(AuthGuard.canAccess('/sponsor', state), isFalse);
    },
  );
  test('denies a student access to admin routes', () {
    const student = AuthUser(
      id: 2,
      name: 'Student',
      phone: '0123456789',
      email: null,
      userType: UserType.student,
      status: 'active',
    );
    const state = AuthState.authenticated(student);

    expect(AuthGuard.homeForUser(student), '/student');
    expect(AuthGuard.canAccess('/student', state), isTrue);
    expect(AuthGuard.canAccess('/admin', state), isFalse);
  });
}
