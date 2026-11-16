import 'package:bat_track_v1/data/local/models/entities/projet_entity.dart';
import 'package:bat_track_v1/data/local/providers/hive_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_models/shared_models.dart';

import '../../mocks/mock_data_factories.dart';
import '../../mocks/mock_services.dart';

void main() {
  group('Projet Providers', () {
    late MockLoggedEntitySyncService<Projet, ProjetEntity> mockService;
    late List<Projet> testProjets;

    setUp(() {
      mockService = MockLoggedEntitySyncService<Projet, ProjetEntity>();
      testProjets = MockDataFactories.createProjetList(3);

      // Configuration par défaut du mock
      when(
        () => mockService.watchAll(),
      ).thenAnswer((_) => Stream.value(testProjets));
    });

    test('allProjectsProvider returns list of projets', () async {
      final container = ProviderContainer(
        overrides: [projetServiceProvider.overrideWith((ref) => mockService)],
      );
      addTearDown(container.dispose);
      container.listen(allProjectsProvider, (_, __) {});

      await Future<void>.delayed(const Duration(milliseconds: 20));
      final state = container.read(allProjectsProvider);

      expect(state.hasValue, true);
      expect(state.value, testProjets);
    });
  });
}
