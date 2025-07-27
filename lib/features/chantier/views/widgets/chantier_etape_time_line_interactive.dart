import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:implicitly_animated_reorderable_list_2/implicitly_animated_reorderable_list_2.dart';
import 'package:implicitly_animated_reorderable_list_2/transitions.dart';

import '../../../../data/local/models/index_model_extention.dart';
import '../../../../data/local/providers/hive_provider.dart';

class ChantiersEtapeKanbanInteractive extends ConsumerWidget {
  final List<ChantierEtape> etapes;
  final void Function(List<ChantierEtape> reordered)? onReorder;
  final void Function(ChantierEtape updated)? onUpdate;
  final void Function(ChantierEtape deleted)? onDelete;

  const ChantiersEtapeKanbanInteractive({
    super.key,
    required this.etapes,
    this.onReorder,
    this.onUpdate,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final grouped = <String, List<ChantierEtape>>{
      'À faire': [],
      'En cours': [],
      'Terminée': [],
    };
    for (var e in etapes) {
      final statut = e.statut;
      grouped[statut]?.add(e);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Kanban interactif des étapes',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children:
                grouped.entries.map((entry) {
                  return Expanded(
                    child: DragTarget<ChantierEtape>(
                      onAcceptWithDetails: (etape) {
                        final updated = etape.copyWith(statut: entry.key);
                        onUpdate?.call(updated);
                      },
                      builder:
                          (context, _, _) => Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                entry.key,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Expanded(
                                child: ImplicitlyAnimatedReorderableList<
                                  ChantierEtape
                                >(
                                  items: entry.value,
                                  areItemsTheSame: (a, b) => a.id == b.id,
                                  onReorderFinished: (
                                    item,
                                    from,
                                    to,
                                    newItems,
                                  ) {
                                    onReorder?.call(etapes);
                                  },
                                  itemBuilder: (
                                    context,
                                    itemAnimation,
                                    item,
                                    index,
                                  ) {
                                    return Reorderable(
                                      key: ValueKey(item.id),
                                      builder:
                                          (
                                            context,
                                            dragAnim,
                                            inDrag,
                                          ) => LongPressDraggable(
                                            data: item,
                                            feedback: Material(
                                              child: Card(
                                                color: Colors.white,
                                                child: Padding(
                                                  padding: const EdgeInsets.all(
                                                    8.0,
                                                  ),
                                                  child: Text(item.titre),
                                                ),
                                              ),
                                            ),
                                            child: SizeFadeTransition(
                                              animation: itemAnimation,
                                              child: Card(
                                                margin: const EdgeInsets.only(
                                                  bottom: 12,
                                                ),
                                                child: ListTile(
                                                  contentPadding:
                                                      const EdgeInsets.all(12),
                                                  leading: const Icon(
                                                    Icons.drag_handle,
                                                  ),
                                                  title: Text(item.titre),
                                                  subtitle: Text(
                                                    item.description,
                                                  ),
                                                  trailing: Wrap(
                                                    spacing: 4,
                                                    children: [
                                                      IconButton(
                                                        icon: const Icon(
                                                          Icons.edit,
                                                        ),
                                                        onPressed: () {
                                                          final chantier = ref
                                                              .read(
                                                                chantierProvider(
                                                                  item.chantierId,
                                                                ),
                                                              );
                                                          context.goNamed(
                                                            'chantier-etape-detail',
                                                            pathParameters: {
                                                              'id':
                                                                  item.chantierId,
                                                              'etapeId':
                                                                  item.id,
                                                            },
                                                            extra: {
                                                              'chantier':
                                                                  chantier,
                                                              'etape': item,
                                                            },
                                                          );
                                                        },
                                                      ),
                                                      if (onDelete != null)
                                                        IconButton(
                                                          icon: const Icon(
                                                            Icons.delete,
                                                            color: Colors.red,
                                                          ),
                                                          onPressed:
                                                              () => onDelete!(
                                                                item,
                                                              ),
                                                        ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                    ),
                  );
                }).toList(),
          ),
        ),
      ],
    );
  }
}

extension on DragTargetDetails<ChantierEtape> {
  ChantierEtape copyWith({required String statut}) {
    return data.copyWith(statut: statut);
  }
}
