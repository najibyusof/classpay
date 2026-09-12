import 'package:classpay/core/errors/api_exception.dart';
import 'package:classpay/core/network/api_response.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parses a successful standard API response', () {
    final response = ApiResponse<String>.fromJson({
      'success': true,
      'message': 'Done',
      'data': 'value',
    }, fromJson: (json) => json! as String);

    expect(response.message, 'Done');
    expect(response.data, 'value');
  });

  test('throws an API exception for a failed standard response', () {
    expect(
      () => ApiResponse<void>.fromJson({
        'success': false,
        'message': 'Validation failed',
        'errors': {
          'email': ['Required'],
        },
      }, fromJson: (_) {}),
      throwsA(isA<ApiException>()),
    );
  });
}
