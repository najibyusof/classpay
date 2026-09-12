import 'package:classpay/models/auth_user.dart';

enum AuthStatus { initializing, unauthenticated, authenticated }

class AuthState {
  const AuthState({
    required this.status,
    this.user,
    this.isLoading = false,
    this.errorMessage,
  });

  const AuthState.initializing()
    : this(status: AuthStatus.initializing, isLoading: true);
  const AuthState.unauthenticated({String? errorMessage})
    : this(status: AuthStatus.unauthenticated, errorMessage: errorMessage);
  const AuthState.authenticated(
    AuthUser user, {
    bool isLoading = false,
    String? errorMessage,
  }) : this(
         status: AuthStatus.authenticated,
         user: user,
         isLoading: isLoading,
         errorMessage: errorMessage,
       );

  final AuthStatus status;
  final AuthUser? user;
  final bool isLoading;
  final String? errorMessage;

  bool get isAuthenticated =>
      status == AuthStatus.authenticated && user != null;
}
