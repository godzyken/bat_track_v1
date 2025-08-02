import 'package:bat_track_v1/core/responsive/wrapper/responsive_layout.dart';
import 'package:bat_track_v1/models/providers/asynchrones/entity_list_future_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/local/models/index_model_extention.dart';
import '../../../../models/views/screens/screen_wrapper.dart';
import '../../../../models/views/widgets/entity_list.dart';
import '../../../auth/data/providers/current_user_provider.dart';

class ClientHomeScreen extends ConsumerWidget {
  const ClientHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final info = context.responsiveInfo(ref);
    final currentUser = ref.watch(currentUserProvider);

    if (currentUser == null || currentUser.role.name != 'client') {
      return const Center(child: Text("Accès réservé aux clients."));
    }

    final userId = currentUser.id;

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
              boxName: 'projectBox',
              infoOverride: info,
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
