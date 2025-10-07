import 'package:bat_track_v1/data/local/models/projets/projet.dart';
import 'package:bat_track_v1/data/local/providers/hive_provider.dart';
import 'package:bat_track_v1/features/auth/data/providers/current_user_provider.dart';
import 'package:bat_track_v1/features/projet/controllers/providers/projet_list_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:riverpod_test/riverpod_test.dart';

import '../../helpers/provider_test_helpers.dart';
import '../../mocks/mock_data_factories.dart';
import '../../mocks/mock_services.dart';

void main() {
  group('Projet Providers', () {
    late MockSyncedEntityService<Projet> mockService;
    late List<Projet> testProjets;

    setUp(() {
      mockService = MockSyncedEntityService<Projet>();
      testProjets = MockDataFactories.createProjetList(3);

      // Configuration par défaut du mock
      when(
        () => mockService.watchAll(),
      ).thenAnswer((_) => Stream.value(testProjets));
    });

    testProvider<AsyncValue<List<Projet>>>(
      'projectListProvider should emit list of projets',
      provider: projectListProvider,

      overrides: [projetServiceProvider.overrideWith((ref) => mockService)],

      expect:
          () => [
            isA<AsyncLoading<List<Projet>>>(),
            ProviderTestHelpers.hasAsyncListLength<Projet>(3),
          ],

      verify: () {
        verify(() => mockService.watchAll()).called(1);
      },
    );

    testProvider<AsyncValue<List<Projet>>>(
      'projectListProvider should handle service errors',
      provider: projectListProvider,

      overrides: [
        projetServiceProvider.overrideWith((ref) {
          final mock = MockSyncedEntityService<Projet>();
          when(
            () => mock.watchAll(),
          ).thenAnswer((_) => Stream.error(Exception('Database error')));
          return mock;
        }),
      ],

      expect:
          () => [
            isA<AsyncLoading<List<Projet>>>(),
            ProviderTestHelpers.hasAsyncError('Database error'),
          ],
    );

    group('Filtered Providers', () {
      testProvider<AsyncValue<List<Projet>>>(
        'should filter projets by user',
        provider: projectListProvider, // Assuming you have a filtered version

        overrides: [
          currentUserProvider.overrideWith(
            (ref) =>
                AsyncValue.data(MockDataFactories.createUser(uid: 'user1')),
          ),
          projetServiceProvider.overrideWith((ref) {
            final userProjets =
                testProjets.where((p) => p.createdBy == 'user1').toList();
            when(
              () => mockService.watchAll(),
            ).thenAnswer((_) => Stream.value(userProjets));
            return mockService;
          }),
        ],

        expect:
            () => [
              isA<AsyncLoading<List<Projet>>>(),
              predicate<AsyncValue<List<Projet>>>(
                (asyncValue) =>
                    asyncValue.hasValue &&
                    asyncValue.value!.every((p) => p.createdBy == 'user1'),
                'All projets belong to user1',
              ),
            ],
      );
    });
  });
}
