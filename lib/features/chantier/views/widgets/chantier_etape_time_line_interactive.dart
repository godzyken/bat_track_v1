import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:implicitly_animated_reorderable_list_2/implicitly_animated_reorderable_list_2.dart';
import 'package:implicitly_animated_reorderable_list_2/transitions.dart';

import '../../../../data/local/models/index_model_extention.dart';
import '../../../../data/local/providers/hive_provider.dart';

class ChantiersEtapeTimelineInteractive extends ConsumerStatefulWidget {
  final List<ChantierEtape> etapes;
  final void Function(List<ChantierEtape> reordered)? onReorder;
  final void Function(int index)? onDelete;

  const ChantiersEtapeTimelineInteractive({
    required this.etapes,
    this.onReorder,
    this.onDelete,
    super.key,
  });

  @override
  ConsumerState<ChantiersEtapeTimelineInteractive> createState() =>
      _ChantiersEtapeTimelineInteractiveState();
}

class _ChantiersEtapeTimelineInteractiveState
    extends ConsumerState<ChantiersEtapeTimelineInteractive> {
  late List<ChantierEtape> _etapes;

  @override
  void initState() {
    super.initState();
    _etapes = List.from(widget.etapes);
  }

  @override
  Widget build(BuildContext context) {
    if (_etapes.isEmpty) {
      return const Text("Aucune étape enregistrée.");
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Planning interactif des étapes',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        const SizedBox(height: 16),
        ImplicitlyAnimatedReorderableList<ChantierEtape>(
          items: _etapes,
          areItemsTheSame: (a, b) => a.id == b.id,
          onReorderFinished: (item, from, to, newItems) {
            setState(() => _etapes = newItems);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Ordre des étapes mis à jour")),
            );
            widget.onReorder?.call(newItems);
          },
          itemBuilder: (context, itemAnimation, item, index) {
            final isDone = item.terminee == true;
            final dateDebut = item.dateDebut?.toLocal();
            final dateFin = item.dateFin?.toLocal();

            return Reorderable(
              key: ValueKey(item.id),
              builder: (context, dragAnimation, inDrag) {
                return SizeFadeTransition(
                  sizeFraction: 0.9,
                  curve: Curves.easeInOut,
                  animation: itemAnimation,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        children: [
                          Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _getStatusColor(item),
                            ),
                          ),
                          if (index != _etapes.length - 1)
                            Container(
                              width: 2,
                              height: 60,
                              color: Colors.grey.shade400,
                            ),
                        ],
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Card(
                          margin: const EdgeInsets.only(bottom: 20),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(12),
                            leading: const Icon(Icons.drag_handle),
                            title: Text(
                              item.titre.isNotEmpty
                                  ? item.titre
                                  : 'Étape ${index + 1}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (dateDebut != null && dateFin != null)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Icons.calendar_today,
                                          size: 14,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          '${_formatDate(dateDebut)} - ${_formatDate(dateFin)}',
                                          style: const TextStyle(fontSize: 12),
                                        ),
                                      ],
                                    ),
                                  ),
                                if (item.description.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: Text(
                                      item.description,
                                      style: const TextStyle(fontSize: 13),
                                    ),
                                  ),
                              ],
                            ),
                            trailing: Wrap(
                              spacing: 4,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () {
                                    final chantier = ref.read(
                                      chantierProvider(item.chantierId!),
                                    );
                                    context.goNamed(
                                      'chantier-etape-detail',
                                      pathParameters: {
                                        'id': item.chantierId!,
                                        'etapeId': item.id!,
                                      },
                                      extra: {
                                        'chantier': chantier,
                                        'etape': item,
                                      },
                                    );
                                  },
                                ),
                                if (widget.onDelete != null)
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    ),
                                    onPressed: () => widget.onDelete!(index),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}/"
        "${date.month.toString().padLeft(2, '0')}/"
        "${date.year}";
  }

  Color _getStatusColor(ChantierEtape e) {
    if (e.terminee == true) return Colors.green;
    if (e.dateDebut != null && e.dateDebut!.isBefore(DateTime.now())) {
      return Colors.orange;
    }
    return Colors.grey;
  }
}
