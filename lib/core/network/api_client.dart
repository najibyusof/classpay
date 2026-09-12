import 'package:classpay/core/config/app_config.dart';
import 'package:classpay/core/errors/api_exception.dart';
import 'package:classpay/core/network/api_response.dart';
import 'package:classpay/core/storage/token_storage.dart';
import 'package:classpay/providers/session_invalidator.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final dioProvider = Provider<Dio>((ref) {
  final config = ref.watch(appConfigProvider);
  final tokenStorage = ref.watch(tokenStorageProvider);
  final sessionInvalidator = ref.watch(sessionInvalidatorProvider);
  final dio = Dio(
    BaseOptions(
      baseUrl: config.apiBaseUrl,
      connectTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 20),
      headers: const {'Accept': 'application/json'},
    ),
  );
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await tokenStorage.readToken();
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (error, handler) async {
        if (error.response?.statusCode == 401) {
          await tokenStorage.clearToken();
          await tokenStorage.clearSession();
          sessionInvalidator.invalidate();
        }
        handler.next(error);
      },
    ),
  );
  return dio;
});

final apiClientProvider = Provider<ApiClient>(
  (ref) => ApiClient(ref.watch(dioProvider)),
);

class ApiClient {
  const ApiClient(this._dio);

  final Dio _dio;

  Future<ApiResponse<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    required T Function(Object? json) fromJson,
  }) => _request(
    () => _dio.get<Object?>(path, queryParameters: queryParameters),
    fromJson,
  );

  Future<ApiResponse<T>> post<T>(
    String path, {
    Object? data,
    required T Function(Object? json) fromJson,
  }) => _request(() => _dio.post<Object?>(path, data: data), fromJson);

  Future<ApiResponse<T>> put<T>(
    String path, {
    Object? data,
    required T Function(Object? json) fromJson,
  }) => _request(() => _dio.put<Object?>(path, data: data), fromJson);

  Future<ApiResponse<T>> patch<T>(
    String path, {
    Object? data,
    required T Function(Object? json) fromJson,
  }) => _request(() => _dio.patch<Object?>(path, data: data), fromJson);

  Future<ApiResponse<T>> delete<T>(
    String path, {
    required T Function(Object? json) fromJson,
  }) => _request(() => _dio.delete<Object?>(path), fromJson);

  Future<ApiResponse<T>> _request<T>(
    Future<Response<Object?>> Function() request,
    T Function(Object? json) fromJson,
  ) async {
    try {
      final response = await request();
      return ApiResponse<T>.fromJson(response.data, fromJson: fromJson);
    } on DioException catch (error) {
      throw _toApiException(error);
    }
  }

  ApiException _toApiException(DioException error) {
    final data = error.response?.data;
    if (data is Map<String, dynamic>) {
      return ApiException(
        message: data['message'] as String? ?? _fallbackMessage(error),
        statusCode: error.response?.statusCode,
        errors: data['errors'] as Map<String, dynamic>? ?? const {},
      );
    }
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.connectionError) {
      return const ApiException(
        message: 'Please check your internet connection.',
      );
    }
    return ApiException(
      message: _fallbackMessage(error),
      statusCode: error.response?.statusCode,
    );
  }

  String _fallbackMessage(DioException error) =>
      switch (error.response?.statusCode) {
        403 => 'You do not have permission to perform this action.',
        404 => 'The requested record could not be found.',
        422 => 'Please review the highlighted fields and try again.',
        500 => 'The service is temporarily unavailable. Please try again.',
        _ => 'Something went wrong. Please try again.',
      };
}
