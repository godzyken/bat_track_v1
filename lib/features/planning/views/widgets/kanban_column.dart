import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/local/models/index_model_extention.dart';
import '../../../../data/local/providers/hive_provider.dart';

class KanbanColumn extends ConsumerWidget {
  final String statut;
  const KanbanColumn({super.key, required this.statut});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final etapes =
        ref.watch(allEtapesProvider).where((e) => e.statut == statut).toList();

    return Expanded(
      child: DragTarget<ChantierEtape>(
        onAcceptWithDetails: (etape) {
          final updated = etape.copyWith(statut: statut);
          ref.read(chantierEtapeServiceProvider).update(updated, etape.data.id);
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

extension on DragTargetDetails<ChantierEtape> {
  ChantierEtape copyWith({required String statut}) {
    return data.copyWith(statut: statut);
  }
}
