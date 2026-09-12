import 'package:classpay/core/errors/api_exception.dart';

String apiErrorMessage(Object error) => error is ApiException
    ? error.message
    : 'Something went wrong. Please try again.';

String? validationErrorFor(ApiException? error, String field) {
  final errors = error?.errors[field];
  if (errors is List && errors.isNotEmpty) return errors.first.toString();
  return errors?.toString();
}
