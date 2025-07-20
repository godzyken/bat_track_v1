import 'package:bat_track_v1/data/local/providers/hive_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import '../../../../data/local/models/index_model_extention.dart';
import '../../../../data/local/services/service_type.dart';

class ChantierNotifier extends StateNotifier<Chantier?> {
  final String id;
  final Box<Chantier> chantierBox;
  final Box<ChantierEtape> etapeBox;
  final Box<Piece> pieceBox;
  final Box<PieceJointe> pieceJointeBox;
  final Box<FactureDraft> factureDraftBox;
  final Box<Intervention> interventionBox;
  final EntityServices<FactureDraft> factureDraftService;
  final EntityServices<Chantier> chantierService;
  final EntityServices<ChantierEtape> etapeService;
  final EntityServices<Piece> pieceService;
  final EntityServices<PieceJointe> pieceJointeService;
  final EntityServices<Intervention> interventionService;

  ChantierNotifier({
    required this.id,
    required this.chantierBox,
    required this.etapeBox,
    required this.pieceBox,
    required this.pieceJointeBox,
    required this.factureDraftBox,
    required this.interventionBox,
    required this.chantierService,
    required this.etapeService,
    required this.pieceService,
    required this.pieceJointeService,
    required this.factureDraftService,
    required this.interventionService,
  }) : super(chantierBox.get(id));

  List<ChantierEtape> get etapes =>
      etapeBox.values.where((e) => e.chantierId == id).toList();

  List<Piece> get pieces => pieceBox.values.where((p) => p.id == id).toList();

  List<PieceJointe> get piecesJointes =>
      pieceJointeBox.values.where((p) => p.id == id).toList();

  /// Update Model
  Future<void> updateChantier(Chantier chantier) async {
    final isNew = !chantierBox.containsKey(chantier.id);

    await chantierBox.put(chantier.id, chantier);
    await chantierService.save(chantier, chantier.id);
    state = chantier;

    if (isNew) {
      await createFactureDraft();
    }
  }

  Future<void> updateEtape(ChantierEtape etape) async {
    await etapeBox.put(etape.id, etape);
    await etapeService.save(etape, etape.id!);
    await recalculateFactureDraft();
  }

  Future<void> updatePiece(Piece piece) async {
    await pieceBox.put(piece.id, piece);
    await pieceService.save(piece, piece.id!);
  }

  Future<void> updatePieceJointe(PieceJointe piece) async {
    await pieceJointeBox.put(piece.id, piece);
    await pieceJointeService.save(piece, piece.id);
  }

  /// Add Model
  Future<void> addEtape(ChantierEtape etape) async {
    await etapeBox.put(etape.id, etape);
    await etapeService.save(etape, etape.id!);
  }

  Future<void> addPiece(Piece piece) async {
    await pieceBox.put(piece.id, piece);
    await pieceService.save(piece, piece.id!);
  }

  Future<void> addPieceJointe(String s, PieceJointe piece) async {
    await pieceJointeBox.put(s, piece);
    await pieceJointeService.save(piece, piece.id);
  }

  /// Delete Model
  Future<void> deleteEtape(String etapeId) async {
    await etapeBox.delete(etapeId);
    await etapeService.delete(etapeId);
  }

  Future<void> deletePiece(String pieceId) async {
    await pieceBox.delete(pieceId);
    await pieceService.delete(pieceId);
  }

  Future<void> deletePieceJointe(String pieceId) async {
    await pieceJointeBox.delete(pieceId);
    await pieceJointeService.delete(pieceId);
  }

  void toggleTerminee(String etapeId) {
    final current = state;
    if (current == null) return;

    final updatedEtapes =
        current.etapes.map((e) {
          if (e.id == etapeId) {
            return e.copyWith(terminee: !e.terminee);
          }
          etapeBox.put(e.id, e);
          etapeService.save(e, e.id!);
          return e;
        }).toList();

    final updatedChantier = current.copyWith(etapes: updatedEtapes);
    state = updatedChantier;
  }

  Future<void> createFactureDraft() async {
    final chantier = chantierBox.get(id);
    if (chantier == null) return;

    final clientId = chantier.clientId;
    final lignes = <CustomLigneFacture>[];

    // Étapes (main d'œuvre)
    final etapesChantier = etapeBox.values.where((e) => e.chantierId == id);
    for (final e in etapesChantier) {
      // Récupère les pièces associées à cette étape
      final piecesEtape = pieceBox.values.where((p) => p.id == e.id);

      // Calcule le coût total des pièces de l’étape
      final montantPieces = piecesEtape.fold<double>(
        0,
        (total, p) => total + (p.getBudgetTotalSansMainOeuvre()),
      );

      lignes.add(
        CustomLigneFacture(
          description: 'Étape : ${e.description}',
          montant: montantPieces,
          quantite: 1,
          total: montantPieces,
        ),
      );
    }

    // Interventions (matériel/supplémentaires)
    final interventions = interventionBox.values.where(
      (i) => i.chantierId == id,
    );
    for (final i in interventions) {
      final montant = i.facture?.totalHT ?? 0;
      lignes.add(
        CustomLigneFacture(
          description: 'Intervention : ${i.description}',
          montant: montant,
          quantite: 1,
          total: montant,
        ),
      );
    }

    final facture = FactureDraft(
      factureId: clientId,
      chantierId: id,
      lignesManuelles: lignes,
      isFinalized: false,
      dateDerniereModification: DateTime.now(),
    );

    await factureDraftBox.put(facture.id, facture);
    await factureDraftService.save(facture, facture.id!);
  }

  Future<void> recalculateFactureDraft() async {
    final existing = factureDraftBox.get(id);
    if (existing != null && !existing.isFinalized) {
      await createFactureDraft(); // Écrase avec nouvelle version recalculée
    }
  }
}

final chantierAdvancedNotifierProvider = StateNotifierProvider.autoDispose
    .family<ChantierNotifier, Chantier?, String>((ref, id) {
      final chantierBox = ref.watch(chantierNotifierProvider(id).notifier).box;
      final etapeBox =
          ref.watch(chantierEtapeNotifierProvider(id).notifier).box;
      final pieceBox = ref.watch(pieceNotifierProvider(id).notifier).box;
      final pieceJointeBox =
          ref.watch(pieceJointeNotifierProvider(id).notifier).box;
      final factureDraftBox =
          ref.watch(factureDraftNotifierProvider(id).notifier).box;
      final interventionBox =
          ref.watch(interventionNotifierProvider(id).notifier).box;

      return ChantierNotifier(
        id: id,
        chantierBox: chantierBox,
        etapeBox: etapeBox,
        pieceBox: pieceBox,
        pieceJointeBox: pieceJointeBox,
        factureDraftBox: factureDraftBox,
        interventionBox: interventionBox,
        chantierService: chantierService,
        etapeService: chantierEtapeService,
        pieceService: pieceService,
        pieceJointeService: pieceJointeService,
        factureDraftService: factureDraftService,
        interventionService: interventionService,
      );
    });
