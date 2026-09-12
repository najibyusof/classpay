import 'package:classpay/models/auth_user.dart';
import 'package:classpay/providers/auth_state.dart';

abstract final class AuthGuard {
  static String homeForUser(AuthUser user) => switch (user.userType) {
    UserType.admin => '/admin',
    UserType.student => '/student',
    UserType.sponsor => '/sponsor',
    UserType.unknown => '/login',
  };

  static bool canAccess(String location, AuthState state) {
    final user = state.user;
    if (user == null) return false;
    if (location.startsWith('/notifications')) return true;
    if (location == '/profile') return true;
    if (user.userType == UserType.admin && location.startsWith('/admin'))
      return true;
    if (user.userType == UserType.student && location.startsWith('/student'))
      return true;
    if (user.userType == UserType.sponsor && location.startsWith('/sponsor'))
      return true;
    return location == homeForUser(user) ||
        location == '/change-password' ||
        location == '/set-password';
  }
}
