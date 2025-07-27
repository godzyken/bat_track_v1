import 'package:bat_track_v1/features/technicien/controllers/notifiers/technicien_list_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/local/models/index_model_extention.dart';

class PieceCard extends ConsumerWidget {
  final Piece piece;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const PieceCard({
    super.key,
    required this.piece,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final techniciens = ref.watch(techniciensListProvider);

    final budget = techniciens.maybeWhen(
      data: (t) => piece.getBudgetTotal(t).toStringAsFixed(2),
      orElse: () => '...',
    );

    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 3,
        margin: const EdgeInsets.all(8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    piece.nom,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: onEdit,
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: onDelete,
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text('Surface : ${piece.surface.toStringAsFixed(1)} m²'),
              const SizedBox(height: 8),

              // Budget
              Row(
                children: [
                  const Icon(Icons.attach_money, size: 20),
                  const SizedBox(width: 4),
                  Text(
                    'Budget total : $budget €',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),

              const SizedBox(height: 12),
              // Matériaux
              _buildSectionTitle(context, 'Matériaux'),
              ...piece.materiaux!.map(
                (m) => _buildBullet(
                  Icon(Icons.paid_outlined),
                  '${m.nom} - ${m.prixUnitaire} €/ ${m.unite}'
                  '${m.coefficientSurface != null ? ', coef: ${m.coefficientSurface}' : ''}'
                  '${m.quantiteFixe != null ? ', fixe: ${m.quantiteFixe}' : ''}',
                ),
              ),

              const SizedBox(height: 8),
              // Matériels
              _buildSectionTitle(context, 'Matériels'),
              ...piece.materiels!.map(
                (m) => _buildBullet(
                  Icon(Icons.paid_sharp),
                  '${m.nom} - ${m.prixUnitaire} € x ${m.quantiteFixe}'
                  '${m.joursLocation != null ? ', ${m.joursLocation}j loc. à ${m.prixLocation} €' : ''}',
                ),
              ),

              const SizedBox(height: 8),
              // Main d'œuvre
              _buildSectionTitle(context, 'Main-d’œuvre'),
              techniciens.maybeWhen(
                data: (list) {
                  final moList = piece.mainOeuvre ?? [];

                  final mainOeuvreWidgets =
                      moList.map((e) {
                        final tech = list.firstWhere(
                          (t) => t.id == e.idTechnicien,
                          orElse: () => Technicien.mock(),
                        );
                        return _buildBullet(
                          Icon(Icons.engineering),
                          '${tech.nom} - ${e.heuresEstimees} h',
                        );
                      }).toList();

                  return Column(children: mainOeuvreWidgets);
                },
                orElse: () => const Text('Chargement...'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.bold,
          color: Colors.grey[700],
        ),
      ),
    );
  }

  Widget _buildBullet(Icon icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          const Text('• ', style: TextStyle(fontSize: 16)),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
