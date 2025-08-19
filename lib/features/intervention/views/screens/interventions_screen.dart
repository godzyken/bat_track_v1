import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../controllers/providers/intervention_stats_provider.dart';

class InterventionsScreen extends ConsumerWidget {
  final String chantierId;
  final String statut;

  const InterventionsScreen({
    super.key,
    required this.chantierId,
    required this.statut,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncIntervs = ref.watch(
      interventionsByStatutProvider({
        "chantierId": chantierId,
        "statut": statut,
      }),
    );

    return Scaffold(
      appBar: AppBar(title: Text("Interventions - $statut")),
      body: asyncIntervs.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text("Erreur: $e")),
        data: (list) {
          if (list.isEmpty) {
            return const Center(child: Text("Aucune intervention trouvée."));
          }
          return ListView.separated(
            itemCount: list.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (context, index) {
              final interv = list[index];
              return ListTile(
                leading: const Icon(Icons.build),
                title: Text(interv.titre!),
                subtitle: Text("Technicien: ${interv.technicienId}"),
                trailing: Text(interv.create.toString()),
                onTap: () {
                  context.push("/intervention/${interv.id}");
                },
              );
            },
          );
        },
      ),
    );
  }
}
