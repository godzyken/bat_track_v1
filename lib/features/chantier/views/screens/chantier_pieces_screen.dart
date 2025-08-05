import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/local/models/index_model_extention.dart';
import '../../../../data/local/providers/hive_provider.dart';
import '../../../../models/views/widgets/entity_form.dart';
import '../../../../models/views/widgets/entity_list.dart';
import '../../../auth/data/providers/auth_state_provider.dart';

class ChantierPiecesScreen extends ConsumerWidget {
  final String chantierId;
  const ChantierPiecesScreen({super.key, required this.chantierId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(appUserProvider).value;
    final isClient = user?.role == 'client';
    final isTech = user?.role == 'tech';
    final pieceService = ref.watch(pieceServiceProvider);
    final piecesAsync = ref.watch(watchPiecesByChantierProvider(chantierId));

    return Scaffold(
      appBar: AppBar(title: const Text("Pièces du chantier")),
      floatingActionButton:
          isClient
              ? FloatingActionButton(
                onPressed:
                    () => showPieceFormDialog(
                      context: context,
                      ref: ref,
                      onSubmit: (updated) async {
                        final validated =
                            isTech
                                ? updated.copyWith(validatedByTech: true)
                                : updated;
                        return pieceService.update(validated, updated.id);
                      },
                      role: user!.role,
                    ),
                child: const Icon(Icons.add),
              )
              : null,
      body: EntityList<Piece>(
        items: piecesAsync,
        boxName: 'pieces',
        onEdit: (piece) {
          showEditPieceDialogForUser(
            context: context,
            ref: ref,
            initialPiece: piece,
            chantierId: chantierId,
            currentUserId: user!.id,
            role: user.role,
            onSubmit: (updated) async {
              if (piece.id != null) {
                pieceService.update(updated, piece.id);
              } else {
                pieceService.save(updated, piece.id);
              }
            },
          );
        },
        onDelete: isClient ? (id) => pieceService.delete(id) : null,
        readOnly: user?.role != 'client',
      ),
    );
  }

  void showPieceFormDialog({
    required BuildContext context,
    required WidgetRef ref,
    required void Function(Piece) onSubmit,
    Piece? initialPiece,
    required String role,
  }) {
    showDialog(
      context: context,
      builder:
          (context) => EntityForm<Piece>(
            initialValue: initialPiece,
            createEmpty: Piece.mock,
            fromJson: Piece.fromJson,
            onSubmit: onSubmit,
            customFieldBuilder: (
              ctx,
              key,
              value,
              controller,
              onChanged,
              expert,
            ) {
              // 🔒 Le technicien ne peut modifier QUE les dimensions
              if (role == 'technicien') {
                final isDimension = [
                  'longueur',
                  'largeur',
                  'hauteur',
                ].contains(key);
                if (!isDimension) {
                  return TextFormField(
                    controller: controller,
                    enabled: false,
                    decoration: InputDecoration(
                      labelText: key,
                      disabledBorder: const OutlineInputBorder(),
                    ),
                  );
                }
              }

              // Par défaut, utiliser le builder standard
              return null;
            },
            fieldVisibility: (key, value) {
              if (role == 'technicien') {
                // On peut aussi cacher des champs non pertinents pour les techniciens
                if (key == 'createdBy' || key == 'lastModified') return false;
              }
              return true; // sinon, tout est visible
            },
          ),
    );
  }

  void showEditPieceDialogForUser({
    required BuildContext context,
    required WidgetRef ref,
    required Piece? initialPiece,
    required String chantierId,
    required String currentUserId,
    required String role,
    required void Function(Piece updated) onSubmit,
  }) {
    showDialog(
      context: context,
      builder:
          (context) => EntityForm<Piece>(
            chantierId:
                initialPiece == null ? "Nouvelle pièce" : "Modifier la pièce",
            initialValue: initialPiece,
            createEmpty: () => Piece.mock(),
            fromJson: Piece.fromJson,
            onSubmit: onSubmit,
            customFieldBuilder: (
              ctx,
              key,
              value,
              controller,
              onChanged,
              expert,
            ) {
              // 🔒 Le technicien ne peut modifier QUE les dimensions
              if (role == 'tech') {
                final isDimension = [
                  'longueur',
                  'largeur',
                  'hauteur',
                ].contains(key);
                if (!isDimension) {
                  return TextFormField(
                    controller: controller,
                    enabled: false,
                    decoration: InputDecoration(
                      labelText: key,
                      disabledBorder: const OutlineInputBorder(),
                    ),
                  );
                }
              }
              return null; // fallback to default
            },
            fieldVisibility: (key, _) {
              // Exemples supplémentaires
              if (role == 'tech' && key == 'addedBy') return false;
              return true;
            },
          ),
    );
  }
}
