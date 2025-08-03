import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/local/models/index_model_extention.dart';

class EtapeCard extends ConsumerWidget {
  final ChantierEtape etape;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const EtapeCard({
    super.key,
    required this.etape,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final color = etape.terminee ? Colors.green[100] : Colors.orange[100];

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      color: color,
      child: ListTile(
        leading: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.circle, size: 12, color: Colors.blue),
            Container(width: 2, height: 40, color: Colors.blue.shade200),
          ],
        ),
        title: Text(
          etape.titre,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(etape.description),
            const SizedBox(height: 4),
            if (etape.dateDebut != null)
              Text(
                '📅 Début : ${etape.dateDebut.toLocal().toString().split(' ')[0]}',
              ),
            if (etape.dateFin != null)
              Text(
                '🏁 Fin : ${etape.dateFin.toLocal().toString().split(' ')[0]}',
              ),
            Text(etape.terminee ? '✅ Terminée' : '⏳ En cours'),
          ],
        ),
        trailing: Wrap(
          spacing: 4,
          children: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: onEdit,
              tooltip: 'editer',
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: onDelete,
              tooltip: 'supprimer',
            ),
          ],
        ),
      ),
    );
  }
}
