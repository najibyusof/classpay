import 'package:classpay/core/network/pagination.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('reports pagination boundaries from a Laravel paginator payload', () {
    final firstPage = PaginatedResponse<String>.fromJson({
      'data': ['one'],
      'current_page': 1,
      'last_page': 2,
      'total': 2,
    }, itemFromJson: (item) => item! as String);
    final lastPage = PaginatedResponse<String>.fromJson({
      'data': ['two'],
      'current_page': 2,
      'last_page': 2,
      'total': 2,
    }, itemFromJson: (item) => item! as String);

    expect(firstPage.hasNextPage, isTrue);
    expect(lastPage.hasNextPage, isFalse);
  });
}
