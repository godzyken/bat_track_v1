import 'package:bat_track_v1/data/local/models/projets/projet.dart';
import 'package:bat_track_v1/features/projet/controllers/providers/projet_list_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../data/projet_penelope_data.dart';

void main() {
  group('projectListProvider tests', () {
    test('projectListProvider emits 1 project', () async {
      final container = ProviderContainer(
        overrides: [
          projectListProvider.overrideWith(
            (ref) => Stream.value([
              Projet(
                id: '1',
                nom: 'Projet Test',
                description: '',
                dateDebut: DateTime.now(),
                dateFin: DateTime.now().add(const Duration(days: 500)),
                company: '',
                createdBy: '',
                members: [],
                clientValide: true,
                chefDeProjetValide: true,
                techniciensValides: true,
                superUtilisateurValide: false,
                cloudVersion: const {},
                localDraft: const {},
              ),
            ]),
          ),
        ],
      );
      addTearDown(container.dispose);

      final states = <AsyncValue<List<Projet>>>[];
      container.listen<AsyncValue<List<Projet>>>(
        projectListProvider,
        (previous, next) => states.add(next),
        fireImmediately: true,
      );

      await Future.delayed(const Duration(milliseconds: 10));

      expect(states, [
        const AsyncLoading<List<Projet>>(),
        predicate<AsyncValue<List<Projet>>>((a) {
          return a.hasValue &&
              a.value!.length == 1 &&
              a.value!.first.nom == 'Projet Test';
        }),
      ]);
    });

    test('projectListProvider emits updates when stream changes', () async {
      final container = ProviderContainer(
        overrides: [
          projectListProvider.overrideWith(
            (ref) => Stream.fromIterable([
              [
                Projet(
                  id: '1',
                  nom: 'Projet Initial',
                  description: '',
                  dateDebut: DateTime.now(),
                  dateFin: DateTime.now().add(const Duration(days: 30)),
                  company: '',
                  createdBy: '',
                  members: [],
                  clientValide: true,
                  chefDeProjetValide: true,
                  techniciensValides: true,
                  superUtilisateurValide: false,
                  cloudVersion: const {},
                  localDraft: const {},
                ),
              ],
              [
                Projet(
                  id: '1',
                  nom: 'Projet Initial',
                  description: '',
                  dateDebut: DateTime.now(),
                  dateFin: DateTime.now().add(const Duration(days: 30)),
                  company: '',
                  createdBy: '',
                  members: [],
                  clientValide: true,
                  chefDeProjetValide: true,
                  techniciensValides: true,
                  superUtilisateurValide: false,
                  cloudVersion: const {},
                  localDraft: const {},
                ),
                Projet(
                  id: '2',
                  nom: 'Projet Nouveau',
                  description: '',
                  dateDebut: DateTime.now(),
                  dateFin: DateTime.now().add(const Duration(days: 60)),
                  company: '',
                  createdBy: '',
                  members: [],
                  clientValide: true,
                  chefDeProjetValide: true,
                  techniciensValides: true,
                  superUtilisateurValide: false,
                  cloudVersion: const {},
                  localDraft: const {},
                ),
              ],
            ]),
          ),
        ],
      );
      addTearDown(container.dispose);

      final states = <AsyncValue<List<Projet>>>[];
      container.listen<AsyncValue<List<Projet>>>(
        projectListProvider,
        (previous, next) => states.add(next),
        fireImmediately: true,
      );

      await Future.delayed(const Duration(milliseconds: 10));

      expect(states.length, 3);
      expect(states[0], const AsyncLoading<List<Projet>>());
      expect(states[1].value!.length, 1);
      expect(states[2].value!.length, 2);
    });

    test('projectListProvider emits an error', () async {
      final container = ProviderContainer(
        overrides: [
          projectListProvider.overrideWith(
            (ref) => Stream<List<Projet>>.error(Exception('Firestore error')),
          ),
        ],
      );
      addTearDown(container.dispose);

      final states = <AsyncValue<List<Projet>>>[];
      container.listen<AsyncValue<List<Projet>>>(
        projectListProvider,
        (previous, next) => states.add(next),
        fireImmediately: true,
      );

      await Future.delayed(const Duration(milliseconds: 10));

      expect(states[0], const AsyncLoading<List<Projet>>());
      expect(states[1].hasError, true);
      expect(states[1].error.toString(), contains('Firestore error'));
    });

    test('projectListProvider emits 1 projet complet avec chantiers et étapes', () async {
      final container = ProviderContainer(
        overrides: [
          projectListProvider.overrideWith((ref) => Stream.value([projetPenelope])),
        ],
      );
      addTearDown(container.dispose);

      await Future.delayed(const Duration(milliseconds: 10));
      final state = container.read(projectListProvider);

      expect(state.hasValue, true);
      expect(state.value!.length, 1);
      expect(state.value!.first.chantiers!.isNotEmpty, true);
    });
  });
}
