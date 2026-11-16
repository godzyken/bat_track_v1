import 'package:bat_track_v1/core/providers/entity_providers.dart';
import 'package:bat_track_v1/data/local/models/adapters/hive_entity_factory.dart';
import 'package:bat_track_v1/data/local/models/entities/projet_entity.dart';
import 'package:bat_track_v1/data/remote/providers/multi_backend_remote_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
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
      if (!Hive.isAdapterRegistered(1)) {
        Hive.registerAdapter(ProjetEntityAdapter());
      }
      EntityFactoryRegistry.init();
    });

    setUp(() async {
      await HiveTestSetup.setupHive();
      EntityFactoryRegistry.init();

      mockRemoteStorage = MockServiceBuilder.createMockRemoteService();
      when(() => mockRemoteStorage.isConnected).thenReturn(true);
      when(
        () => mockRemoteStorage.watchCollectionRaw(any()),
      ).thenAnswer((_) => Stream.value([]));
      when(
        () => mockRemoteStorage.saveRaw(any(), any(), any()),
      ).thenAnswer((_) async {});
      when(
        () => mockRemoteStorage.getAllRaw(any()),
      ).thenAnswer((_) async => []);

      container = ProviderContainer(
        overrides: [
          multiBackendRemoteProvider.overrideWith((ref) => mockRemoteStorage),
        ],
      );
    });

    tearDown(() async {
      container.dispose();
      try {
        if (Hive.isBoxOpen('projets')) {
          await Hive.box<ProjetEntity>('projets').clear();
        }
      } catch (_) {}
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

        container.listen(projetListProvider, (_, __) {});

        // Act - Déclencher la synchronisation via le service
        final projetService = container.read(projetServiceProvider);
        await projetService.syncAllFromRemote();

        await Future<void>.delayed(const Duration(milliseconds: 50));

        // Assert - Vérifier que les données sont disponibles via le provider
        final projectListAsync = container.read(projetListProvider);
        expect(projectListAsync.value?.length, equals(5));
      },
    );

    test('should handle offline mode gracefully', () async {
      // Arrange - Simuler hors ligne
      when(() => mockRemoteStorage.isConnected).thenReturn(false);
      when(
        () => mockRemoteStorage.getAllRaw(any()),
      ).thenThrow(Exception('No internet connection'));

      container.listen(projetListProvider, (_, __) {});

      // Créer des données locales
      final localProjets = MockDataFactories.createProjetList(2);
      final projetService = container.read(projetServiceProvider);

      for (final projet in localProjets) {
        await projetService.save(projet);
      }

      await Future<void>.delayed(const Duration(milliseconds: 50));

      // Act & Assert - Le provider doit retourner les données locales
      final projectListAsync = container.read(projetListProvider);
      expect(projectListAsync.value?.length, equals(2));
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
      ).copyWith(updatedAt: now.add(const Duration(minutes: 10)));

      // Setup mocks
      when(
        () => mockRemoteStorage.getAllRaw('projets'),
      ).thenAnswer((_) async => [remoteProjet.toJson()]);

      // Créer la version locale
      final projetService = container.read(projetServiceProvider);
      await projetService.sync(localProjet);

      // Act - Synchronisation bidirectionnelle
      await projetService.syncAllFromRemote();

      // Assert - La version remote (plus récente) doit être conservée
      final finalProjet = await projetService.get('conflict_1');
      expect(finalProjet?.nom, equals('Version Remote'));
    });
  });
}
