import 'package:bat_track_v1/core/responsive/wrapper/responsive_layout.dart';
import 'package:bat_track_v1/features/auth/data/providers/current_user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_models/shared_models.dart';

import '../../../../data/local/models/base/access_policy_interface.dart';
import '../../../../data/local/models/index_model_extention.dart';
import '../../../../data/local/services/service_type.dart';
import '../../../../models/providers/asynchrones/entity_list_future_provider.dart';
import '../../../../models/views/screens/screen_wrapper.dart';
import '../../../../models/views/widgets/entity_list.dart';

class ClientHomeScreen extends ConsumerWidget {
  const ClientHomeScreen({super.key, required String clientId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final info = context.responsiveInfo(ref);
    final currentUser = ref.watch(currentUserProvider).value;

    if (currentUser == null) {
      return const Center(child: Text("Veuillez vous connecter."));
    }

    final isAdmin = currentUser.role == 'admin';
    final isOwner = currentUser.role == 'client';

    bool canEdit<T extends UnifiedModel>({
      required T entity,
      required AppUser currentUser,
    }) {
      String entityOwner;
      if (entity is Projet) {
        entityOwner = entity.ownerId;
      } else if (entity is Chantier) {
        entityOwner = entity.clientId;
      } else if (entity is Intervention) {
        entityOwner = entity.chantierId;
      } else {
        return false;
      }
      return currentUser.role == 'admin' ||
          (currentUser.role == 'client' && entityOwner == currentUser.uid);
    }

    bool canDelete(UnifiedModel entity) =>
        canEdit(entity: entity, currentUser: currentUser);

    Widget buildEntitySection<T extends UnifiedModel>({
      required String title,
      required AsyncValue<List<T>> items,
      required String boxName,
      required T Function() createEmpty,
      required T Function(Map<String, dynamic>) fromJson,
      required Future<void> Function(T, String) save,
      required Future<void> Function(String) delete,
      required Future<void> Function(T, String) update,
      List<T> Function(List<T>)? filter,
    }) {
      final filteredItems = items.whenData(
        (list) => filter != null ? filter(list) : list,
      );
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          EntityList<T>(
            items: filteredItems,
            boxName: boxName,
            infoOverride: info,
            currentRole: currentUser.role,
            currentUserId: currentUser.id,
            readOnly: false,
            onEdit: (entity) =>
                canEdit(entity: entity, currentUser: currentUser)
                ? showEntityFormDialog<T>(
                    context: context,
                    ref: ref,
                    role: currentUser.role,
                    createEmpty: createEmpty,
                    fromJson: fromJson,
                    onSubmit: (updated) async =>
                        await update(updated, entity.id),
                  )
                : null,
            onCreate: isOwner
                ? () => showEntityFormDialog<T>(
                    context: context,
                    ref: ref,
                    role: currentUser.role,
                    createEmpty: createEmpty,
                    fromJson: fromJson,
                    onSubmit: (entity) async => await save(entity, entity.id),
                  )
                : null,
            onDelete: (id) async {
              final entity = filteredItems.value!.firstWhere((e) => e.id == id);
              if (canDelete(entity)) await delete(id);
            },
            policy: MultiRolePolicy(),
          ),
          const SizedBox(height: 24),
        ],
      );
    }

    final projects = ref.watch(allProjectsFutureProvider);
    final chantiers = ref.watch(allChantiersFutureProvider);
    final interventions = ref.watch(allInterventionsFutureProvider);

    return ScreenWrapper(
      title: 'Espace Client',
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            buildEntitySection<Projet>(
              title: "Mes projets",
              items: projects,
              boxName: 'project',
              createEmpty: Projet.mock,
              fromJson: Projet.fromJson,
              save: (entity, id) => projetService.save(entity),
              delete: projetService.delete,
              update: (entity, id) => projetService.sync(entity),
              filter: (list) => list
                  .where((p) => isOwner ? p.ownerId == currentUser.uid : true)
                  .toList(),
            ),
            buildEntitySection<Chantier>(
              title: "Chantiers associés",
              items: chantiers,
              boxName: 'chantierBox',
              createEmpty: Chantier.mock,
              fromJson: Chantier.fromJson,
              save: (entity, id) => chantierService.save(entity),
              delete: chantierService.delete,
              update: (entity, id) => chantierService.sync(entity),
              filter: (list) => list
                  .where(
                    (c) =>
                        projects.value?.any(
                          (p) =>
                              p.id == c.chefDeProjetId &&
                              p.ownerId == currentUser.uid,
                        ) ??
                        false,
                  )
                  .toList(),
            ),
            buildEntitySection<Intervention>(
              title: "Interventions prévues",
              items: interventions,
              boxName: 'interventionBox',
              createEmpty: Intervention.mock,
              fromJson: Intervention.fromJson,
              save: (entity, id) => interventionService.save(entity),
              delete: interventionService.delete,
              update: (entity, id) => interventionService.sync(entity),
              filter: (list) => list
                  .where(
                    (i) =>
                        chantiers.value?.any(
                          (c) =>
                              projects.value?.any(
                                (p) =>
                                    p.id == c.chefDeProjetId &&
                                    p.ownerId == currentUser.uid,
                              ) ??
                              false,
                        ) ??
                        false,
                  )
                  .toList(),
            ),
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
