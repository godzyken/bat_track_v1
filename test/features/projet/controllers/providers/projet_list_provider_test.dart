import 'dart:developer' as developer;

import 'package:bat_track_v1/data/local/models/projets/projet.dart';
import 'package:bat_track_v1/features/projet/controllers/providers/projet_list_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod_test/riverpod_test.dart';

import '../../data/list_data.dart';
import '../../data/projet_penelope_data.dart';
import 'mock_stream_provider.dart';

void main() {
  testProvider<AsyncValue<List<Projet>>>(
    'projectListProvider emits 1 project (matchers)',
    provider: projectListProvider,

    overrides: [
      projectListProvider.overrideWith(
        (ref) => Stream.value([
          Projet(
            id: '1',
            nom: 'Projet Test',
            description: '',
            dateDebut: DateTime.now(),
            dateFin: DateTime.now().add(Duration(days: 500)),
            company: '',
            createdBy: '',
            members: [],
            clientValide: true,
            chefDeProjetValide: true,
            techniciensValides: true,
            superUtilisateurValide: false,
            cloudVersion: {},
            localDraft: {},
          ),
        ]),
      ),
    ],

    expect: () => <dynamic>[
      isA<AsyncLoading<List<Projet>>>(),
      predicate<AsyncValue<List<Projet>>>((a) {
        final ok =
            a.hasValue &&
            a.value!.length == 1 &&
            a.value!.first.nom == 'Projet Test';

        // petit developer.log pour debug (visible dans `flutter test`)
        if (!ok) {
          // va s’afficher si le matcher échoue
          developer.log('⚠️ State reçu: $a');
        }

        return ok;
      }, 'AsyncData avec 1 projet "Projet Test"'),
    ],

    wait: const Duration(milliseconds: 1),
    verify: () {
      developer.log(
        '✅ verify exécuté: projectListProvider a bien émis un projet',
      );
    },
  );

  testProvider<AsyncValue<List<Projet>>>(
    'projectListProvider emits updates when stream changes',
    provider: projectListProvider,

    overrides: [
      projectListProvider.overrideWith(
        (ref) => Stream.fromIterable([
          // 🔹 Premier snapshot : 1 projet
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

          // 🔹 Deuxième snapshot : 2 projets
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

    // 🔎 expect capture les états successifs :
    expect: () => <dynamic>[
      isA<AsyncLoading<List<Projet>>>(),
      predicate<AsyncValue<List<Projet>>>(
        (a) => a.hasValue && a.value!.length == 1,
        'AsyncData avec 1 projet',
      ),
      predicate<AsyncValue<List<Projet>>>(
        (a) => a.hasValue && a.value!.length == 2,
        'AsyncData avec 2 projets',
      ),
    ],

    wait: const Duration(milliseconds: 10),

    verify: () {
      developer.log(
        '✅ verify exécuté: projectListProvider a bien émis 1 puis 2 projets',
      );
    },
  );

  testProvider<AsyncValue<List<Projet>>>(
    'projectListProvider emits updates over time (Stream.periodic)',
    provider: projectListProvider,

    overrides: [
      projectListProvider.overrideWith((ref) {
        // 🔹 Émet une nouvelle liste toutes les 50ms
        return Stream.periodic(const Duration(milliseconds: 50), (count) {
          if (count == 0) {
            // Premier event : 1 projet
            return [
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
            ];
          } else {
            // Deuxième event : 2 projets
            return [
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
            ];
          }
        }).take(2); // on limite à 2 events pour ne pas boucler
      }),
    ],

    expect: () => <dynamic>[
      isA<AsyncLoading<List<Projet>>>(),
      predicate<AsyncValue<List<Projet>>>(
        (a) => a.hasValue && a.value!.length == 1,
        'AsyncData avec 1 projet',
      ),
      predicate<AsyncValue<List<Projet>>>(
        (a) => a.hasValue && a.value!.length == 2,
        'AsyncData avec 2 projets',
      ),
    ],

    // ⏳ On attend assez longtemps pour laisser les 2 events arriver
    wait: const Duration(milliseconds: 200),

    verify: () {
      developer.log(
        '✅ verify exécuté: projectListProvider a bien émis 1 puis 2 projets au fil du temps',
      );
    },
  );

  testProvider<AsyncValue<List<Projet>>>(
    'projectListProvider emits an error (Stream.error)',
    provider: projectListProvider,

    overrides: [
      projectListProvider.overrideWith((ref) {
        // 🔹 On simule une erreur directe
        return Stream<List<Projet>>.error(Exception('Firestore error'));
      }),
    ],

    expect: () => <dynamic>[
      // D'abord un état de chargement
      isA<AsyncLoading<List<Projet>>>(),
      // Puis une erreur
      predicate<AsyncValue<List<Projet>>>(
        (a) => a.hasError && a.error.toString().contains('Firestore error'),
        'AsyncError avec "Firestore error"',
      ),
    ],

    wait: const Duration(milliseconds: 50),

    verify: () {
      developer.log(
        '✅ verify exécuté: projectListProvider a bien émis une erreur',
      );
    },
  );

  testProvider<AsyncValue<List<Projet>>>(
    'projectListProvider emits 1 project then an error',
    provider: projectListProvider,

    overrides: [
      projectListProvider.overrideWith((ref) {
        return (() async* {
          // ✅ Premier event : succès avec 1 projet
          yield [
            Projet(
              id: '1',
              nom: 'Projet Test',
              description: '',
              dateDebut: DateTime.now(),
              dateFin: DateTime.now().add(const Duration(days: 10)),
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
          ];

          // ❌ Ensuite : on simule une erreur
          throw Exception('Network error');
        })();
      }),
    ],

    expect: () => <dynamic>[
      // Toujours d’abord AsyncLoading
      isA<AsyncLoading<List<Projet>>>(),
      // Ensuite un AsyncData avec 1 projet
      predicate<AsyncValue<List<Projet>>>(
        (a) => a.hasValue && a.value!.length == 1,
        'AsyncData avec 1 projet',
      ),
      // Puis une erreur
      predicate<AsyncValue<List<Projet>>>(
        (a) => a.hasError && a.error.toString().contains('Network error'),
        'AsyncError avec "Network error"',
      ),
    ],

    wait: const Duration(milliseconds: 200),

    verify: () {
      developer.log(
        '✅ verify exécuté: projectListProvider a bien émis 1 projet puis une erreur',
      );
    },
  );

  testProvider<AsyncValue<List<Projet>>>(
    'projectListProvider emits 1 projet → 2 projets → erreur',
    provider: projectListProvider,

    overrides: [
      projectListProvider.overrideWith((ref) {
        return (() async* {
          // 🔄 1er snapshot : 1 projet
          yield [
            Projet(
              id: '1',
              nom: 'Projet A',
              description: '',
              dateDebut: DateTime.now(),
              dateFin: DateTime.now().add(const Duration(days: 10)),
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
          ];

          // 🔄 2e snapshot : 2 projets
          yield [
            Projet(
              id: '1',
              nom: 'Projet A',
              description: '',
              dateDebut: DateTime.now(),
              dateFin: DateTime.now().add(const Duration(days: 10)),
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
              nom: 'Projet B',
              description: '',
              dateDebut: DateTime.now(),
              dateFin: DateTime.now().add(const Duration(days: 20)),
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
          ];

          // ❌ Erreur simulée
          throw Exception('Firestore disconnected');
        })();
      }),
    ],

    expect: () => <dynamic>[
      // Toujours AsyncLoading au début
      isA<AsyncLoading<List<Projet>>>(),

      // Ensuite AsyncData avec 1 projet
      predicate<AsyncValue<List<Projet>>>(
        (a) => a.hasValue && a.value!.length == 1,
        'AsyncData avec 1 projet',
      ),

      // Puis AsyncData avec 2 projets
      predicate<AsyncValue<List<Projet>>>(
        (a) => a.hasValue && a.value!.length == 2,
        'AsyncData avec 2 projets',
      ),

      // Enfin AsyncError
      predicate<AsyncValue<List<Projet>>>(
        (a) =>
            a.hasError && a.error.toString().contains('Firestore disconnected'),
        'AsyncError avec "Firestore disconnected"',
      ),
    ],

    wait: const Duration(milliseconds: 200),

    verify: () {
      developer.log('✅ verify: Séquence 1 → 2 projets → erreur bien reçue');
    },
  );

  testProvider<AsyncValue<List<Projet>>>(
    'projectListProvider emits 1 → 2 projets → erreur → 3 projets',
    provider: projectListProvider,
    overrides: [
      projectListProvider.overrideWith(
        mockStreamProvider<Projet>(
          snapshots: [
            [projetPenelope], // snapshot 0 : 1 projet
            [
              projetPenelope,
              Projet(
                id: 'prj_002',
                nom: 'Rénovation villa Zeus',
                description: 'Projet secondaire',
                createdBy: 'cli_002',
                dateDebut: DateTime(2025, 4, 1),
                chantiers: [chantierPenelope],
                dateFin: DateTime(2025, 5, 1),
                company: 'Panhihi',
                members: [],
                assignedUserIds: [],
                clientValide: true,
                chefDeProjetValide: true,
                techniciensValides: true,
                superUtilisateurValide: false,
                cloudVersion: const {},
                localDraft: const {},
              ),
            ], // snapshot 1 : 2 projets
            [], // snapshot 2 : erreur simulée
            [
              projetPenelope,
              Projet(
                id: 'prj_002',
                nom: 'Rénovation villa Zeus',
                description: 'Projet secondaire',
                createdBy: 'cli_002',
                dateDebut: DateTime(2025, 4, 1),
                chantiers: [chantierPenelope],
                dateFin: DateTime(2025, 5, 1),
                company: 'Panhihi',
                members: [],
                assignedUserIds: [],
                clientValide: true,
                chefDeProjetValide: true,
                techniciensValides: true,
                superUtilisateurValide: false,
                cloudVersion: const {},
                localDraft: const {},
              ),
              Projet(
                id: 'prj_003',
                nom: 'Rénovation villa Athena',
                description: 'Projet tertiaire',
                createdBy: 'cli_003',
                dateDebut: DateTime(2025, 5, 1),
                chantiers: [chantierPenelope],
                dateFin: DateTime(2025, 6, 1),
                company: 'Panhihi',
                members: [],
                assignedUserIds: [],
                clientValide: true,
                chefDeProjetValide: true,
                techniciensValides: true,
                superUtilisateurValide: false,
                cloudVersion: const {},
                localDraft: const {},
              ),
            ], // snapshot 3 : 3 projets
          ],
          errors: {
            2: Exception('Firestore disconnected'),
          }, // erreur au snapshot 2
        ),
      ),
    ],
    expect: () => <dynamic>[
      isA<AsyncLoading<List<Projet>>>(),
      isA<AsyncData<List<Projet>>>()
          .having((r) => r.value, 'value', isNotEmpty)
          .having(
            (r) => r.value.first.nom,
            'nom du premier projet',
            'Rénovation villa Penelope',
          ),
      predicate<AsyncValue<List<Projet>>>(
        (a) => a.hasValue && a.value!.length == 1,
      ),
      predicate<AsyncValue<List<Projet>>>(
        (a) => a.hasValue && a.value!.length == 2,
      ),
      predicate<AsyncValue<List<Projet>>>(
        (a) =>
            a.hasError && a.error.toString().contains('Firestore disconnected'),
      ),
      predicate<AsyncValue<List<Projet>>>(
        (a) => a.hasValue && a.value!.length == 3,
      ),
    ],
    wait: const Duration(milliseconds: 300),
    verify: () => developer.log(
      '✅ verify: séquence complète 1→2→erreur→3 projets avec chantiers et étapes',
    ),
  );

  testProvider<AsyncValue<List<Projet>>>(
    'projectListProvider test 5 snapshots avec 2 erreurs simulées',
    provider: projectListProvider,
    overrides: [
      projectListProvider.overrideWith(
        mockStreamProvider<Projet>(
          snapshots: [
            [projetA], // snapshot 0
            [projetA, projetB], // snapshot 1 → erreur
            [projetA, projetB, projetC], // snapshot 2
            [projetA, projetB, projetC, projetD], // snapshot 3 → 2e erreur
            [projetA, projetB, projetC, projetD, projetE], // snapshot 4
          ],
          errors: {
            1: Exception('Firestore disconnected'),
            3: Exception('Firestore timeout'),
          },
        ),
      ),
    ],
    expect: () => <dynamic>[
      isA<AsyncLoading<List<Projet>>>(),
      isA<AsyncData<List<Projet>>>()
          .having((r) => r.value, 'value', isNotEmpty)
          .having(
            (r) => r.value.first.nom,
            'nom du premier projet',
            'Rénovation villa Penelope',
          ),
      predicate<AsyncValue<List<Projet>>>(
        (a) => a.hasValue && a.value!.length == 1,
      ),
      predicate<AsyncValue<List<Projet>>>(
        (a) =>
            a.hasError && a.error.toString().contains('Firestore disconnected'),
      ),
      predicate<AsyncValue<List<Projet>>>(
        (a) => a.hasValue && a.value!.length == 3,
      ),
      predicate<AsyncValue<List<Projet>>>(
        (a) => a.hasError && a.error.toString().contains('Firestore timeout'),
      ),
      predicate<AsyncValue<List<Projet>>>(
        (a) => a.hasValue && a.value!.length == 5,
      ),
    ],
    wait: const Duration(milliseconds: 300),
    verify: () => developer.log(
      '✅ Test Firestore réaliste avec 5 snapshots et 2 erreurs simulées passé',
    ),
  );

  testProvider<AsyncValue<List<Projet>>>(
    'projectListProvider emits 1 projet complet avec chantiers et étapes',
    provider: projectListProvider,
    overrides: [
      projectListProvider.overrideWith((ref) => Stream.value([projetPenelope])),
    ],
    expect: () => <dynamic>[
      isA<AsyncLoading<List<Projet>>>(),
      predicate<AsyncValue<List<Projet>>>(
        (a) =>
            a.hasValue &&
            a.value!.length == 1 &&
            a.value!.first.chantiers!.isNotEmpty &&
            a.value!.first.chantiers?.first.etapes.length == 3 &&
            a.value!.first.chantiers!.first.etapes.first.pieces.isNotEmpty,
      ),
    ],
    wait: const Duration(milliseconds: 1),
    verify: () {
      developer.log(
        "✅ verify: projetPenelope avec chantier et étapes est bien émis",
      );
    },
  );

  testProvider<AsyncValue<List<Projet>>>(
    'projectListProvider emits 1 → 2 projets → erreur → 3 projets avec chantiers et étapes',
    provider: projectListProvider,
    overrides: [
      projectListProvider.overrideWith(
        mockStreamProvider<Projet>(
          snapshots: [
            [projetPenelope], // snapshot 1
            [
              // snapshot 2
              projetPenelope,
              Projet(
                id: 'prj_002',
                nom: 'Rénovation villa Zeus',
                description: 'Projet secondaire de rénovation',
                createdBy: 'cli_002',
                dateDebut: DateTime(2025, 4, 1),
                chantiers: [chantierPenelope],
                dateFin: DateTime(2025, 5, 1),
                company: 'Panhihi',
                members: [],
                assignedUserIds: [],
                clientValide: true,
                chefDeProjetValide: true,
                techniciensValides: true,
                superUtilisateurValide: false,
                cloudVersion: const {},
                localDraft: const {},
              ),
            ],
            [], // snapshot 3 → erreur
            [
              // snapshot 4
              projetPenelope,
              Projet(
                id: 'prj_002',
                nom: 'Rénovation villa Zeus',
                description: 'Projet secondaire de rénovation',
                createdBy: 'cli_002',
                dateDebut: DateTime(2025, 4, 1),
                chantiers: [chantierPenelope],
                dateFin: DateTime(2025, 5, 1),
                company: 'Panhihi',
                members: [],
                assignedUserIds: [],
                clientValide: true,
                chefDeProjetValide: true,
                techniciensValides: true,
                superUtilisateurValide: false,
                cloudVersion: const {},
                localDraft: const {},
              ),
              Projet(
                id: 'prj_003',
                nom: 'Rénovation villa Athena',
                description: 'Projet tertiaire de rénovation',
                createdBy: 'cli_003',
                dateDebut: DateTime(2025, 5, 1),
                chantiers: [chantierPenelope],
                dateFin: DateTime(2025, 6, 1),
                company: 'Panhihi',
                members: [],
                assignedUserIds: [],
                clientValide: true,
                chefDeProjetValide: true,
                techniciensValides: true,
                superUtilisateurValide: false,
                cloudVersion: const {},
                localDraft: const {},
              ),
            ],
          ],
          errors: {2: Exception('Firestore disconnected')},
        ),
      ),
    ],
    expect: () => <dynamic>[
      isA<AsyncLoading<List<Projet>>>(),
      predicate<AsyncValue<List<Projet>>>(
        (a) =>
            a.hasValue &&
            a.value!.length == 1 &&
            a.value!.first.nom == 'Rénovation villa Penelope' &&
            a.value!.first.chantiers!.first.etapes.length == 3,
      ),
      predicate<AsyncValue<List<Projet>>>(
        (a) => a.hasValue && a.value!.length == 2,
      ),
      predicate<AsyncValue<List<Projet>>>(
        (a) =>
            a.hasError && a.error.toString().contains('Firestore disconnected'),
      ),
      predicate<AsyncValue<List<Projet>>>(
        (a) => a.hasValue && a.value!.length == 3,
      ),
    ],
    wait: const Duration(milliseconds: 300),
    verify: () => developer.log(
      '✅ séquence complète, 1→2→erreur→3 projets avec chantiers et étapes, validée',
    ),
  );
}
