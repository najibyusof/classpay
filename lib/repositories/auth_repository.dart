import 'package:classpay/core/network/api_client.dart';
import 'package:classpay/models/auth_session.dart';
import 'package:classpay/models/auth_user.dart';
import 'package:classpay/services/auth_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authServiceProvider = Provider<AuthService>(
  (ref) => AuthService(ref.watch(apiClientProvider)),
);
final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepository(ref.watch(authServiceProvider)),
);

class AuthRepository {
  const AuthRepository(this._service);
  final AuthService _service;

  Future<AuthSession> login({
    required String phone,
    required String password,
    required String deviceName,
  }) =>
      _service.login(phone: phone, password: password, deviceName: deviceName);
  Future<void> logout() => _service.logout();
  Future<AuthUser> me() => _service.me();
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) => _service.changePassword(
    currentPassword: currentPassword,
    newPassword: newPassword,
  );
  Future<void> setPassword({required String password}) =>
      _service.setPassword(password: password);
  Future<AuthSession> refreshToken() => _service.refreshToken();
}
