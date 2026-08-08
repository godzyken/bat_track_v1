import 'package:bat_track_v1/data/local/models/projets/projet.dart';
import 'package:bat_track_v1/features/projet/controllers/notifiers/projet_list_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('adding a project updates state', () async {
    final container = ProviderContainer(
      overrides: [
        // On pourrait overrider le service si besoin
      ],
    );
    addTearDown(container.dispose);

    final notifier = container.read(projetListProvider.notifier);

    final projet = Projet(
      id: '1',
      nom: 'Projet Test',
      currentUserId: 'Peopole',
      localDraft: const {},
      cloudVersion: const {},
      createdBy: 'Penelope',
      company: 'Criuzette',
      specialite: 'Revetements sol',
      members: const ['teck 20', 'teck 01'],
      budgetEstime: 200000,
      assignedUserIds: const ['teck 01', 'teck 2O'],
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
    );

    // Initial state check
    // expect(container.read(projetListProvider), const AsyncValue.data([]));

    await notifier.addProject(projet);

    // Final state check
    final state = container.read(projetListProvider);
    expect(state.value, contains(projet));
  });
}
