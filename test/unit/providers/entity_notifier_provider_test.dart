import 'package:bat_track_v1/data/local/models/index_model_extention.dart';
import 'package:bat_track_v1/data/local/providers/hive_provider.dart';
import 'package:bat_track_v1/features/chantier/controllers/providers/chantier_sync_provider.dart';
import 'package:bat_track_v1/models/providers/asynchrones/generic_adapter_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:riverpod_test/riverpod_test.dart';

import '../../mocks/mock_data_factories.dart';

void main() {
  group('EntityNotifierProvider Tests', () {
    late MockLoggedEntitySyncService<Projet> mockService;
    late List<Projet> testProjets;

    setUp(() {
      mockService = MockLoggedEntitySyncService<Projet>();
      testProjets = MockDataFactories.createProjetList(3);
    });

    group('CRUD Operations via Notifier', () {
      testProvider<AsyncValue<List<Projet>>>(
        'should handle create operation',
        provider: allProjectsProvider,

        overrides: [projetServiceProvider.overrideWith((ref) => mockService)],

        setUp: () {
          when(() => mockService.watchAll()).thenAnswer(
            (_) => Stream.fromIterable([
              [], // État initial
              [testProjets[0]], // Après création
            ]),
          );
          when(
            () => mockService.create(any()),
          ).thenAnswer((_) async => testProjets[0]);
        },

        act: (container) async {
          final notifier = container.read(projetNotifierProvider.notifier);
          await notifier.create(testProjets[0]);
        },

        expect: () => [
          isA<AsyncLoading<List<Projet>>>(),
          predicate<AsyncValue<List<Projet>>>(
            (state) => state.hasValue && state.value!.isEmpty,
            'Initial empty state',
          ),
          predicate<AsyncValue<List<Projet>>>(
            (state) =>
                state.hasValue &&
                state.value!.length == 1 &&
                state.value!.first.id == testProjets[0].id,
            'State after creation',
          ),
        ],
      );

      testProvider<AsyncValue<List<Projet>>>(
        'should handle update operation',
        provider: projetNotifierProvider,

        overrides: [projetServiceProvider.overrideWith((ref) => mockService)],

        setUp: () {
          final updatedProjet = testProjets[0].copyWith(
            nom: 'Projet Modifié',
            updatedAt: DateTime.now(),
          );

          when(() => mockService.watchAll()).thenAnswer(
            (_) => Stream.fromIterable([
              [testProjets[0]], // État initial avec un projet
              [updatedProjet], // Après modification
            ]),
          );
          when(
            () => mockService.update(any()),
          ).thenAnswer((_) async => updatedProjet);
        },

        act: (container) async {
          final notifier = container.read(projetNotifierProvider.notifier);
          final updatedProjet = testProjets[0].copyWith(nom: 'Projet Modifié');
          await notifier.update(updatedProjet);
        },

        expect: () => [
          isA<AsyncLoading<List<Projet>>>(),
          predicate<AsyncValue<List<Projet>>>(
            (state) =>
                state.hasValue && state.value!.first.nom == testProjets[0].nom,
            'Initial state',
          ),
          predicate<AsyncValue<List<Projet>>>(
            (state) =>
                state.hasValue && state.value!.first.nom == 'Projet Modifié',
            'State after update',
          ),
        ],
      );

      testProvider<AsyncValue<List<Projet>>>(
        'should handle delete operation',
        provider: projetNotifierProvider,

        overrides: [projetServiceProvider.overrideWith((ref) => mockService)],

        setUp: () {
          when(() => mockService.watchAll()).thenAnswer(
            (_) => Stream.fromIterable([
              [testProjets[0]], // État avec un projet
              [], // Après suppression
            ]),
          );
          when(() => mockService.delete(any())).thenAnswer((_) async {});
        },

        act: (container) async {
          final notifier = container.read(projetNotifierProvider.notifier);
          await notifier.delete(testProjets[0].id);
        },

        expect: () => [
          isA<AsyncLoading<List<Projet>>>(),
          predicate<AsyncValue<List<Projet>>>(
            (state) => state.hasValue && state.value!.length == 1,
            'State with one projet',
          ),
          predicate<AsyncValue<List<Projet>>>(
            (state) => state.hasValue && state.value!.isEmpty,
            'State after deletion',
          ),
        ],
      );
    });

    group('Error Handling in Notifier', () {
      testProvider<AsyncValue<List<Projet>>>(
        'should handle service errors during create',
        provider: projetNotifierProvider,

        overrides: [projetServiceProvider.overrideWith((ref) => mockService)],

        setup: () {
          when(
            () => mockService.watchAll(),
          ).thenAnswer((_) => Stream.value([]));
          when(
            () => mockService.create(any()),
          ).thenThrow(Exception('Creation failed'));
        },

        act: (container) async {
          final notifier = container.read(projetNotifierProvider.notifier);
          try {
            await notifier.create(testProjets[0]);
          } catch (e) {
            // Expected error
          }
        },

        expect: () => [
          isA<AsyncLoading<List<Projet>>>(),
          predicate<AsyncValue<List<Projet>>>(
            (state) => state.hasValue && state.value!.isEmpty,
            'Should maintain empty state after failed creation',
          ),
        ],
      );
    });
  });
}
