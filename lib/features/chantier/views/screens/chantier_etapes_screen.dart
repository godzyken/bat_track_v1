import 'package:bat_track_v1/core/responsive/wrapper/responsive_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/responsive/wrapper/responsive_card_layout.dart';
import '../../../../data/local/models/index_model_extention.dart';
import '../../../../data/remote/providers/chantier_provider.dart';
import '../../../../models/views/widgets/entity_form.dart';
import '../widgets/etape_card.dart';
import '../widgets/piece_card.dart';

class ChantierEtapesScreen extends ConsumerWidget {
  final String chantierId;
  const ChantierEtapesScreen({super.key, required this.chantierId});

  void _openEtapeForm(
    BuildContext context,
    WidgetRef ref, {
    ChantierEtape? etape,
  }) {
    showDialog(
      context: context,
      builder:
          (_) => EntityForm(
            chantierId: chantierId,
            initialValue: etape,
            createEmpty: () => ChantierEtape.mock(),
            fromJson: (json) => ChantierEtape.fromJson(json),
            onSubmit: (updated) {
              final notifier = ref.read(
                chantierAdvancedNotifierProvider(chantierId).notifier,
              );
              etape == null
                  ? notifier.addEtape(updated)
                  : notifier.updateEtape(updated);
            },
          ),
    );
  }

  void _openPieceForm(BuildContext context, WidgetRef ref, {Piece? piece}) {
    showDialog(
      context: context,
      builder:
          (_) => EntityForm<Piece>(
            chantierId: chantierId,
            initialValue: piece,
            createEmpty: () => Piece.mock(),
            fromJson: (json) => Piece.fromJson(json),
            onSubmit: (updated) {
              final notifier = ref.read(
                chantierAdvancedNotifierProvider(chantierId).notifier,
              );
              piece == null
                  ? notifier.addPiece(updated)
                  : notifier.updatePiece(updated);
            },
          ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chantier = ref.watch(chantierAdvancedNotifierProvider(chantierId));
    final info = context.responsiveInfo(ref);

    if (chantier.value == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final models = chantier.value?.etapes;
    final pieces = chantier.value?.etapes.expand((e) => e.pieces).toList();

    return Scaffold(
      appBar: AppBar(title: const Text("Étapes & Pièces")),
      body: ResponsiveCardLayout(
        children: [
          const Padding(
            padding: EdgeInsets.all(12),
            child: Text(
              "📋 Étapes",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          if (models!.isEmpty)
            const Center(child: Text("Aucune étape pour l'instant"))
          else if (info.isTablet || info.isDesktop)
            Column(
              children:
                  models
                      .map(
                        (etape) => EtapeCard(
                          etape: etape,
                          onEdit:
                              () => _openEtapeForm(context, ref, etape: etape),
                          onDelete:
                              () => ref
                                  .read(
                                    chantierAdvancedNotifierProvider(
                                      chantierId,
                                    ).notifier,
                                  )
                                  .deleteEtape(etape.id),
                        ),
                      )
                      .toList(),
            )
          else
            ...models.map(
              (etape) => EtapeCard(
                etape: etape,
                onEdit: () => _openEtapeForm(context, ref, etape: etape),
                onDelete:
                    () => ref
                        .read(
                          chantierAdvancedNotifierProvider(chantierId).notifier,
                        )
                        .deleteEtape(etape.id),
              ),
            ),

          const Padding(
            padding: EdgeInsets.all(12),
            child: Text(
              "🧱 Pièces",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          if (pieces!.isEmpty)
            const Center(child: Text("Aucune pièce définie"))
          else
            GridView.count(
              crossAxisCount: info.isTablet ? 2 : 1,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 1.3,
              children:
                  pieces.map((piece) {
                    return Stack(
                      children: [
                        PieceCard(piece: piece),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed:
                                    () => _openPieceForm(
                                      context,
                                      ref,
                                      piece: piece,
                                    ),
                                tooltip: 'editer',
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed:
                                    () => ref
                                        .read(
                                          chantierAdvancedNotifierProvider(
                                            chantierId,
                                          ).notifier,
                                        )
                                        .deletePiece(piece.id),
                                tooltip: 'supprimer',
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  }).toList(),
            ),

          const SizedBox(height: 20),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton.extended(
            heroTag: "addEtape",
            onPressed: () => _openEtapeForm(context, ref),
            icon: const Icon(Icons.playlist_add),
            label: const Text("Ajouter une étape"),
          ),
          const SizedBox(height: 10),
          FloatingActionButton.extended(
            heroTag: "addPiece",
            onPressed: () => _openPieceForm(context, ref),
            icon: const Icon(Icons.add_home_work),
            label: const Text("Ajouter une pièce"),
          ),
        ],
      ),
    );
  }
}
