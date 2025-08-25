import 'package:bat_track_v1/data/local/models/projets/projet.dart';
import 'package:bat_track_v1/features/projet/controllers/notifiers/projet_list_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod_test/riverpod_test.dart';

void main() {
  testStateNotifier<ProjetListNotifier, AsyncValue<List<Projet>>>(
    'adding a project updates state',
    act:
        (notifier) => notifier.addProject(
          Projet(
            id: '1',
            nom: 'Projet Test',
            currentUserId: 'Peopole',
            localDraft: {},
            cloudVersion: {},
            createdBy: 'Penelope',
            company: 'Criuzette',
            specialite: 'Revetements sol',
            members: ['teck 20', 'teck 01'],
            budgetEstime: 200000,
            assignedUserIds: ['teck 01', 'teck 2O'],
            dateDebut: DateTime.now(),
            dateFin: DateTime(1),
            description: 'Pose de carelage',
            localisation: '1 rue de lanusse, 31200 ',
            deadLine: DateTime(1),
            updatedAt: DateTime.now(),
            status: ProjetStatus.draft,
            superUtilisateurValide: false,
            techniciensValides: true,
            clientValide: true,
            chefDeProjetValide: true,
          ),
        ),
    expect:
        () => emitsInOrder([
          AsyncValue.data([]),
          AsyncValue.data([
            Projet(
              id: '1',
              nom: 'Projet Test',
              currentUserId: 'Peopole',
              localDraft: {},
              cloudVersion: {},
              createdBy: 'Penelope',
              company: 'Criuzette',
              specialite: 'Revetements sol',
              members: ['teck 20', 'teck 01'],
              budgetEstime: 200000,
              assignedUserIds: ['teck 01', 'teck 2O'],
              dateDebut: DateTime.now(),
              dateFin: DateTime(1),
              description: 'Pose de carelage',
              localisation: '1 rue de lanusse, 31200 ',
              deadLine: DateTime(1),
              updatedAt: DateTime.now(),
              status: ProjetStatus.draft,
              superUtilisateurValide: false,
              techniciensValides: true,
              clientValide: true,
              chefDeProjetValide: true,
            ),
          ]), // état après ajout
        ]),
    provider: projetListProvider,
  );
}
