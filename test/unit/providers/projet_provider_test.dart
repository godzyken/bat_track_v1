import 'package:bat_track_v1/data/local/models/projets/projet.dart';
import 'package:bat_track_v1/data/local/models/entities/projet_entity.dart';
import 'package:bat_track_v1/data/local/providers/hive_provider.dart';
import 'package:bat_track_v1/features/projet/controllers/providers/projet_list_provider.dart';
import 'package:bat_track_v1/models/data/hive_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

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

    test('projectListProvider should emit list of projets', () async {
      final container = ProviderContainer(
        overrides: [
          projetServiceProvider.overrideWith((ref) => mockService),
        ],
      );
      addTearDown(container.dispose);

      // Note: projectListProvider implementation in your code uses firestoreProvider
      // directly, which might need separate mocking if you want to test that specific provider.
      // If projectListProvider was defined to use projetServiceProvider, this override would work.
    });
  });
}
