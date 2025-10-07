import 'package:bat_track_v1/data/local/models/projets/projet.dart';
import 'package:bat_track_v1/models/services/hive_entity_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

import '../../../helpers/hive_test_setup.dart';
import '../../../mocks/mock_data_factories.dart';

void main() {
  group('HiveEntityService<Projet>', () {
    late HiveEntityService<Projet> service;
    late Box<Projet> testBox;

    setUpAll(() async {
      await HiveTestSetup.setupHive();
    });

    setUp(() async {
      testBox = await HiveTestSetup.openTestBox<Projet>('test_projets');
      service = HiveEntityService<Projet>(
        boxName: 'test_projets',
        fromJson: (json) => Projet.fromJson(json),
      );
    });

    tearDown(() async {
      await testBox.clear();
    });

    tearDownAll(() async {
      await HiveTestSetup.tearDownHive();
    });

    group('CRUD Operations', () {
      test('should create and retrieve a projet', () async {
        // Arrange
        final projet = MockDataFactories.createProjet(id: 'test_1');

        // Act
        await service.create(projet);
        final retrieved = await service.getById('test_1');

        // Assert
        expect(retrieved, isNotNull);
        expect(retrieved!.id, equals('test_1'));
        expect(retrieved.nom, equals(projet.nom));
      });

      test('should update an existing projet', () async {
        // Arrange
        final originalProjet = MockDataFactories.createProjet(id: 'test_1');
        await service.create(originalProjet);

        final updatedProjet = originalProjet.copyWith(
          nom: 'Projet Modifié',
          updatedAt: DateTime.now(),
        );

        // Act
        await service.update(updatedProjet);
        final retrieved = await service.getById('test_1');

        // Assert
        expect(retrieved!.nom, equals('Projet Modifié'));
        expect(retrieved.updatedAt, isNotNull);
      });

      test('should delete a projet', () async {
        // Arrange
        final projet = MockDataFactories.createProjet(id: 'test_1');
        await service.create(projet);

        // Act
        await service.delete('test_1');
        final retrieved = await service.getById('test_1');

        // Assert
        expect(retrieved, isNull);
      });

      test('should get all projets', () async {
        // Arrange
        final projets = MockDataFactories.createProjetList(3);
        for (final projet in projets) {
          await service.create(projet);
        }

        // Act
        final allProjets = await service.getAll();

        // Assert
        expect(allProjets.length, equals(3));
        expect(
          allProjets.map((p) => p.id).toList(),
          containsAll(projets.map((p) => p.id)),
        );
      });
    });

    group('Stream Operations', () {
      test('watchAll should emit updates when projets change', () async {
        // Arrange
        final projet1 = MockDataFactories.createProjet(id: 'test_1');
        final projet2 = MockDataFactories.createProjet(id: 'test_2');

        // Act & Assert
        expectLater(
          service.watchAll(),
          emitsInOrder([
            [], // Initial empty state
            [projet1], // After first create
            [projet1, projet2], // After second create
            [projet2], // After first delete
          ]),
        );

        await service.create(projet1);
        await service.create(projet2);
        await service.delete('test_1');
      });

      test('watchById should emit updates for specific projet', () async {
        // Arrange
        final originalProjet = MockDataFactories.createProjet(id: 'test_1');
        final updatedProjet = originalProjet.copyWith(nom: 'Updated Name');

        // Act & Assert
        expectLater(
          service.watchById('test_1'),
          emitsInOrder([
            null, // Initial state
            originalProjet, // After create
            updatedProjet, // After update
            null, // After delete
          ]),
        );

        await service.create(originalProjet);
        await service.update(updatedProjet);
        await service.delete('test_1');
      });
    });

    group('Query Operations', () {
      test('should filter projets by createdBy', () async {
        // Arrange
        final user1Projets = List.generate(
          2,
          (i) =>
              MockDataFactories.createProjet(id: 'u1_$i', createdBy: 'user1'),
        );
        final user2Projets = List.generate(
          3,
          (i) =>
              MockDataFactories.createProjet(id: 'u2_$i', createdBy: 'user2'),
        );

        for (final projet in [...user1Projets, ...user2Projets]) {
          await service.create(projet);
        }

        // Act
        final user1Results = await service.query(
          where: (projet) => projet.createdBy == 'user1',
        );

        // Assert
        expect(user1Results.length, equals(2));
        expect(user1Results.every((p) => p.createdBy == 'user1'), isTrue);
      });

      test('should sort projets by dateDebut', () async {
        // Arrange
        final now = DateTime.now();
        final projets = [
          MockDataFactories.createProjet(
            id: '1',
          ).copyWith(dateDebut: now.add(Duration(days: 2))),
          MockDataFactories.createProjet(id: '2').copyWith(dateDebut: now),
          MockDataFactories.createProjet(
            id: '3',
          ).copyWith(dateDebut: now.add(Duration(days: 1))),
        ];

        for (final projet in projets) {
          await service.create(projet);
        }

        // Act
        final sortedResults = await service.query(
          orderBy: (a, b) => a.dateDebut.compareTo(b.dateDebut),
        );

        // Assert
        expect(sortedResults[0].id, equals('2')); // now
        expect(sortedResults[1].id, equals('3')); // now + 1 day
        expect(sortedResults[2].id, equals('1')); // now + 2 days
      });
    });
  });
}
