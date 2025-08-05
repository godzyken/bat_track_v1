import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:implicitly_animated_reorderable_list_2/implicitly_animated_reorderable_list_2.dart';
import 'package:implicitly_animated_reorderable_list_2/transitions.dart';

import '../../../../data/local/models/index_model_extention.dart';
import '../../../../data/local/providers/hive_provider.dart';

class ChantiersEtapeKanbanInteractive extends ConsumerWidget {
  final List<ChantierEtape> etapes;
  final void Function(List<ChantierEtape>) onReorder;
  final void Function(String id) onDelete;
  final void Function(ChantierEtape updated)? onUpdate;
  final bool Function(ChantierEtape)? canEditEtape;

  const ChantiersEtapeKanbanInteractive({
    super.key,
    required this.etapes,
    required this.onReorder,
    required this.onDelete,
    this.onUpdate,
    this.canEditEtape,
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

    return SizedBox.expand(
      child: Column(
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
                    final color = switch (entry.key) {
                      'À faire' => Colors.grey[100],
                      'En cours' => Colors.yellow[100],
                      'Terminée' => Colors.green[100],
                      _ => Colors.white,
                    };

                    return Expanded(
                      child: DragTarget<ChantierEtape>(
                        onAcceptWithDetails: (details) {
                          final updated = details.data.copyWith(
                            statut: entry.key,
                          );
                          onUpdate?.call(updated);
                        },
                        builder:
                            (context, _, _) => Container(
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              padding: const EdgeInsets.all(8),
                              color: color,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    entry.key,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
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
                                        onReorder(newItems);
                                      },
                                      itemBuilder: (
                                        context,
                                        itemAnimation,
                                        item,
                                        index,
                                      ) {
                                        final canEdit =
                                            canEditEtape?.call(item) ?? true;

                                        return Reorderable(
                                          key: ValueKey(item.id),
                                          builder:
                                              (
                                                context,
                                                dragAnim,
                                                inDrag,
                                              ) => LongPressDraggable<
                                                ChantierEtape
                                              >(
                                                data: item,
                                                feedback: Material(
                                                  elevation: 4,
                                                  child: Card(
                                                    color: Colors.white,
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                            8.0,
                                                          ),
                                                      child: Text(item.titre),
                                                    ),
                                                  ),
                                                ),
                                                child: SizeFadeTransition(
                                                  animation: itemAnimation,
                                                  child: Card(
                                                    margin:
                                                        const EdgeInsets.only(
                                                          bottom: 12,
                                                        ),
                                                    child: ListTile(
                                                      contentPadding:
                                                          const EdgeInsets.all(
                                                            12,
                                                          ),
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
                                                          if (canEdit)
                                                            IconButton(
                                                              icon: const Icon(
                                                                Icons.edit,
                                                              ),
                                                              onPressed: () {
                                                                final chantier =
                                                                    ref.read(
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
                                                                    'etape':
                                                                        item,
                                                                  },
                                                                );
                                                              },
                                                              tooltip: 'Éditer',
                                                            ),
                                                          if (canEdit)
                                                            IconButton(
                                                              icon: const Icon(
                                                                Icons.delete,
                                                                color:
                                                                    Colors.red,
                                                              ),
                                                              onPressed:
                                                                  () =>
                                                                      onDelete(
                                                                        item.id,
                                                                      ),
                                                              tooltip:
                                                                  'Supprimer',
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
                      ),
                    );
                  }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class ChantiersEtapeKanbanReadOnly extends ConsumerWidget {
  final List<ChantierEtape> etapes;

  const ChantiersEtapeKanbanReadOnly({super.key, required this.etapes});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final grouped = <String, List<ChantierEtape>>{
      'À faire': [],
      'En cours': [],
      'Terminée': [],
    };

    for (var e in etapes) {
      grouped[e.statut]?.add(e);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Suivi des étapes (lecture seule)',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 400, // hauteur fixe ou adaptative
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children:
                grouped.entries.map((entry) {
                  final color = switch (entry.key) {
                    'À faire' => Colors.grey[100],
                    'En cours' => Colors.yellow[100],
                    'Terminée' => Colors.green[100],
                    _ => Colors.white,
                  };

                  return Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      padding: const EdgeInsets.all(8),
                      color: color,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            entry.key,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Expanded(
                            child: ListView.builder(
                              itemCount: entry.value.length,
                              itemBuilder: (context, index) {
                                final item = entry.value[index];
                                return Card(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.all(12),
                                    title: Text(item.titre),
                                    subtitle: Text(item.description),
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
