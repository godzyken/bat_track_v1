import 'package:bat_track_v1/features/projet/controllers/notifiers/projet_list_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_models/shared_models.dart';

class _FakeProjetListNotifier extends ProjetListNotifier {
  final List<Projet> projects = [];

  @override
  Future<List<Projet>> build() async {
    return projects;
  }

  @override
  Future<void> addProject(Projet projet) async {
    projects.add(projet);
    state = AsyncValue.data(List.from(projects));
  }
}

void main() {
  test('adding a project updates state', () async {
    final projet = Projet(
      id: '1',
      clientId: 'client_1',
      nom: 'Projet Test',
      description: 'Pose de carelage',
      dateDebut: DateTime.now(),
      dateFin: DateTime.now().add(const Duration(days: 30)),
      company: 'Criuzette',
      createdBy: 'Penelope',
      members: const ['teck 20', 'teck 01'],
      assignedUserIds: const ['teck 01', 'teck 2O'],
      status: ProjetStatus.draft,
      superUtilisateurValide: false,
      techniciensValides: true,
      clientValide: true,
      chefDeProjetValide: true,
      cloudVersion: const {},
      localDraft: const {},
    );

    final container = ProviderContainer(
      overrides: [
        projetListProvider.overrideWith(() => _FakeProjetListNotifier()),
      ],
    );
    addTearDown(container.dispose);
    container.listen(projetListProvider, (_, _) {});

    final notifier = container.read(projetListProvider.notifier);
    await notifier.addProject(projet);

    final state = container.read(projetListProvider);
    expect(state.value, contains(projet));
  });
}
