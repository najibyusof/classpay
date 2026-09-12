class ApiException implements Exception {
  const ApiException({
    required this.message,
    this.statusCode,
    this.errors = const {},
  });

  final String message;
  final int? statusCode;
  final Map<String, dynamic> errors;

  @override
  String toString() => 'ApiException($statusCode): $message';
}
