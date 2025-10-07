import 'package:bat_track_v1/data/local/models/index_model_extention.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../mocks/mock_data_factories.dart';

void main() {
  group('Projet Business Logic', () {
    late Projet draftProjet;
    late AppUser clientUser;
    late AppUser adminUser;
    late AppUser techUser;

    setUp(() {
      clientUser = MockDataFactories.createUser(
        uid: 'client_1',
        role: UserRole.client,
      );
      adminUser = MockDataFactories.createUser(
        uid: 'admin_1',
        role: UserRole.superUtilisateur,
        isAdmin: true,
      );
      techUser = MockDataFactories.createUser(
        uid: 'tech_1',
        role: UserRole.technicien,
      );

      draftProjet = MockDataFactories.createProjet(
        id: 'proj_1',
        createdBy: clientUser.uid,
        status: ProjetStatus.draft,
      );
    });

    group('Validation Workflow', () {
      test('client validation should transition to pending state', () {
        final validated = draftProjet.validateByClient(clientUser.uid);

        expect(validated.clientValide, isTrue);
        expect(validated.status, equals('pendingValidation'));
      });

      test('admin validation should complete validation process', () {
        final clientValidated = draftProjet.copyWith(clientValide: true);
        final adminValidated = clientValidated.validateByAdminOrChef(adminUser);

        expect(adminValidated.chefDeProjetValide, isTrue);
        expect(adminValidated.status, equals('validatedWithoutTechnicians'));
      });

      test('full validation workflow should work end-to-end', () {
        // Step 1: Client validation
        var projet = draftProjet.validateByClient(clientUser.uid);
        expect(projet.status, equals('pendingValidation'));

        // Step 2: Admin validation
        projet = projet.validateByAdminOrChef(adminUser);
        expect(projet.status, equals('validatedWithoutTechnicians'));

        // Step 3: Assign technician
        projet = projet.assignTechnician(techUser);
        expect(projet.members, contains(techUser.uid));

        // Step 4: Technician validation (simulated)
        projet = projet.copyWith(techniciensValides: true);
        expect(projet.status, equals('fullyValidated'));
      });

      test('should enforce validation order', () {
        // Cannot validate by admin before client
        expect(
          () => draftProjet.validateByAdminOrChef(adminUser),
          returnsNormally, // This should work as admin can validate anytime
        );

        // Cannot assign technician without client validation
        expect(
          () => draftProjet.assignTechnician(techUser),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('Permission System', () {
      test('should respect edit permissions by project status', () {
        // Draft: client can edit
        expect(draftProjet.canEdit(clientUser), isTrue);
        expect(draftProjet.canEdit(techUser), isFalse);

        // Validated: client cannot edit, assigned tech can
        final validatedProjet = draftProjet.copyWith(
          status: ProjetStatus.validated,
          chefDeProjetValide: true,
          assignedUserIds: [techUser.uid],
        );

        expect(validatedProjet.canEdit(clientUser), isFalse);
        expect(validatedProjet.canEdit(techUser), isTrue);
      });

      test('should handle technician assignment permissions', () {
        final clientValidated = draftProjet.copyWith(clientValide: true);

        // Can assign tech to client-validated project
        expect(clientValidated.canBeAssigned(techUser), isTrue);

        // Cannot assign same tech twice
        final withTech = clientValidated.assignTechnician(techUser);
        expect(withTech.canBeAssigned(techUser), isFalse);
      });
    });

    group('Status Calculations', () {
      test('should calculate correct composite status', () {
        var projet = draftProjet;
        expect(projet.status, equals('draft'));

        projet = projet.copyWith(clientValide: true);
        expect(projet.status, equals('pendingValidation'));

        projet = projet.copyWith(chefDeProjetValide: true);
        expect(projet.status, equals('validatedWithoutTechnicians'));

        projet = projet.copyWith(techniciensValides: true);
        expect(projet.status, equals('fullyValidated'));
      });

      test('should handle edge cases in status calculation', () {
        // Invalid state: tech validated but not chef
        final invalidState = draftProjet.copyWith(
          clientValide: true,
          techniciensValides: true,
          chefDeProjetValide: false,
        );

        expect(invalidState.status, equals('pendingValidation'));
      });
    });
  });
}
