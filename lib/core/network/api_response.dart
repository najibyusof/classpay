import 'package:classpay/core/errors/api_exception.dart';

class ApiResponse<T> {
  const ApiResponse({required this.message, required this.data});

  final String message;
  final T data;

  factory ApiResponse.fromJson(
    Object? json, {
    required T Function(Object? json) fromJson,
  }) {
    if (json is! Map<String, dynamic>) {
      throw const ApiException(
        message: 'The server returned an invalid response.',
      );
    }
    final isSuccess = json['success'] == true;
    final message = json['message'] as String? ?? '';
    if (!isSuccess) {
      throw ApiException(
        message: message.isEmpty
            ? 'The request could not be completed.'
            : message,
        errors: json['errors'] as Map<String, dynamic>? ?? const {},
      );
    }
    return ApiResponse(message: message, data: fromJson(json['data']));
  }
}
