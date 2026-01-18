import 'package:bat_track_v1/data/local/providers/hive_provider.dart';
import 'package:bat_track_v1/data/remote/providers/multi_backend_remote_provider.dart';
import 'package:bat_track_v1/features/projet/controllers/providers/projet_list_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../helpers/hive_test_setup.dart';
import '../mocks/mock_data_factories.dart';
import '../mocks/mock_services.dart';

void main() {
  group('Full Sync Flow Integration Tests', () {
    late ProviderContainer container;
    late MockRemoteStorageService mockRemoteStorage;

    setUpAll(() async {
      await HiveTestSetup.setupHive();
    });

    setUp(() {
      mockRemoteStorage = MockServiceBuilder.createMockRemoteService();

      container = ProviderContainer(
        overrides: [
          multiBackendRemoteProvider.overrideWith((ref) => mockRemoteStorage),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    tearDownAll(() async {
      await HiveTestSetup.tearDownHive();
    });

    test(
      'should sync projects from remote to local and reflect in UI',
      () async {
        // Arrange - Données remote
        final remoteProjets = MockDataFactories.createProjetList(5);
        when(() => mockRemoteStorage.getAllRaw('projets')).thenAnswer(
          (_) async => remoteProjets.map((p) => p.toJson()).toList(),
        );

        // Act - Déclencher la synchronisation via le service
        final projetService = container.read(projetServiceProvider);
        await projetService.syncFromRemote();

        // Assert - Vérifier que les données sont disponibles via le provider
        final projectListAsync = container.read(projectListProvider);

        await expectLater(
          projectListAsync.when(
            data: (data) => data.length,
            loading: () => 0,
            error: (_, _) => -1,
          ),
          equals(5),
        );
      },
    );

    test('should handle offline mode gracefully', () async {
      // Arrange - Simuler hors ligne
      when(() => mockRemoteStorage.isConnected).thenReturn(false);
      when(
        () => mockRemoteStorage.getAllRaw(any()),
      ).thenThrow(Exception('No internet connection'));

      // Créer des données locales
      final localProjets = MockDataFactories.createProjetList(2);
      final projetService = container.read(projetServiceProvider);

      for (final projet in localProjets) {
        await projetService.sync(projet);
      }

      // Act & Assert - Le provider doit retourner les données locales
      final projectListAsync = container.read(projectListProvider);

      await expectLater(
        projectListAsync.when(
          data: (data) => data.length,
          loading: () => 0,
          error: (_, _) => -1,
        ),
        equals(2),
      );
    });

    test('should resolve conflicts during bidirectional sync', () async {
      // Arrange - Conflit de données
      final now = DateTime.now();
      final localProjet = MockDataFactories.createProjet(
        id: 'conflict_1',
        nom: 'Version Locale',
      ).copyWith(updatedAt: now);

      final remoteProjet = MockDataFactories.createProjet(
        id: 'conflict_1',
        nom: 'Version Remote',
      ).copyWith(updatedAt: now.add(Duration(minutes: 10))); // Plus récent

      // Setup mocks
      when(
        () => mockRemoteStorage.getAllRaw('projets'),
      ).thenAnswer((_) async => [remoteProjet.toJson()]);
      when(
        () => mockRemoteStorage.saveRaw('projets', any(), any()),
      ).thenAnswer((_) async {});

      // Créer la version locale
      final projetService = container.read(projetServiceProvider);
      await projetService.sync(localProjet);

      // Act - Synchronisation bidirectionnelle
      await projetService.syncAllFromRemote();

      // Assert - La version remote (plus récente) doit être conservée
      final finalProjet = await projetService.watch('conflict_1');
      expect(finalProjet.first, equals('Version Remote'));
    });
  });
}
