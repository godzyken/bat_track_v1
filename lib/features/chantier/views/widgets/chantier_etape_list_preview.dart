import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../data/local/models/index_model_extention.dart';
import '../../../../data/local/providers/hive_provider.dart';
import '../../../../models/views/widgets/entity_etape_form.dart';

class ChantiersEtapeListPreview extends ConsumerWidget {
  final List<ChantierEtape>? etapes;
  final void Function(int index) onTap;
  final void Function(int index)? onDelete;

  const ChantiersEtapeListPreview({
    required this.etapes,
    required this.onTap,
    this.onDelete,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (etapes == null || etapes!.isEmpty) {
      return const Text("Aucune étape enregistrée.");
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Étapes du chantier',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 8),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: Column(
            key: ValueKey(etapes!.length),
            children: [
              ...etapes!.asMap().entries.map((entry) {
                final index = entry.key;
                final etape = entry.value;

                return Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor:
                          etape.terminee == true ? Colors.green : Colors.grey,
                      child: Text('${index + 1}'),
                    ),
                    title: Text(
                      etape.titre.isNotEmpty == true
                          ? etape.titre
                          : 'Étape ${index + 1}',
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(etape.description),
                        if (etape.dateDebut != null && etape.dateFin != null)
                          Text(
                            'Du ${etape.dateDebut!.toLocal().toString().split(' ').first} '
                            'au ${etape.dateFin!.toLocal().toString().split(' ').first}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.edit),
                        if (onDelete != null)
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => onDelete!(index),
                          ),
                      ],
                    ),
                    onTap: () {
                      final chantier = ref.read(
                        chantierProvider(etape.chantierId!),
                      );
                      context.goNamed(
                        'chantier-etape-detail',
                        pathParameters: {
                          'id': etape.chantierId!,
                          'etapeId': etape.id!,
                        },
                        extra: {'chantier': chantier, 'etape': etape},
                      );
                    },
                  ),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }
}

/// Champ personnalisé pour `Chantier.etapes`
Widget? chantierFieldBuilder(
  BuildContext context,
  String key,
  dynamic value,
  TextEditingController? controller,
  void Function(dynamic) onChanged,
  bool expertMode,
) {
  if (key != 'etapes') return null;

  final etapes =
      (value as List)
          .map((e) => e is ChantierEtape ? e : ChantierEtape.fromJson(e))
          .toList();

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        "Étapes du chantier",
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 8),
      ElevatedButton.icon(
        icon: const Icon(Icons.add),
        label: const Text("Ajouter une étape"),
        onPressed: () {
          showDialog(
            context: context,
            builder:
                (_) => EntityEtapeForm(
                  initialValue: null,
                  onSubmit: (etape) {
                    final updated = [...etapes, etape];
                    onChanged(updated.map((e) => e?.toJson()).toList());
                  },
                  fromJson: ChantierEtape.fromJson,
                  createEmpty: ChantierEtape.mock,
                ),
          );
        },
      ),
      const SizedBox(height: 8),
      ChantiersEtapeListPreview(
        etapes: etapes,
        onTap: (i) {
          final chantier = value;

          context.goNamed(
            'chantier-etape-detail',
            pathParameters: {
              'id': etapes[i].chantierId!,
              'etapeId': etapes[i].id!,
            },
            extra: {'chantier': chantier, 'etape': etapes[i]},
          );
        },
        onDelete: (i) {
          etapes.removeAt(i);
          onChanged(etapes.map((e) => e.toJson()).toList());
        },
      ),
    ],
  );
}
