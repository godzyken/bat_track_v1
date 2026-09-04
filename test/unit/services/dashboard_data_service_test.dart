import 'package:bat_track_v1/data/local/models/index_model_extention.dart';
import 'package:bat_track_v1/data/local/models/entities/index_entity_extention.dart';
import 'package:bat_track_v1/models/services/dashboard_data_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_models/shared_models.dart';

import '../../mocks/mock_data_factories.dart';
import '../../mocks/mock_services.dart';

void main() {
  group('DashboardService', () {
    late DashboardService dashboardService;
    late MockLoggedEntitySyncService<Projet, ProjetEntity> mockProjetService;
    late MockLoggedEntitySyncService<Chantier, ChantierEntity>
    mockChantierService;
    late MockLoggedEntitySyncService<Intervention, InterventionEntity>
    mockInterventionService;
    late AppUser testUser;

    setUp(() {
      mockProjetService = MockLoggedEntitySyncService<Projet, ProjetEntity>();
      mockChantierService =
          MockLoggedEntitySyncService<Chantier, ChantierEntity>();
      mockInterventionService =
          MockLoggedEntitySyncService<Intervention, InterventionEntity>();

      testUser = MockDataFactories.createUser(uid: 'user_1');

      dashboardService = DashboardService(
        user: testUser,
        projetService: mockProjetService,
        chantierService: mockChantierService,
        interventionService: mockInterventionService,
      );
    });

    test('watchProjects should return a stream from service', () {
      when(
        () => mockProjetService.watchByOwner(any()),
      ).thenAnswer((_) => Stream.value([]));

      final stream = dashboardService.watchProjects();

      expect(stream, isA<Stream<List<Projet>>>());
    });
  });
}
