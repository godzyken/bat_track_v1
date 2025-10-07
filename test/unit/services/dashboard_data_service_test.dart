import 'package:bat_track_v1/data/local/models/index_model_extention.dart';
import 'package:bat_track_v1/models/services/dashboard_data_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../mocks/mock_data_factories.dart';

void main() {
  group('DashboardService', () {
    late DashboardService dashboardService;
    late MockLoggedEntityService<Projet> mockProjetService;
    late MockLoggedEntityService<Chantier> mockChantierService;
    late MockLoggedEntityService<Intervention> mockInterventionService;
    late AppUser testUser;

    setUp(() {
      mockProjetService = MockLoggedEntityService<Projet>();
      mockChantierService = MockLoggedEntityService<Chantier>();
      mockInterventionService = MockLoggedEntityService<Intervention>();

      testUser = MockDataFactories.createUser(
        uid: 'user_1',
        role: UserRole.client,
      );

      dashboardService = DashboardService(
        user: testUser,
        projetService: mockProjetService,
        chantierService: mockChantierService,
        interventionService: mockInterventionService,
      );
    });

    group('User-specific Data Filtering', () {
      test('should return only user projects for client', () async {
        final allProjets = [
          MockDataFactories.createProjet(createdBy: 'user_1'),
          MockDataFactories.createProjet(createdBy: 'user_2'),
          MockDataFactories.createProjet(createdBy: 'user_1'),
        ];

        when(
          () => mockProjetService.getAll(),
        ).thenAnswer((_) async => allProjets);

        final userProjets = await dashboardService.getUserProjects();

        expect(userProjets.length, equals(2));
        expect(userProjets.every((p) => p.createdBy == 'user_1'), isTrue);
      });

      test('should return all projects for admin', () async {
        final adminUser = MockDataFactories.createUser(
          uid: 'admin_1',
          isAdmin: true,
        );

        final adminDashboard = DashboardService(
          user: adminUser,
          projetService: mockProjetService,
          chantierService: mockChantierService,
          interventionService: mockInterventionService,
        );

        final allProjets = MockDataFactories.createProjetList(5);
        when(
          () => mockProjetService.getAll(),
        ).thenAnswer((_) async => allProjets);

        final adminProjets = await adminDashboard.getUserProjects();

        expect(adminProjets.length, equals(5));
      });
    });

    group('Dashboard Statistics', () {
      test('should calculate correct project statistics', () async {
        final projets = [
          MockDataFactories.createProjet(
            createdBy: 'user_1',
          ).copyWith(status: ProjetStatus.draft),
          MockDataFactories.createProjet(
            createdBy: 'user_1',
          ).copyWith(status: ProjetStatus.validated),
          MockDataFactories.createProjet(
            createdBy: 'user_1',
          ).copyWith(status: ProjetStatus.draft),
        ];

        when(() => mockProjetService.getAll()).thenAnswer((_) async => projets);

        final stats = await dashboardService.getProjectStatistics();

        expect(stats['total'], equals(3));
        expect(stats['draft'], equals(2));
        expect(stats['validated'], equals(1));
        expect(stats['pending'], equals(0));
      });

      test('should handle empty project list', () async {
        when(() => mockProjetService.getAll()).thenAnswer((_) async => []);

        final stats = await dashboardService.getProjectStatistics();

        expect(stats['total'], equals(0));
        expect(stats['draft'], equals(0));
        expect(stats['validated'], equals(0));
      });
    });
  });
}
