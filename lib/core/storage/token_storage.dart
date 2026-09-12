import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final tokenStorageProvider = Provider<TokenStorage>(
  (ref) => const TokenStorage(FlutterSecureStorage()),
);

class TokenStorage {
  const TokenStorage(this._storage);

  static const _tokenKey = 'sanctum_bearer_token';
  static const _sessionKey = 'auth_session';
  final FlutterSecureStorage _storage;

  Future<String?> readToken() => _storage.read(key: _tokenKey);
  Future<void> saveToken(String token) =>
      _storage.write(key: _tokenKey, value: token);
  Future<void> clearToken() => _storage.delete(key: _tokenKey);
  Future<void> saveSession(Map<String, Object?> session) =>
      _storage.write(key: _sessionKey, value: jsonEncode(session));

  Future<Map<String, dynamic>?> readSession() async {
    final value = await _storage.read(key: _sessionKey);
    if (value == null) return null;
    final decoded = jsonDecode(value);
    return decoded is Map<String, dynamic> ? decoded : null;
  }

  Future<void> clearSession() => _storage.delete(key: _sessionKey);
}
