import 'package:classpay/core/network/api_client.dart';
import 'package:classpay/models/auth_session.dart';
import 'package:classpay/models/auth_user.dart';

class AuthService {
  const AuthService(this._apiClient);

  final ApiClient _apiClient;
  static const _basePath = '/auth';

  Future<AuthSession> login({
    required String phone,
    required String password,
    required String deviceName,
  }) async {
    final response = await _apiClient.post<AuthSession>(
      '$_basePath/login',
      data: {'phone': phone, 'password': password, 'device_name': deviceName},
      fromJson: AuthSession.fromJson,
    );
    return response.data;
  }

  Future<void> logout() async {
    await _apiClient.post<void>('$_basePath/logout', fromJson: (_) {});
  }

  Future<AuthUser> me() async {
    final response = await _apiClient.get<AuthUser>(
      '$_basePath/me',
      fromJson: (json) {
        final map = json as Map<String, dynamic>;
        return AuthUser.fromJson(map['user'] ?? map);
      },
    );
    return response.data;
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) => _apiClient.post<void>(
    '$_basePath/change-password',
    data: {
      'current_password': currentPassword,
      'password': newPassword,
      'password_confirmation': newPassword,
    },
    fromJson: (_) {},
  );

  Future<void> setPassword({required String password}) => _apiClient.post<void>(
    '$_basePath/set-password',
    data: {'password': password, 'password_confirmation': password},
    fromJson: (_) {},
  );

  Future<AuthSession> refreshToken() async {
    final response = await _apiClient.post<AuthSession>(
      '$_basePath/refresh-token',
      fromJson: AuthSession.fromJson,
    );
    return response.data;
  }
}
