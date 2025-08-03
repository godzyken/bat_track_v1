import 'package:bat_track_v1/features/projet/views/screens/projet_form_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/local/models/projets/projet.dart';
import '../../../../main.dart';
import '../../../../models/views/widgets/entity_card.dart';
import '../../../auth/data/providers/auth_state_provider.dart';

final projectListProvider = StreamProvider<List<Projet>>((ref) {
  final firestore = ref.watch(firestoreProvider);
  return firestore
      .collection('projects')
      .snapshots()
      .map(
        (snapshot) =>
            snapshot.docs.map((doc) => Projet.fromJson(doc.data())).toList(),
      );
});

class ProjectListScreen extends ConsumerWidget {
  const ProjectListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncProjects = ref.watch(projectListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Liste des projets"),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _openProjectForm(context, ref),
          ),
        ],
      ),
      body: asyncProjects.when(
        data:
            (projects) => ListView.builder(
              itemCount: projects.length,
              itemBuilder: (context, index) {
                final project = projects[index];
                return EntityCard(
                  entity: project,
                  onEdit: () => _openProjectForm(context, ref),
                  onDelete: () => _deleteProject(context, ref, project),
                  showActions: true,
                );
              },
            ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => ErrorApp(message: 'Erreur in Projet : $e'),
      ),
    );
  }

  void _openProjectForm(
    BuildContext context,
    WidgetRef ref, {
    Projet? project,
  }) {
    showDialog(
      context: context,
      builder: (context) => ProjectFormDialog(project: project),
    );
  }

  Future<void> _deleteProject(
    BuildContext context,
    WidgetRef ref,
    Projet project,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Supprimer le projet ?'),
            content: Text('Voulez-vous vraiment supprimer "${project.nom}" ?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Annuler'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Supprimer'),
              ),
            ],
          ),
    );
    if (confirm == true) {
      final doc = ref
          .read(firestoreProvider)
          .collection('projects')
          .doc(project.id);
      await doc.delete();
    }
  }
}
