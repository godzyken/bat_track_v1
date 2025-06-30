import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:open_filex/open_filex.dart';
import 'package:timelines_plus/timelines_plus.dart';

import '../../../../data/local/models/index_model_extention.dart';
import '../../controllers/notifiers/chantier_notifier.dart';

class ChantierEtapeDetailScreen extends ConsumerWidget {
  final Chantier chantier;
  final ChantierEtape etape;

  const ChantierEtapeDetailScreen({
    super.key,
    required this.chantier,
    required this.etape,
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
        final ext = file.extension?.toLowerCase() ?? '';
        final type = ext == 'pdf' ? 'pdf' : 'image';

        final piece = PieceJointe(
          id: etape.id!,
          url: file.path!,
          nom: file.name,
          type: type,
        );

        await ref
            .read(chantierNotifierProvider.notifier)
            .addPieceJointe(etape.id!, piece);
      }
    } catch (e) {
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
    ref.read(chantierNotifierProvider.notifier).toggleTerminee(etapeId);
  }

  Widget _buildTimeline(
    BuildContext context,
    Chantier chantier,
    ChantierEtape etape,
  ) {
    final etapes = chantier.etapes;

    return Timeline.tileBuilder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      theme: TimelineThemeData(
        nodePosition: 0,
        indicatorTheme: const IndicatorThemeData(size: 20),
        connectorTheme: const ConnectorThemeData(thickness: 2.5),
      ),
      builder: TimelineTileBuilder.connected(
        itemCount: etapes.length,
        connectionDirection: ConnectionDirection.before,
        contentsBuilder:
            (_, index) => _buildTile(context, etapes[index], etape.id!),
        indicatorBuilder: (_, index) {
          final e = etapes[index];
          return DotIndicator(
            color: e.terminee ? Colors.green : Colors.grey,
            child:
                e.id == etape.id
                    ? const Icon(
                      Icons.arrow_forward,
                      size: 12,
                      color: Colors.white,
                    )
                    : null,
          );
        },
        connectorBuilder: (_, __, ___) => const SolidLineConnector(),
      ),
    );
  }

  Widget _buildTile(
    BuildContext context,
    ChantierEtape current,
    String selectedId,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        title: Text(current.titre),
        subtitle: Text(
          current.dateDebut != null
              ? 'Début : ${current.dateDebut!.toLocal().toString().split(' ').first}'
              : 'Pas de date',
        ),
        tileColor:
            current.id == selectedId
                ? Colors.blue.withAlpha((255 * 0.1).toInt())
                : Colors.transparent,
        trailing: Icon(
          current.terminee ? Icons.check_circle : Icons.timelapse,
          color: current.terminee ? Colors.green : Colors.orange,
        ),
        onTap: () {
          if (current.id != selectedId) {
            context.goNamed(
              'chantier-etape-detail',
              pathParameters: {
                'id': current.chantierId ?? '', // à ajuster si nécessaire
                'etapeId': current.id!,
              },
            );
          }
        },
      ),
    );
  }

  Widget _buildGallery(List<PieceJointe> pieces) {
    if (pieces.isEmpty) {
      return const Text('Aucune pièce jointe.');
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: pieces.map((piece) => _buildPieceWidget(piece)).toList(),
    );
  }

  Widget _buildPieceWidget(PieceJointe piece) {
    final file = File(piece.url);
    final isImage = piece.type == 'image';

    return GestureDetector(
      onTap: () => OpenFilex.open(piece.url),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          isImage
              ? ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(
                  file,
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                ),
              )
              : Container(
                width: 100,
                height: 100,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.picture_as_pdf,
                  size: 40,
                  color: Colors.red,
                ),
              ),
          const SizedBox(height: 4),
          SizedBox(
            width: 100,
            child: Text(
              piece.nom,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = chantier;
    final e = etape;

    return Scaffold(
      appBar: AppBar(
        title: Text(e.titre),
        actions: [
          IconButton(
            icon: Icon(
              e.terminee ? Icons.check_circle : Icons.radio_button_unchecked,
              color: e.terminee ? Colors.green : null,
            ),
            tooltip:
                e.terminee
                    ? 'Marquer comme non terminée'
                    : 'Marquer comme terminée',
            onPressed: () => _toggleTerminee(ref, e.id!),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (e.description.isNotEmpty) Text(e.description),
          const SizedBox(height: 24),
          Text(
            'Timeline du chantier',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          _buildTimeline(context, c, e),
          const Divider(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Pièces jointes',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              IconButton(
                icon: const Icon(Icons.attach_file),
                tooltip: 'Ajouter une pièce jointe',
                onPressed: () => _addPieceJointe(ref, context, e),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildGallery(e.piecesJointes ?? []),
        ],
      ),
    );
  }
}
