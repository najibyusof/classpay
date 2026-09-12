import 'package:classpay/core/network/pagination.dart';
import 'package:classpay/models/organization.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parses paginated organization API data', () {
    final page = PaginatedResponse<Organization>.fromJson({
      'data': [
        {
          'id': 7,
          'name': 'SMK Seri Murni',
          'code': 'SSM',
          'description': 'School',
          'status': 'active',
          'administrator_count': 2,
        },
      ],
      'current_page': 1,
      'last_page': 3,
      'total': 21,
    }, itemFromJson: Organization.fromJson);

    expect(page.total, 21);
    expect(page.hasNextPage, isTrue);
    expect(page.items.single.administratorCount, 2);
    expect(page.items.single.toRequestJson().containsKey('id'), isFalse);
  });
}
