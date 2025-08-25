import 'package:bat_track_v1/core/responsive/wrapper/responsive_layout.dart';
import 'package:bat_track_v1/data/local/providers/hive_provider.dart';
import 'package:bat_track_v1/features/projet/views/screens/projet_form_screen.dart';
import 'package:bat_track_v1/models/views/screens/exeception_screens.dart';
import 'package:bat_track_v1/models/views/widgets/entity_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/local/models/projets/projet.dart';
import '../../../../data/local/models/utilisateurs/technicien.dart';
import '../../../auth/data/providers/auth_state_provider.dart';
import '../../../auth/data/providers/current_user_provider.dart';
import '../../../technicien/controllers/notifiers/technicien_list_notifier.dart';
import '../../../technicien/views/widgets/assign_technicien_dialog.dart';
import '../../controllers/providers/projet_list_provider.dart';
import '../../domain/rules/projet_policy.dart';

class ProjectListScreen extends ConsumerWidget {
  const ProjectListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncProjects = ref.watch(projectListProvider);
    final asyncTechniciens = ref.watch(techniciensListProvider);
    final currentUser = ref.watch(currentUserProvider).value;
    final info = context.responsiveInfo(ref);
    final policy = ProjetPolicy();

    if (currentUser == null) {
      return const Center(child: Text('Utilisateur non connecté'));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Liste des projets"),
        actions: [
          if (policy.canCreate(currentUser))
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => _openProjectForm(context, ref, asyncTechniciens),
              tooltip: 'Créer un projet',
            ),
        ],
      ),
      body: asyncProjects.when(
        data: (projects) {
          if (projects.isEmpty) {
            return const Center(child: Text("Aucun Projet disponible"));
          }
          if (info.isMobile) {
            return ListView.builder(
              itemCount: projects.length,
              itemBuilder: (context, index) {
                final project = projects[index];
                if (!policy.canRead(currentUser, project)) {
                  return const SizedBox.shrink();
                }
                return EntityCard(
                  entity: project,
                  onEdit:
                      policy.canEdit(currentUser, project)
                          ? () => _openProjectForm(
                            context,
                            ref,
                            asyncTechniciens,
                            project: project,
                          )
                          : null,
                  onDelete:
                      policy.canDelete(currentUser, project)
                          ? () => _deleteProject(context, ref, project)
                          : null,
                  showActions: true,
                  trailingActions: [
                    if (policy.canValidate(currentUser, project))
                      IconButton(
                        icon: const Icon(Icons.check_circle),
                        tooltip: "Valider",
                        onPressed: () async {
                          await _validateProject(ref, project);
                        },
                      ),
                    if (policy.canAssignTech(currentUser, project))
                      IconButton(
                        icon: const Icon(Icons.person_add),
                        tooltip: "Assigner technicien",
                        onPressed:
                            () => _assignTechnicien(context, ref, project),
                      ),
                  ],
                );
              },
            );
          } else {
            final crossAxisCount = info.isTablet ? 2 : 4;
            return GridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 4 / 3,
              ),
              itemCount: projects.length,
              itemBuilder: (context, index) {
                final projet = projects[index];
                if (!policy.canRead(currentUser, projet)) {
                  return const SizedBox.shrink();
                }

                return EntityCard(
                  entity: projet,
                  onEdit:
                      () => _openProjectForm(
                        context,
                        ref,
                        asyncTechniciens,
                        project: projet,
                      ),
                  onDelete: () => _deleteProject(context, ref, projet),
                  showActions: true,
                  trailingActions: [
                    if (policy.canValidate(currentUser, projet))
                      IconButton(
                        icon: const Icon(Icons.check_circle),
                        tooltip: "Valider",
                        onPressed: () async {
                          await _validateProject(ref, projet);
                        },
                      ),
                    if (policy.canAssignTech(currentUser, projet))
                      IconButton(
                        icon: const Icon(Icons.person_add),
                        tooltip: "Assigner technicien",
                        onPressed:
                            () => _assignTechnicien(context, ref, projet),
                      ),
                  ],
                );
              },
            );
          }
        },
        loading: () => const LoadingApp(),
        error: (e, st) => ErrorApp(message: 'Erreur in Projet List: $e'),
      ),
    );
  }

  void _openProjectForm(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<List<Technicien>> asyncTechniciens, {
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

  Future<void> _validateProject(WidgetRef ref, Projet projet) async {
    final updated = projet.copyWith(
      status: ProjetStatus.validated,
      updatedAt: DateTime.now(),
    );
    await ref
        .read(firestoreProvider)
        .collection('projects')
        .doc(projet.id)
        .set(updated.toJson());
  }

  void _assignTechnicien(
    BuildContext context,
    WidgetRef ref,
    Projet projet,
  ) async {
    final currentUser = ref.read(currentUserProvider).value;
    if (currentUser == null) return;

    // Vérifie la policy avant d’ouvrir
    final policy = ProjetPolicy();
    if (!policy.canAssignTech(currentUser, projet)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vous n'avez pas les droits")),
      );
      return;
    }

    final selectedTechs = await showDialog<List<String>>(
      context: context,
      builder: (_) => AssignTechnicienDialog(projet: projet),
    );

    if (selectedTechs != null) {
      final updated = projet.copyWith(
        assignedUserIds: selectedTechs,
        updatedAt: DateTime.now(),
      );
      await ref.read(projetServiceProvider).updateEntity(updated);
    }
  }
}
