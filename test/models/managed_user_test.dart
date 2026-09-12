import 'package:classpay/models/managed_user.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parses managed users and relationship data without credentials', () {
    final student = ManagedUser.fromJson({
      'id': 3,
      'name': 'Aina',
      'phone': '0123456789',
      'email': 'aina@example.test',
      'status': 'active',
    });
    final participant = ClassParticipant.fromJson({
      'id': 5,
      'user': {
        'id': 3,
        'name': 'Aina',
        'phone': '0123456789',
        'status': 'active',
      },
      'participant_type': 'student',
      'status': 'active',
    });
    final relationship = SponsorStudentRelationship.fromJson({
      'student': {
        'id': 3,
        'name': 'Aina',
        'phone': '0123456789',
        'status': 'active',
      },
      'relationship_type': 'guardian',
      'status': 'active',
    });

    expect(student.toRequestJson().containsKey('password'), isFalse);
    expect(participant.participantType, 'student');
    expect(relationship.relationshipType, 'guardian');
  });
}
