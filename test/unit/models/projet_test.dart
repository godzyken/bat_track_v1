import 'package:bat_track_v1/data/local/models/index_model_extention.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../mocks/mock_data_factories.dart';

void main() {
  group('Projet Model', () {
    late Projet testProjet;

    setUp(() {
      testProjet = MockDataFactories.createProjet(
        id: 'proj_1',
        nom: 'Test Projet',
        createdBy: 'user_1',
      );
    });

    group('Serialization', () {
      test('should serialize to JSON correctly', () {
        final json = testProjet.toJson();

        expect(json['id'], equals('proj_1'));
        expect(json['nom'], equals('Test Projet'));
        expect(json['createdBy'], equals('user_1'));
        expect(json['dateDebut'], isA<String>());
        expect(json['dateFin'], isA<String>());
      });

      test('should deserialize from JSON correctly', () {
        final json = testProjet.toJson();
        final reconstructed = Projet.fromJson(json);

        expect(reconstructed.id, equals(testProjet.id));
        expect(reconstructed.nom, equals(testProjet.nom));
        expect(reconstructed.createdBy, equals(testProjet.createdBy));
        expect(reconstructed.dateDebut, equals(testProjet.dateDebut));
      });

      test('should handle null updatedAt in JSON', () {
        final json = testProjet.toJson();
        json['updatedAt'] = null;

        final reconstructed = Projet.fromJson(json);
        expect(reconstructed.updatedAt, isNull);
        expect(reconstructed.isUpdated, isFalse);
      });
    });

    group('Access Control', () {
      test('admin user should have full access', () {
        final adminUser = MockDataFactories.createUser(
          uid: 'admin_1',
          isAdmin: true,
        );

        expect(testProjet.canAccess(adminUser), isTrue);
        expect(testProjet.canEdit(adminUser), isTrue);
        expect(testProjet.canValidate(adminUser), isTrue);
      });

      test('owner should have access and edit rights for draft projects', () {
        final ownerUser = MockDataFactories.createUser(
          uid: 'user_1',
          role: UserRole.client,
        );

        expect(testProjet.canAccess(ownerUser), isTrue);
        expect(testProjet.canEdit(ownerUser), isTrue);
      });

      test('owner should not edit validated projects', () {
        final ownerUser = MockDataFactories.createUser(
          uid: 'user_1',
          role: UserRole.client,
        );
        final validatedProjet = testProjet.copyWith(
          status: ProjetStatus.validated,
          chefDeProjetValide: true,
        );

        expect(validatedProjet.canEdit(ownerUser), isFalse);
      });

      test('assigned technician should have limited access', () {
        final techUser = MockDataFactories.createUser(
          uid: 'tech_1',
          role: UserRole.technicien,
        );
        final projetWithTech = testProjet.copyWith(
          assignedUserIds: ['tech_1'],
          status: ProjetStatus.validated,
        );

        expect(projetWithTech.canAccess(techUser), isTrue);
        expect(projetWithTech.canEdit(techUser), isTrue);
        expect(projetWithTech.canValidate(techUser), isFalse);
      });

      test('unrelated user should have no access', () {
        final randomUser = MockDataFactories.createUser(
          uid: 'random_user',
          role: UserRole.client,
        );

        expect(testProjet.canAccess(randomUser), isFalse);
        expect(testProjet.canEdit(randomUser), isFalse);
      });
    });

    group('Workflow Extensions', () {
      test('should validate by client correctly', () {
        final validatedProjet = testProjet.validateByClient('user_1');

        expect(validatedProjet.clientValide, isTrue);
        expect(validatedProjet.id, equals(testProjet.id));
      });

      test('should throw when non-owner tries to validate', () {
        expect(
          () => testProjet.validateByClient('other_user'),
          throwsA(isA<Exception>()),
        );
      });

      test('should assign technician correctly', () {
        final techUser = MockDataFactories.createUser(
          uid: 'tech_1',
          role: UserRole.technicien,
        );
        final clientValidatedProjet = testProjet.copyWith(clientValide: true);

        final result = clientValidatedProjet.assignTechnician(techUser);

        expect(result.members, contains('tech_1'));
        expect(result.members.length, equals(1));
      });

      test('should not assign same technician twice', () {
        final techUser = MockDataFactories.createUser(
          uid: 'tech_1',
          role: UserRole.technicien,
        );
        final projetWithTech = testProjet.copyWith(
          clientValide: true,
          members: ['tech_1'],
        );

        expect(
          () => projetWithTech.assignTechnician(techUser),
          throwsA(isA<Exception>()),
        );
      });

      test('should calculate correct status', () {
        expect(testProjet.status, equals('draft'));

        final clientValidated = testProjet.copyWith(clientValide: true);
        expect(clientValidated.status, equals('pendingValidation'));

        final chefValidated = clientValidated.copyWith(
          chefDeProjetValide: true,
        );
        expect(chefValidated.status, equals('validatedWithoutTechnicians'));

        final fullyValidated = chefValidated.copyWith(techniciensValides: true);
        expect(fullyValidated.status, equals('fullyValidated'));
      });
    });

    group('Copy Operations', () {
      test('should copy with field updates', () {
        final updated = testProjet.copyWithField('specialite', 'Plomberie');

        expect(updated.specialite, equals('Plomberie'));
        expect(updated.id, equals(testProjet.id)); // Other fields unchanged
      });

      test('should handle technicienIds update', () {
        final updated = testProjet.copyWithField('technicienIds', [
          'tech_1',
          'tech_2',
        ]);

        expect(updated.assignedUserIds, equals(['tech_1', 'tech_2']));
      });
    });
  });
}
