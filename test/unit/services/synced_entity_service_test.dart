import 'package:bat_track_v1/core/services/unified_entity_service.dart';
import 'package:bat_track_v1/data/local/models/projets/projet.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../mocks/mock_data_factories.dart';
import '../../mocks/mock_services.dart';

void main() {
  group('SyncedEntityService<Projet>', () {
    late MockHiveEntityService<Projet> mockLocal;
    late MockRemoteEntityServiceAdapter<Projet> mockRemote;
    late UnifiedEntityService<Projet> syncedService;
    late List<Projet> testProjets;

    setUp(() {
      mockLocal = MockHiveEntityService<Projet>();
      mockRemote = MockRemoteEntityServiceAdapter<Projet>();
      syncedService = UnifiedEntityService<Projet>(
        collectionName: mockRemote.collection,
        remoteStorage: mockRemote.storage,
        fromJson: mockLocal.fromJson,
      );

      testProjets = MockDataFactories.createProjetList(3);

      // Setup par défaut des mocks
      when(() => mockLocal.getAll()).thenAnswer((_) async => []);
      when(() => mockRemote.getAll()).thenAnswer((_) async => []);
      when(() => mockLocal.watchAll()).thenAnswer((_) => Stream.value([]));
    });

    group('Sync Operations', () {
      test('syncToRemote should push local changes to remote', () async {
        // Arrange
        when(() => mockLocal.getAll()).thenAnswer((_) async => testProjets);
        when(
          () => mockRemote.storage.saveRaw(any(), any(), any()),
        ).thenAnswer((_) async => testProjets);

        // Act
        final result = await syncedService.watchAll();

        // Assert
        expect(result.length, equals(3));
        verify(() => mockLocal.getAll()).called(1);
        verify(() => mockRemote.storage.createBatch(testProjets)).called(1);
      });

      test('syncFromRemote should pull remote changes to local', () async {
        // Arrange
        when(() => mockRemote.getAll()).thenAnswer((_) async => testProjets);
        when(
          () => mockLocal.createBatch(any()),
        ).thenAnswer((_) async => testProjets);

        // Act
        final result = await syncedService.getAll();

        // Assert
        expect(result.length, equals(3));
        verify(() => mockRemote.getAll()).called(1);
        verify(() => mockLocal.createBatch(testProjets)).called(1);
      });

      test('bidirectionalSync should merge local and remote data', () async {
        // Arrange
        final localProjets = [testProjets[0]]; // Un projet en local
        final remoteProjets = [
          testProjets[1],
          testProjets[2],
        ]; // Deux projets en remote

        when(() => mockLocal.getAll()).thenAnswer((_) async => localProjets);
        when(() => mockRemote.getAll()).thenAnswer((_) async => remoteProjets);
        when(
          () => mockLocal.createBatch(any()),
        ).thenAnswer((_) async => remoteProjets);
        when(
          () => mockRemote.createBatch(any()),
        ).thenAnswer((_) async => localProjets);

        // Act
        await syncedService.getAll();

        // Assert - Vérifie que chaque côté a reçu les données de l'autre
        verify(() => mockLocal.createBatch(remoteProjets)).called(1);
        verify(() => mockRemote.createBatch(localProjets)).called(1);
      });
    });

    group('Conflict Resolution', () {
      test('should resolve conflicts by updatedAt timestamp', () async {
        // Arrange
        final now = DateTime.now();
        final localProjet = testProjets[0].copyWith(
          nom: 'Local Version',
          updatedAt: now,
        );
        final remoteProjet = testProjets[0].copyWith(
          nom: 'Remote Version',
          updatedAt: now.add(Duration(minutes: 5)), // Plus récent
        );

        when(() => mockLocal.getAll()).thenAnswer((_) async => [localProjet]);
        when(() => mockRemote.getAll()).thenAnswer((_) async => [remoteProjet]);
        when(
          () => mockLocal.update(any()),
        ).thenAnswer((_) async => remoteProjet);

        // Act
        await syncedService.bidirectionalSync();

        // Assert - Le remote (plus récent) doit être gardé
        verify(() => mockLocal.update(remoteProjet)).called(1);
      });
    });

    group('Error Handling', () {
      test('should handle remote service unavailable', () async {
        // Arrange
        when(
          () => mockRemote.getAll(),
        ).thenThrow(Exception('Remote service unavailable'));
        when(() => mockLocal.getAll()).thenAnswer((_) async => testProjets);

        // Act & Assert
        expect(() => syncedService.syncFromRemote(), throwsA(isA<Exception>()));
      });

      test('should continue with local operations when remote fails', () async {
        // Arrange
        final projet = testProjets[0];
        when(
          () => mockLocal.watchByQuery(any()),
        ).thenAnswer((_) async => projet);
        when(
          () => mockRemote.create(any()),
        ).thenThrow(Exception('Network error'));

        // Act - Ne devrait pas lever d'exception
        await syncedService.create(projet);

        // Assert - Local doit avoir été appelé même si remote a échoué
        verify(() => mockLocal.create(projet)).called(1);
      });
    });

    group('Data Consistency', () {
      test('should ensure data consistency after sync', () async {
        // Arrange
        final localData = [testProjets[0]];
        final remoteData = [testProjets[1], testProjets[2]];
        final expectedFinalData = [...localData, ...remoteData];

        when(() => mockLocal.getAll())
            .thenAnswer((_) async => localData)
            .thenAnswer((_) async => expectedFinalData); // After sync

        when(() => mockRemote.getAll()).thenAnswer((_) async => remoteData);
        when(
          () => mockLocal.createBatch(any()),
        ).thenAnswer((_) async => remoteData);
        when(
          () => mockRemote.createBatch(any()),
        ).thenAnswer((_) async => localData);

        // Act
        await syncedService.bidirectionalSync();
        final finalData = await syncedService.getAll();

        // Assert
        expect(finalData.length, equals(3));
        expect(
          finalData.map((p) => p.id).toSet(),
          equals(expectedFinalData.map((p) => p.id).toSet()),
        );
      });
    });
  });
}
