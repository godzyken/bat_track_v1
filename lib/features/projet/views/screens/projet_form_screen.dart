import 'package:bat_track_v1/data/local/models/base/has_acces_control.dart';
import 'package:bat_track_v1/data/local/models/projets/projet.dart';
import 'package:bat_track_v1/features/auth/data/providers/current_user_provider.dart';
import 'package:bat_track_v1/models/views/widgets/entity_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_models/shared_models.dart';

import '../../../auth/data/providers/auth_state_provider.dart';
import '../../../auth/views/widgets/user_dropdown_field.dart';
import '../../../technicien/controllers/notifiers/technicien_list_notifier.dart';

class ProjectFormDialog extends ConsumerStatefulWidget {
  final Projet? project;

  const ProjectFormDialog({super.key, this.project});

  @override
  ConsumerState<ProjectFormDialog> createState() => _ProjectFormDialogState();
}

class _ProjectFormDialogState extends ConsumerState<ProjectFormDialog> {
  String? selectedClientId;
  List<String> selectedTechniciens = [];
  bool clientValide = false;
  bool chefDeProjetValide = false;
  bool superUtilisateurValide = false;

  @override
  void initState() {
    super.initState();
    if (widget.project != null) {
      selectedClientId = widget.project!.ownerId;
      selectedTechniciens = [...widget.project!.members];
      clientValide = widget.project!.clientValide;
      chefDeProjetValide = widget.project!.chefDeProjetValide;
      superUtilisateurValide = widget.project!.superUtilisateurValide;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.project != null;
    final userAsync = ref.watch(currentUserProvider);
    final techsAsync = ref.watch(techniciensListProvider);

    if (userAsync.isLoading || techsAsync.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final user = userAsync.value!;
    final techs = techsAsync.value!;

    return EntityForm<Projet>(
      chantierId: isEditing ? 'Modifier le projet' : 'Créer un projet',
      initialValue: widget.project,
      createEmpty: () => Projet.mock(),
      fromJson: (json) => Projet.fromJson(json),
      onSubmit: (project) async {
        // ⚡ Gestion validation par rôle
        final updatedProject = project.copyWith(
          createdBy: selectedClientId ?? project.createdBy,
          members: selectedTechniciens,
          clientValide: clientValide,
          chefDeProjetValide: chefDeProjetValide,
          superUtilisateurValide: superUtilisateurValide,
        );

        final doc = ref
            .read(firestoreProvider)
            .collection('projects')
            .doc(updatedProject.id);
        await doc.set(updatedProject.toJson());
        if (context.mounted) {
          context.pop();
        }
      },
      customFieldBuilder:
          (context, key, value, controller, onChanged, expertMode) {
            // 🔹 Choix du client (toujours accessible au admin)
            if (key == 'clientId' &&
                (AppUserAccess(user).isAdmin || !isEditing)) {
              return UserDropdownField(
                role: 'client',
                label: 'Client assigné',
                selectedUserId: selectedClientId ?? '',
                onChanged: (newId) => setState(() => selectedClientId = newId),
              );
            }

            // 🔹 Multi-sélection technicien pour admin / chef de projet
            if (key == 'technicienIds' &&
                value is List &&
                (AppUserAccess(user).isAdmin || user.isChefDeProjet)) {
              return Wrap(
                spacing: 8,
                children: techs.map((t) {
                  final isSelected = selectedTechniciens.contains(t.id);
                  return FilterChip(
                    label: Text('${t.nom} (${t.specialite})'),
                    selected: isSelected,
                    onSelected: (sel) {
                      setState(() {
                        if (sel) {
                          selectedTechniciens.add(t.id);
                        } else {
                          selectedTechniciens.remove(t.id);
                        }
                      });
                    },
                  );
                }).toList(),
              );
            }

            // 🔹 Validation par rôle
            if (key == 'clientValide' && AppUserAccess(user).isClient) {
              return CheckboxListTile(
                title: const Text('Je valide le projet'),
                value: clientValide,
                onChanged: (v) => setState(() => clientValide = v ?? false),
              );
            }

            if (key == 'chefDeProjetValide' && user.isChefDeProjet) {
              return CheckboxListTile(
                title: const Text('Validation Chef de projet'),
                value: chefDeProjetValide,
                onChanged: (v) =>
                    setState(() => chefDeProjetValide = v ?? false),
              );
            }

            if (key == 'superUtilisateurValide' &&
                AppUserAccess(user).isAdmin) {
              return CheckboxListTile(
                title: const Text('Validation Super Utilisateur'),
                value: superUtilisateurValide,
                onChanged: (v) =>
                    setState(() => superUtilisateurValide = v ?? false),
              );
            }

            return null;
          },
    );
  }
}
