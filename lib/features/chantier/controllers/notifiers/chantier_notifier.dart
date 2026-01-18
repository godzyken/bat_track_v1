import 'dart:typed_data' show Uint8List;

import 'package:bat_track_v1/core/providers/entity_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/services/unified_entity_service.dart';
import '../../../../data/local/models/entities/index_entity_extention.dart';
import '../../../../data/local/models/index_model_extention.dart';
import '../../../../data/remote/providers/chantier_provider.dart';

// J'utilise le nom de classe 'ChantierNotifier' qui était implicitement votre intention.
class ChantierNotifier
    extends AutoDisposeFamilyAsyncNotifier<Chantier?, String> {
  final _uuid = const Uuid();

  // Champs internes
  late String _id;
  late UnifiedEntityService<Chantier, ChantierEntity> _chantierService;
  late UnifiedEntityService<ChantierEtape, ChantierEtapesEntity> _etapeService;
  late UnifiedEntityService<Piece, PieceEntity> _pieceService;
  late UnifiedEntityService<PieceJointe, PieceJointeEntity> _pieceJointeService;
  late UnifiedEntityService<FactureDraft, FactureDraftEntity>
  _factureDraftService;
  late UnifiedEntityService<Intervention, InterventionEntity>
  _interventionService;

  @override
  Future<Chantier?> build(String id) async {
    _id = id;

    _chantierService = ref.read(chantierServiceProvider);
    _etapeService = ref.read(chantierEtapeServiceProvider);
    _pieceService = ref.read(pieceServiceProvider);
    _pieceJointeService = ref.read(pieceJointeServiceProvider);
    _factureDraftService = ref.read(factureDraftServiceProvider);
    _interventionService = ref.read(interventionServiceProvider);

    ref.listen(watchChantierProvider(id), (_, next) {
      state = next;
    });

    return _chantierService.get(id);
  }

  Future<void> _updateChantierLastModified() async {
    final currentChantier = state.value;
    if (currentChantier == null) return;

    // Mise à jour de la date sans autre modification
    final updatedChantier = currentChantier.copyWith(updatedAt: DateTime.now());
    await _chantierService.save(updatedChantier);
  }

  // Ajout d'une nouvelle Étape
  Future<void> addEtape(ChantierEtape etape) async {
    final newEtape = etape.copyWith(
      id: _uuid.v4(),
      chantierId: _id,
      updatedAt: DateTime.now(),
    );

    await _etapeService.save(newEtape);
    await recalculateFactureDraft();
    await _updateChantierLastModified();
  }

  // Ajout d'une nouvelle Pièce
  Future<void> addPiece(Piece piece) async {
    final newPiece = piece.copyWith(
      id: _uuid.v4(),
      addedBy: _id,
      updatedAt: DateTime.now(),
    );

    await _pieceService.save(newPiece);
    await recalculateFactureDraft();
    await _updateChantierLastModified();
  }

  // Ajout d'une nouvelle Pièce Jointe
  Future<void> addPieceJointe(PieceJointe piece) async {
    final newPiece = piece.copyWith(
      id: _uuid.v4(),
      parentId: _id,
      updatedAt: DateTime.now(),
    );

    await _pieceJointeService.save(newPiece);
    await _updateChantierLastModified();
  }

  // Ajout d'une nouvelle Intervention
  Future<void> addIntervention(Intervention intervention) async {
    final newIntervention = intervention.copyWith(
      id: _uuid.v4(),
      chantierId: _id,
      updatedAt: DateTime.now(),
    );

    await _interventionService.save(newIntervention);
    await recalculateFactureDraft();
    await _updateChantierLastModified();
  }

  /// Met à jour le Chantier. Utilise la méthode save() complète du service unifié.
  Future<void> updateChantier(Chantier chantier) async {
    final isNew = chantier.id.isEmpty;

    // Le service unifié gère la persistance (local/remote/sync).
    await _chantierService.save(chantier.copyWith(updatedAt: DateTime.now()));

    // Logique métier
    if (isNew) {
      await createFactureDraft();
    }
  }

  /// Met à jour une Étape.
  Future<void> updateEtape(ChantierEtape etape) async {
    await _etapeService.save(etape);
    await recalculateFactureDraft();
    await _updateChantierLastModified();
  }

  /// Met à jour une Pièce.
  Future<void> updatePiece(Piece piece) async {
    await _pieceService.save(piece);
    await recalculateFactureDraft();
    await _updateChantierLastModified();
  }

  /// Met à jour une Pièce Jointe.
  Future<void> updatePieceJointe(PieceJointe piece) async {
    await _pieceJointeService.save(piece);
    await _updateChantierLastModified();
  }

  /// Suppression d'une Étape.
  Future<void> deleteEtape(String etapeId) async {
    await _etapeService.delete(etapeId);
    await recalculateFactureDraft();
    await _updateChantierLastModified();
  }

  /// Suppression d'une Pièce.
  Future<void> deletePiece(String pieceId) async {
    await _pieceService.delete(pieceId);
    await recalculateFactureDraft();
    await _updateChantierLastModified();
  }

  /// Suppression d'une Pièce Jointe.
  Future<void> deletePieceJointe(String pieceId) async {
    await _pieceJointeService.delete(pieceId);
    await _updateChantierLastModified();
  }

  void toggleTerminee(String etapeId) {
    _etapeService.get(etapeId).then((e) async {
      if (e == null) return;
      final updated = e.copyWith(
        terminee: !e.terminee,
        updatedAt: DateTime.now(),
      );
      await updateEtape(updated);
    });
  }

  // ------------------------------------------------------------------
  // LOGIQUE MÉTIER COMPLEXE (FACTURE)
  // ------------------------------------------------------------------

  Future<void> createFactureDraft() async {
    final chantier = state.value;
    if (chantier == null) return;

    final clientId = chantier.clientId;
    final lignes = <CustomLigneFacture>[];

    // Lecture des dépendances (Étapes, Pièces, Interventions)
    // Nous utilisons getAllLocal() pour la rapidité et car le service sync les garde à jour.
    final allEtapes = await _etapeService.getAllLocal();
    final allPieces = await _pieceService.getAllLocal();
    final allInterventions = await _interventionService.getAllLocal();

    // Étapes (main d'œuvre)
    final etapesChantier = allEtapes.where((e) => e.chantierId == _id);
    for (final e in etapesChantier) {
      final piecesEtape = allPieces.where(
        (p) => p.id == e.id,
      ); // Nouvelle hypothèse de filtre: p.etapeId

      final montantPieces = piecesEtape.fold<double>(
        0,
        (total, p) =>
            total + (p.getBudgetTotalSansMainOeuvre()), // Méthode du modèle
      );

      lignes.add(
        CustomLigneFacture(
          ctlId: const Uuid().v4(), // Nouvel ID unique pour la ligne
          description: 'Étape: ${e.description}',
          montant: montantPieces,
          quantite: 1, // L'étape est une unité de travail
          total: montantPieces,
          ctlUpdatedAt: DateTime.now(),
        ),
      );
    }

    // Interventions (matériel/supplémentaires)
    final interventions = allInterventions.where((i) => i.chantierId == _id);
    for (final i in interventions) {
      final montant =
          i.facture?.totalHT ??
          0; // Hypothèse: Intervention a un champ 'facture'
      lignes.add(
        CustomLigneFacture(
          ctlId: const Uuid().v4(),
          description: 'Intervention: ${i.description}',
          montant: montant,
          quantite: 1,
          total: montant,
          ctlUpdatedAt: i.updatedAt,
        ),
      );
    }

    final facture = FactureDraft(
      factureId: _id, // L'ID de la facture
      chantierId: chantier.id,
      clientId: clientId,
      lignesManuelles: lignes,
      signature: Uint8List(0), // Signature vide par défaut
      isFinalized: false,
      remise:
          chantier.remiseParDefaut ??
          0, // Hypothèse: Chantier a un champ 'remise'
      tauxTVA:
          chantier.tauxTVAParDefaut ??
          1.20, // Hypothèse: Chantier a un champ 'tauxTVA'
      dateDerniereModification: DateTime.now(),
    );

    // ✅ La seule ligne pour enregistrer la facture
    await _factureDraftService.save(facture);
  }

  Future<void> recalculateFactureDraft() async {
    // Lecture de la facture existante via le service unifié
    final existing = await _factureDraftService.get(_id);

    if (existing != null && !existing.isFinalized) {
      await createFactureDraft(); // Recrée et écrase l'ancienne (car ID est le même)
    }
  }
}
