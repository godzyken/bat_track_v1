import 'package:bat_track_v1/core/responsive/wrapper/responsive_layout.dart';
import 'package:bat_track_v1/models/views/widgets/entity_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/local/models/base/access_policy_interface.dart';
import '../../../../data/local/models/index_model_extention.dart';
import '../../../../data/local/services/service_type.dart';
import '../../../../models/providers/asynchrones/entity_list_future_provider.dart';
import '../../../../models/views/screens/screen_wrapper.dart';
import '../../../auth/data/providers/current_user_provider.dart';

class TechHomeScreen extends ConsumerWidget {
  const TechHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final info = context.responsiveInfo(ref);
    final currentUser = ref.watch(currentUserProvider);

    if (currentUser == null || currentUser.role.name != 'technicien') {
      return const Center(child: Text("Accès réservé aux techniciens."));
    }

    final userId = currentUser.id;

    final isAdmin = currentUser.role.name == 'admin';
    final isTech = currentUser.role.name == 'tech';

    final projects = ref.watch(allProjectsFutureProvider);
    final chantiers = ref.watch(allChantiersFutureProvider);
    final interventions = ref.watch(allInterventionsFutureProvider);

    final assignedProjects = projects.whenData(
      (list) => list.where((p) => p.members.contains(userId)).toList(),
    );

    final assignedChantiers = chantiers.whenData(
      (list) => list.where((c) => c.technicienIds.contains(userId)).toList(),
    );

    final upcomingInterventions = interventions.whenData(
      (list) =>
          list
              .where(
                (i) =>
                    i.technicienId == userId &&
                    i.create != null &&
                    i.create.isAfter(DateTime.now()),
              )
              .toList()
            ..sort((a, b) => a.create.compareTo(b.create)),
    );

    return ScreenWrapper(
      title: 'Espace Technicien',
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Projets assignés",
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            EntityList<Projet>(
              items: assignedProjects,
              boxName: 'projectBox',
              infoOverride: info,
              onCreate:
                  isAdmin && isTech
                      ? () {
                        showEntityFormDialog<Projet>(
                          context: context,
                          ref: ref,
                          role: currentUser.role.name,
                          onSubmit: (projet) async {
                            await projetService.save(projet, projet.id);
                          },
                          fromJson: Projet.fromJson,
                          createEmpty: Projet.mock,
                        );
                      }
                      : () {},
              onEdit: (projet) {
                showEntityFormDialog<Projet>(
                  context: context,
                  ref: ref,
                  role: currentUser.role.name,
                  onSubmit: (updated) async {
                    await projetService.update(updated, projet.id);
                  },
                  fromJson: Projet.fromJson,
                  createEmpty: Projet.mock,
                );
              },
              onDelete:
                  isAdmin && isTech ? (id) => projetService.delete(id) : null,
              readOnly: !isAdmin && !isTech,
              currentRole: currentUser.role.name,
              currentUserId: currentUser.id,
              policy: MultiRolePolicy(),
            ),
            const SizedBox(height: 24),

            Text(
              "Chantiers assignés",
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            EntityList<Chantier>(
              items: assignedChantiers,
              boxName: 'chantierBox',
              infoOverride: info,
              onCreate:
                  isAdmin && isTech
                      ? () {
                        showEntityFormDialog<Chantier>(
                          context: context,
                          ref: ref,
                          role: currentUser.role.name,
                          onSubmit: (chantier) async {
                            await chantierService.save(chantier, chantier.id);
                          },
                          fromJson: Chantier.fromJson,
                          createEmpty: Chantier.mock,
                        );
                      }
                      : () {},
              onEdit: (chantier) {
                showEntityFormDialog<Chantier>(
                  context: context,
                  ref: ref,
                  role: currentUser.role.name,
                  onSubmit: (updated) async {
                    await chantierService.update(updated, chantier.id);
                  },
                  fromJson: Chantier.fromJson,
                  createEmpty: Chantier.mock,
                );
              },
              onDelete:
                  isAdmin && isTech ? (id) => projetService.delete(id) : null,
              readOnly: !isAdmin && !isTech,
              currentRole: currentUser.role.name,
              currentUserId: currentUser.id,
              policy: MultiRolePolicy(),
            ),
            const SizedBox(height: 24),

            Text(
              "Interventions à venir",
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            EntityList<Intervention>(
              items: upcomingInterventions,
              boxName: 'interventionBox',
              infoOverride: info,
              onCreate:
                  isAdmin && isTech
                      ? () {
                        showEntityFormDialog<Projet>(
                          context: context,
                          ref: ref,
                          role: currentUser.role.name,
                          onSubmit: (projet) async {
                            await projetService.save(projet, projet.id);
                          },
                          fromJson: Projet.fromJson,
                          createEmpty: Projet.mock,
                        );
                      }
                      : () {},
              onEdit: (projet) {
                showEntityFormDialog<Projet>(
                  context: context,
                  ref: ref,
                  role: currentUser.role.name,
                  onSubmit: (updated) async {
                    await projetService.update(updated, projet.id);
                  },
                  fromJson: Projet.fromJson,
                  createEmpty: Projet.mock,
                );
              },
              onDelete:
                  isAdmin && isTech ? (id) => projetService.delete(id) : null,
              readOnly: !isAdmin && !isTech,
              currentRole: currentUser.role.name,
              currentUserId: currentUser.id,
              policy: MultiRolePolicy(),
            ),
            const SizedBox(height: 32),

            Center(
              child: ElevatedButton.icon(
                onPressed: () => Navigator.pushNamed(context, '/profil'),
                icon: const Icon(Icons.person),
                label: const Text("Voir mon profil"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
