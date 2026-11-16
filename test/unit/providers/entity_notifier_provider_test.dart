import 'package:bat_track_v1/core/providers/entity_providers.dart';
import 'package:bat_track_v1/data/local/models/entities/projet_entity.dart';
import 'package:bat_track_v1/data/local/models/index_model_extention.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../mocks/mock_data_factories.dart';
import '../../mocks/mock_services.dart';

void main() {
  group('EntityNotifierProvider Tests', () {
    late MockLoggedEntitySyncService<Projet, ProjetEntity> mockService;

    setUpAll(() {
      registerFallbackValue(MockDataFactories.createProjet());
    });

    setUp(() {
      mockService = MockLoggedEntitySyncService<Projet, ProjetEntity>();
    });

    test('should handle create operation', () async {
      final container = ProviderContainer(
        overrides: [projetServiceProvider.overrideWith((ref) => mockService)],
      );
      addTearDown(container.dispose);
      // ...
    });
  });
}
