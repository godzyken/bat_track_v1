import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/local/providers/hive_provider.dart';
import '../../../../data/remote/providers/chantier_provider.dart';
import '../../../chantier/views/widgets/chantier_etape_time_line_interactive.dart';
import '../widgets/kanban_column.dart';

class KanbanPlanningScreen extends ConsumerWidget {
  final String chantierId;

  const KanbanPlanningScreen({super.key, required this.chantierId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statuts = ['À faire', 'En cours', 'Terminé'];

    final chantierAsync = ref.watch(
      chantierAdvancedNotifierProvider(chantierId),
    );
    final allEtapes = ref.watch(allEtapesStreamProvider);

    if (chantierAsync.value == null) {
      return const Scaffold(
        body: Center(child: Text("Chargement du chantier...")),
      );
    }

    // Étapes liées uniquement à ce chantier
    final etapesDuChantier =
        allEtapes.value!.where((e) => e.chantierId == chantierId).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Planning Chantier')),
      body: Column(
        children: [
          // === KANBAN ===
          Expanded(
            flex: 2,
            child: Row(
              children:
                  statuts
                      .map(
                        (s) => KanbanColumn(
                          statut: s,
                          etapes:
                              etapesDuChantier
                                  .where((e) => e.statut == s)
                                  .toList(),
                          onDrop: (updatedEtape) {
                            ref
                                .read(chantierEtapeServiceProvider)
                                .save(updatedEtape);
                          },
                        ),
                      )
                      .toList(),
            ),
          ),

          const Divider(),

          // === TIMELINE / INTERACTIVE ===
          Expanded(
            flex: 1,
            child: ChantiersEtapeKanbanInteractive(
              etapes: etapesDuChantier,
              onReorder: (reordered) {
                for (var i = 0; i < reordered.length; i++) {
                  final updated = reordered[i].copyWith(ordre: i);
                  ref.read(chantierEtapeServiceProvider).save(updated);
                }
              },
              onDelete: (id) {
                ref.read(chantierEtapeServiceProvider).delete(id);
              },
            ),
          ),
        ],
      ),
    );
  }
}
