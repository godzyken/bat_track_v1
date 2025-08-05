import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/local/models/index_model_extention.dart';
import '../../../../data/local/providers/hive_provider.dart';

class KanbanColumn extends ConsumerWidget {
  final String statut;
  final List<ChantierEtape> etapes;
  final void Function(ChantierEtape etape) onDrop;

  const KanbanColumn({
    super.key,
    required this.statut,
    required this.etapes,
    required this.onDrop,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Expanded(
      child: DragTarget<ChantierEtape>(
        onAcceptWithDetails: (details) {
          final updated = details.data.copyWith(statut: statut);
          ref
              .read(chantierEtapeServiceProvider)
              .update(updated, details.data.id);
          onDrop(updated); // Optionnel : notifie le parent
        },
        builder:
            (context, _, _) => Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  color: Colors.grey[200],
                  child: Text(
                    statut,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 8),
                ...etapes.map(
                  (e) => LongPressDraggable<ChantierEtape>(
                    data: e,
                    feedback: Material(
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(e.displayTitle),
                        ),
                      ),
                    ),
                    child: Card(
                      child: ListTile(title: Text(e.displaySubtitle)),
                    ),
                  ),
                ),
              ],
            ),
      ),
    );
  }
}
