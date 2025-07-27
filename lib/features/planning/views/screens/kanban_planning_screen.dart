import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../chantier/views/widgets/chantier_etape_time_line_interactive.dart';
import '../widgets/kanban_column.dart';

class KanbanPlanningScreen extends ConsumerWidget {
  const KanbanPlanningScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statuts = ['À faire', 'En cours', 'Terminé'];

    return Scaffold(
      appBar: AppBar(title: const Text('Planning Chantier')),
      body: Column(
        children: [
          Expanded(
            flex: 2,
            child: Row(
              children: statuts.map((s) => KanbanColumn(statut: s)).toList(),
            ),
          ),
          const Divider(),
          Expanded(flex: 1, child: ChantiersEtapeKanbanInteractive(etapes: [])),
        ],
      ),
    );
  }
}
