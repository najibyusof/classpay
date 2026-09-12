import 'package:classpay/core/errors/api_exception.dart';
import 'package:classpay/core/storage/token_storage.dart';
import 'package:classpay/models/auth_session.dart';
import 'package:classpay/providers/auth_state.dart';
import 'package:classpay/providers/session_invalidator.dart';
import 'package:classpay/repositories/auth_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/legacy.dart';

final sessionManagerProvider = ChangeNotifierProvider<SessionManager>((ref) {
  return SessionManager(
    ref.watch(authRepositoryProvider),
    ref.watch(tokenStorageProvider),
    ref.watch(sessionInvalidatorProvider),
  );
});

class SessionManager extends ChangeNotifier {
  SessionManager(this._repository, this._tokenStorage, this._invalidator) {
    _invalidator.addListener(_handleInvalidation);
    _restoreSession();
  }

  final AuthRepository _repository;
  final TokenStorage _tokenStorage;
  final SessionInvalidator _invalidator;
  AuthState _state = const AuthState.initializing();
  AuthState get state => _state;

  void _handleInvalidation() {
    if (_state.isAuthenticated) {
      _setState(const AuthState.unauthenticated());
    }
  }

  Future<void> _restoreSession() async {
    if (await _tokenStorage.readToken() == null) {
      _setState(const AuthState.unauthenticated());
      return;
    }
    try {
      final user = await _repository.me();
      _setState(AuthState.authenticated(user));
    } catch (_) {
      await clearSession();
    }
  }

  Future<bool> login({
    required String phone,
    required String password,
    required String deviceName,
  }) async {
    _setState(const AuthState.unauthenticated());
    _setState(
      const AuthState(status: AuthStatus.unauthenticated, isLoading: true),
    );
    try {
      final session = await _repository.login(
        phone: phone,
        password: password,
        deviceName: deviceName,
      );
      await _saveSession(session);
      _setState(AuthState.authenticated(session.user));
      return true;
    } on ApiException catch (error) {
      _setState(AuthState.unauthenticated(errorMessage: error.message));
      return false;
    }
  }

  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) => _runAuthenticatedAction(
    () => _repository.changePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
    ),
  );

  Future<bool> setPassword({required String password}) =>
      _runAuthenticatedAction(
        () => _repository.setPassword(password: password),
      );

  Future<bool> refreshToken() async {
    final user = _state.user;
    if (user == null) return false;
    _setState(AuthState.authenticated(user, isLoading: true));
    try {
      final session = await _repository.refreshToken();
      await _saveSession(session);
      _setState(AuthState.authenticated(session.user));
      return true;
    } on ApiException catch (error) {
      if (error.statusCode == 401) {
        await clearSession();
      } else {
        _setState(AuthState.authenticated(user, errorMessage: error.message));
      }
      return false;
    }
  }

  Future<void> logout() async {
    try {
      await _repository.logout();
    } finally {
      await clearSession();
    }
  }

  Future<void> clearSession() async {
    await _tokenStorage.clearToken();
    await _tokenStorage.clearSession();
    _setState(const AuthState.unauthenticated());
  }

  Future<void> _saveSession(AuthSession session) async {
    await _tokenStorage.saveToken(session.token);
    await _tokenStorage.saveSession(session.toMinimalJson());
  }

  Future<bool> _runAuthenticatedAction(Future<void> Function() action) async {
    final user = _state.user;
    if (user == null) return false;
    _setState(AuthState.authenticated(user, isLoading: true));
    try {
      await action();
      _setState(AuthState.authenticated(user));
      return true;
    } on ApiException catch (error) {
      if (error.statusCode == 401) {
        await clearSession();
      } else {
        _setState(AuthState.authenticated(user, errorMessage: error.message));
      }
      return false;
    }
  }

  void _setState(AuthState state) {
    _state = state;
    notifyListeners();
  }

  @override
  void dispose() {
    _invalidator.removeListener(_handleInvalidation);
    super.dispose();
  }
}
