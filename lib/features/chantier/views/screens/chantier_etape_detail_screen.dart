import 'dart:io';

import 'package:bat_track_v1/features/documents/controllers/generator/calculator.dart';
import 'package:file_picker/file_picker.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:open_filex/open_filex.dart';

import '../../../../core/responsive/wrapper/responsive_card_layout.dart';
import '../../../../core/responsive/wrapper/responsive_layout.dart';
import '../../../../data/local/models/index_model_extention.dart';
import '../../../../data/local/providers/hive_provider.dart';
import '../../controllers/notifiers/chantier_notifier.dart';
import '../widgets/etape_time_line.dart';

class ChantierEtapeDetailScreen extends ConsumerWidget {
  final String chantierId;
  final String etapeId;

  const ChantierEtapeDetailScreen({
    super.key,
    required this.chantierId,
    required this.etapeId,
  });

  Future<void> _addPieceJointe(
    WidgetRef ref,
    BuildContext context,
    ChantierEtape etape,
  ) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: false,
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        final type =
            (file.extension?.toLowerCase() ?? '') == 'pdf' ? 'pdf' : 'image';

        final piece = PieceJointe(
          id: etape.id!,
          url: file.path!,
          nom: file.name,
          type: type,
          taille: file.size,
        );

        await ref
            .read(chantierAdvancedNotifierProvider(chantierId).notifier)
            .addPieceJointe(etape.id!, piece);
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erreur lors de l’ajout de la pièce jointe'),
          ),
        );
      }
    }
  }

  void _toggleTerminee(WidgetRef ref, String etapeId) {
    ref
        .read(chantierAdvancedNotifierProvider(chantierId).notifier)
        .toggleTerminee(etapeId);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chantier = ref.watch(chantierProvider(chantierId));
    final etape = chantier?.etapes.firstWhere(
      (e) => e.id == etapeId,
      orElse: () => throw Exception('Étape introuvable'),
    );

    if (chantier == null || etape == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Erreur')),
        body: const Center(child: Text('Chantier ou étape introuvable')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(etape.titre),
        actions: [
          IconButton(
            tooltip:
                etape.terminee
                    ? 'Marquer comme non terminée'
                    : 'Marquer comme terminée',
            icon: Icon(
              etape.terminee
                  ? Icons.check_circle
                  : Icons.radio_button_unchecked,
              color: etape.terminee ? Colors.green : null,
            ),
            onPressed: () => _toggleTerminee(ref, etape.id!),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ResponsiveCardLayout(
          children: [
            _buildDescriptionCard(context, etape),
            _buildTimelineCard(context, chantier, etape),
            _buildPiecesJointesCard(context, ref, etape),
            _buildBudgetPartielCard(context, etape),
          ],
        ),
      ),
    );
  }

  Widget _buildDescriptionCard(BuildContext context, ChantierEtape etape) {
    return ResponsiveCard(
      title: 'Description',
      child: Text(
        etape.description.isNotEmpty
            ? etape.description
            : 'Aucune description fournie.',
        style: Theme.of(context).textTheme.bodyMedium,
      ),
    );
  }

  Widget _buildTimelineCard(
    BuildContext context,
    Chantier chantier,
    ChantierEtape etape,
  ) {
    return ResponsiveCard(
      title: 'Timeline du chantier',
      child: EtapeTimeline(
        chantier: chantier,
        etape: etape,
        onTap: (selected) {
          if (selected.id != etape.id) {
            context.goNamed(
              'chantier-etape-detail',
              pathParameters: {
                'id': selected.chantierId ?? '',
                'etapeId': selected.id!,
              },
            );
          }
        },
      ),
    );
  }

  Widget _buildPiecesJointesCard(
    BuildContext context,
    WidgetRef ref,
    ChantierEtape etape,
  ) {
    final pieces = etape.piecesJointes ?? [];
    final info = context.responsiveInfo(ref);

    return ResponsiveCard(
      title: 'Pièces jointes',
      action: IconButton(
        icon: const Icon(Icons.attach_file),
        tooltip: 'Ajouter une pièce jointe',
        onPressed: () => _addPieceJointe(ref, context, etape),
      ),
      child:
          pieces.isEmpty
              ? const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text('Aucune pièce jointe.'),
              )
              : LayoutBuilder(
                builder: (context, constraints) {
                  final crossAxisCount =
                      info.isDesktop
                          ? 4
                          : info.isTablet && info.isLandscape
                          ? 3
                          : 2;

                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: pieces.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.9,
                    ),
                    itemBuilder: (_, i) => _buildPieceWidget(pieces[i], info),
                  );
                },
              ),
    );
  }

  Widget _buildBudgetPartielCard(BuildContext context, ChantierEtape etape) {
    final pieces = etape.pieces ?? [];
    double totalMat = 0;
    double totalMateriel = 0;

    for (final p in pieces) {
      final mat = BudgetGen.calculerCoutMateriaux(
        p.materiaux,
        surface: p.surfaceM2,
      );
      final materiel = BudgetGen.calculerCoutMateriels(p.materiels);
      totalMat += mat;
      totalMateriel += materiel;
    }

    final total = totalMat + totalMateriel;

    return ResponsiveCard(
      title: 'Budget estimé',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (pieces.isEmpty) const Text('Aucune pièce ajoutée à cette étape.'),
          if (pieces.isNotEmpty) ...[
            ...pieces.map((p) {
              final partiel = p.getBudgetTotalSansMainOeuvre() ?? 0;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: Text(p.nom ?? 'Pièce')),
                    Text(
                      '${partiel.toStringAsFixed(2)} €',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              );
            }),
            const Divider(),
            Text(
              'Détail des coûts :',
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildCostBreakdownLine('Matériaux', totalMat, Colors.blue),
            _buildCostBreakdownLine('Matériel', totalMateriel, Colors.orange),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: [
                    PieChartSectionData(
                      value: totalMat,
                      color: Colors.blue,
                      title: 'Matériaux\n${totalMat.toStringAsFixed(0)}€',
                      radius: 60,
                      titleStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    PieChartSectionData(
                      value: totalMateriel,
                      color: Colors.orange,
                      title: 'Matériel\n${totalMateriel.toStringAsFixed(0)}€',
                      radius: 60,
                      titleStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                  sectionsSpace: 2,
                  centerSpaceRadius: 40,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                'Total : ${total.toStringAsFixed(2)} €',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.green[700],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCostBreakdownLine(String label, double amount, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(label)),
          Text('${amount.toStringAsFixed(2)} €'),
        ],
      ),
    );
  }

  Widget _buildPieceWidget(PieceJointe piece, ResponsiveInfo info) {
    final isImage = piece.type == 'image';

    final size = info.isMobile ? 100.0 : 120.0;

    return GestureDetector(
      onTap: () => OpenFilex.open(piece.url),
      child: ResponsiveCard(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            isImage
                ? _buildClipRRect(piece, size)
                : Container(
                  width: size,
                  height: size,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.picture_as_pdf,
                    size: 48,
                    color: Colors.red,
                  ),
                ),
            const SizedBox(height: 6),
            SizedBox(
              width: size,
              child: Text(
                piece.nom,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }

  ClipRRect _buildClipRRect(PieceJointe piece, double size) {
    final isWeb = kIsWeb;
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child:
          isWeb
              ? Image.network(
                piece.url,
                width: size,
                height: size,
                fit: BoxFit.contain,
              )
              : Image.file(
                File(piece.url),
                width: size,
                height: size,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => _buildErrorImage(size),
              ),
    );
  }

  Widget _buildErrorImage(double size) {
    return Container(
      width: size,
      height: size,
      color: Colors.grey[300],
      child: const Icon(Icons.broken_image, size: 40),
    );
  }
}
