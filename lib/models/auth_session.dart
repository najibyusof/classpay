import 'package:classpay/models/auth_user.dart';

class AuthSession {
  const AuthSession({
    required this.user,
    required this.token,
    required this.tokenType,
  });

  final AuthUser user;
  final String token;
  final String tokenType;

  factory AuthSession.fromJson(Object? json) {
    final map = json as Map<String, dynamic>;
    return AuthSession(
      user: AuthUser.fromJson(map['user']),
      token: map['token'] as String,
      tokenType: map['token_type'] as String? ?? 'Bearer',
    );
  }

  Map<String, Object?> toMinimalJson() => {
    'id': user.id,
    'name': user.name,
    'user_type': user.userType.name,
  };
}
