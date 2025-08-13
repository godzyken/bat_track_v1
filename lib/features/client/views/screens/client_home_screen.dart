import 'package:bat_track_v1/core/responsive/wrapper/responsive_layout.dart';
import 'package:bat_track_v1/data/local/models/base/access_policy_interface.dart';
import 'package:bat_track_v1/data/local/models/base/has_acces_control.dart';
import 'package:bat_track_v1/data/local/services/service_type.dart';
import 'package:bat_track_v1/features/auth/data/providers/auth_state_provider.dart';
import 'package:bat_track_v1/models/providers/asynchrones/entity_list_future_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/local/models/index_model_extention.dart';
import '../../../../models/views/screens/screen_wrapper.dart';
import '../../../../models/views/widgets/entity_list.dart';

class ClientHomeScreen extends ConsumerWidget {
  const ClientHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final info = context.responsiveInfo(ref);
    final currentUser = ref.watch(appUserProvider);

    if (currentUser.value == null || currentUser.value?.role != 'client') {
      return const Center(child: Text("Accès réservé aux clients."));
    }

    final userId = currentUser.value?.isChefDeProjet;

    final projects = ref.watch(allProjectsFutureProvider);
    final chantiers = ref.watch(allChantiersFutureProvider);
    final interventions = ref.watch(allInterventionsFutureProvider);

    // Projets créés par le client
    final clientProjects = projects.whenData(
      (list) => list.where((p) => p.createdBy == userId).toList(),
    );

    // Chantiers associés aux projets du client
    final clientChantiers = chantiers.whenData(
      (list) =>
          list
              .where(
                (c) =>
                    clientProjects.value?.any(
                      (p) => p.id == c.chefDeProjetId,
                    ) ??
                    false,
              )
              .toList(),
    );

    // Interventions associées aux chantiers du client
    final clientInterventions = interventions.whenData(
      (list) =>
          list
              .where(
                (i) =>
                    clientChantiers.value?.any((c) => c.id == i.chantierId) ??
                    false,
              )
              .toList(),
    );

    final isClient = currentUser.value?.role == 'client';
    final isTech = currentUser.value?.role == 'tech';

    return ScreenWrapper(
      title: 'Espace Client',
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Mes projets", style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            EntityList<Projet>(
              items: clientProjects,
              boxName: 'project',
              infoOverride: info,
              currentRole: currentUser.value!.role,
              currentUserId: currentUser.value!.id,
              readOnly: !isClient && !isTech,
              onEdit: (projects) {
                showEntityFormDialog<Projet>(
                  context: context,
                  ref: ref,
                  role: currentUser.value!.role,
                  onSubmit: (updated) async {
                    await projetService.update(updated, projects.id);
                  },
                  fromJson: Projet.fromJson,
                  createEmpty: Projet.mock,
                );
              },
              onCreate:
                  isClient
                      ? () => showEntityFormDialog(
                        context: context,
                        ref: ref,
                        role: currentUser.value!.role,
                        createEmpty: Projet.mock,
                        fromJson: Projet.fromJson,
                        onSubmit: (projects) async {
                          await projetService.save(projects, projects.id);
                        },
                      )
                      : () {},
              onDelete: isClient ? (id) => projetService.delete(id) : null,
              policy: MultiRolePolicy(),
            ),
            const SizedBox(height: 24),

            Text(
              "Chantiers associés",
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            EntityList<Chantier>(
              items: clientChantiers,
              boxName: 'chantierBox',
              infoOverride: info,
              currentRole: currentUser.value!.role,
              currentUserId: currentUser.value!.id,
              readOnly: !isClient && !isTech,
              onEdit: (chantier) {
                showEntityFormDialog<Chantier>(
                  context: context,
                  ref: ref,
                  role: currentUser.value!.role,
                  onSubmit: (updated) async {
                    await chantierService.update(updated, chantier.id);
                  },
                  fromJson: Chantier.fromJson,
                  createEmpty: Chantier.mock,
                );
              },
              onCreate:
                  isClient
                      ? () => showEntityFormDialog(
                        context: context,
                        ref: ref,
                        role: currentUser.value!.role,
                        createEmpty: Chantier.mock,
                        fromJson: Chantier.fromJson,
                        onSubmit: (chantier) async {
                          await chantierService.save(chantier, chantier.id);
                        },
                      )
                      : () {},
              onDelete: isClient ? (id) => chantierService.delete(id) : null,
              policy: MultiRolePolicy(),
            ),
            const SizedBox(height: 24),

            Text(
              "Interventions prévues",
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            EntityList<Intervention>(
              items: clientInterventions,
              boxName: 'interventionBox',
              infoOverride: info,
              currentRole: currentUser.value!.role,
              currentUserId: currentUser.value!.id,
              readOnly: !isClient && !isTech,
              onEdit: (intervention) {
                showEntityFormDialog<Intervention>(
                  context: context,
                  ref: ref,
                  role: currentUser.value!.role,
                  onSubmit: (updated) async {
                    await interventionService.update(updated, intervention.id);
                  },
                  fromJson: Intervention.fromJson,
                  createEmpty: Intervention.mock,
                );
              },
              onCreate:
                  isClient
                      ? () => showEntityFormDialog(
                        context: context,
                        ref: ref,
                        role: currentUser.value!.role,
                        createEmpty: Intervention.mock,
                        fromJson: Intervention.fromJson,
                        onSubmit: (intervention) async {
                          await interventionService.save(
                            intervention,
                            intervention.id,
                          );
                        },
                      )
                      : () {},
              onDelete:
                  isClient ? (id) => interventionService.delete(id) : null,
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
