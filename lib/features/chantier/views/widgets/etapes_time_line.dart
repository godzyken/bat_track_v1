import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/local/models/index_model_extention.dart';

class EtapesTimeline extends ConsumerWidget {
  final List<ChantierEtape> etapes;
  final void Function(ChantierEtape) onEdit;
  final void Function(ChantierEtape) onDelete;

  const EtapesTimeline({
    super.key,
    required this.etapes,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Stepper(
      physics: const NeverScrollableScrollPhysics(),
      steps:
          etapes.map((etape) {
            final index = etapes.indexOf(etape);
            return Step(
              isActive: true,
              state: etape.terminee ? StepState.complete : StepState.indexed,
              title: Text(etape.titre),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(etape.description),
                  if (etape.dateDebut != null)
                    Text(
                      'Début : ${etape.dateDebut!.toLocal().toString().split(' ')[0]}',
                    ),
                  if (etape.dateFin != null)
                    Text(
                      'Fin : ${etape.dateFin!.toLocal().toString().split(' ')[0]}',
                    ),
                  Text(etape.terminee ? '✅ Terminée' : '⏳ En cours'),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => onEdit(etape),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => onDelete(etape),
                      ),
                    ],
                  ),
                ],
              ),
              content: const SizedBox.shrink(), // on évite le bloc inutile
            );
          }).toList(),
      currentStep: 0,
      controlsBuilder:
          (_, _) => const SizedBox.shrink(), // pas de boutons natifs
    );
  }
}
