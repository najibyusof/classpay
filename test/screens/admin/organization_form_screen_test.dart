import 'package:classpay/core/errors/api_exception.dart';
import 'package:classpay/core/network/api_client.dart';
import 'package:classpay/models/organization.dart';
import 'package:classpay/repositories/organization_repository.dart';
import 'package:classpay/screens/admin/organization_form_screen.dart';
import 'package:classpay/services/organization_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _ValidationFailingRepository extends OrganizationRepository {
  _ValidationFailingRepository() : super(OrganizationService(ApiClient(Dio())));

  @override
  Future<Organization> create(Organization organization) => Future.error(
    const ApiException(
      message: 'The given data was invalid.',
      statusCode: 422,
      errors: {
        'code': ['This organization code is already in use.'],
      },
    ),
  );
}

void main() {
  testWidgets(
    'displays backend validation errors on the matching organization form field',
    (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            organizationRepositoryProvider.overrideWithValue(
              _ValidationFailingRepository(),
            ),
          ],
          child: MaterialApp(
            theme: ThemeData(useMaterial3: true),
            home: const OrganizationFormScreen(),
          ),
        ),
      );

      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(0), 'SMK Seri Murni');
      await tester.enterText(fields.at(1), 'SSM');
      await tester.tap(find.text('Create organization'));
      await tester.pumpAndSettle();

      expect(
        find.text('This organization code is already in use.'),
        findsOneWidget,
      );
      expect(find.text('The given data was invalid.'), findsOneWidget);
    },
  );
}
