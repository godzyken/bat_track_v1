import 'dart:typed_data';

import 'package:bat_track_v1/core/providers/entity_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/riverpod/base_entity_notifier.dart';
import '../../../../core/services/unified_entity_service.dart';
import '../../../../data/local/models/entities/index_entity_extention.dart';
import '../../../../data/local/models/index_model_extention.dart';
import '../../../../data/remote/providers/chantier_provider.dart';

class ChantierNotifierV2 extends BaseEntityNotifier<Chantier> {
  final _uuid = const Uuid();
  final String chantierId;

  ChantierNotifierV2(this.chantierId);

  // ─────────────────────────────────────────────
  // BaseEntityNotifier contrat
  // ─────────────────────────────────────────────

  @override
  String get entityId => chantierId;

  @override
  Future<Chantier?> fetchById(String id) =>
      ref.read(chantierServiceProvider).get(id);

  @override
  Future<void> save(Chantier item) =>
      ref.read(chantierServiceProvider).save(item);

  @override
  Future<void> delete(String id) =>
      ref.read(chantierServiceProvider).delete(id);

  // ─────────────────────────────────────────────
  // Override build() pour ajouter le stream temps réel
  // ─────────────────────────────────────────────

  @override
  Future<Chantier?> build() async {
    if (chantierId.isEmpty) return null;

    // Écoute temps réel — auto-annulé par Riverpod à chaque rebuild
    ref.listen(watchChantierProvider(chantierId), (_, next) {
      next.whenData((value) => state = AsyncData(value));
    });

    return fetchById(chantierId);
  }

  // ─────────────────────────────────────────────
  // Accès aux services (lazy, via ref)
  // ─────────────────────────────────────────────

  UnifiedEntityService<ChantierEtape, ChantierEtapesEntity> get _etapeService =>
      ref.read(chantierEtapeServiceProvider);

  UnifiedEntityService<Piece, PieceEntity> get _pieceService =>
      ref.read(pieceServiceProvider);

  UnifiedEntityService<PieceJointe, PieceJointeEntity>
  get _pieceJointeService => ref.read(pieceJointeServiceProvider);

  UnifiedEntityService<FactureDraft, FactureDraftEntity>
  get _factureDraftService => ref.read(factureDraftServiceProvider);

  UnifiedEntityService<Intervention, InterventionEntity>
  get _interventionService => ref.read(interventionServiceProvider);

  // ─────────────────────────────────────────────
  // Guard central — étend updateEntity de la base
  // ─────────────────────────────────────────────

  Future<void> _guard(Future<void> Function() fn) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await fn();
      return fetchById(chantierId);
    });
  }

  Future<void> _touchUpdatedAt() async {
    final current = state.value;
    if (current == null) return;
    await save(current.copyWith(updatedAt: DateTime.now()));
  }

  // ─────────────────────────────────────────────
  // Étapes
  // ─────────────────────────────────────────────

  Future<void> addEtape(ChantierEtape etape) => _guard(() async {
    await _etapeService.save(
      etape.copyWith(
        id: _uuid.v4(),
        chantierId: chantierId,
        updatedAt: DateTime.now(),
      ),
    );
    await recalculateFactureDraft();
    await _touchUpdatedAt();
  });

  Future<void> updateEtape(ChantierEtape etape) => _guard(() async {
    await _etapeService.save(etape);
    await recalculateFactureDraft();
    await _touchUpdatedAt();
  });

  Future<void> deleteEtape(String etapeId) => _guard(() async {
    await _etapeService.delete(etapeId);
    await recalculateFactureDraft();
    await _touchUpdatedAt();
  });

  Future<void> toggleTerminee(String etapeId) async {
    final e = await _etapeService.get(etapeId);
    if (e == null) return;
    await updateEtape(
      e.copyWith(terminee: !e.terminee, updatedAt: DateTime.now()),
    );
  }

  // ─────────────────────────────────────────────
  // Pièces
  // ─────────────────────────────────────────────

  Future<void> addPiece(Piece piece) => _guard(() async {
    await _pieceService.save(
      piece.copyWith(
        id: _uuid.v4(),
        addedBy: chantierId,
        updatedAt: DateTime.now(),
      ),
    );
    await recalculateFactureDraft();
    await _touchUpdatedAt();
  });

  Future<void> updatePiece(Piece piece) => _guard(() async {
    await _pieceService.save(piece);
    await recalculateFactureDraft();
    await _touchUpdatedAt();
  });

  Future<void> deletePiece(String pieceId) => _guard(() async {
    await _pieceService.delete(pieceId);
    await recalculateFactureDraft();
    await _touchUpdatedAt();
  });

  // ─────────────────────────────────────────────
  // Pièces Jointes
  // ─────────────────────────────────────────────

  Future<void> addPieceJointe(PieceJointe piece) => _guard(() async {
    await _pieceJointeService.save(
      piece.copyWith(
        id: _uuid.v4(),
        parentId: chantierId,
        updatedAt: DateTime.now(),
      ),
    );
    await _touchUpdatedAt();
  });

  Future<void> updatePieceJointe(PieceJointe piece) => _guard(() async {
    await _pieceJointeService.save(piece);
    await _touchUpdatedAt();
  });

  Future<void> deletePieceJointe(String pieceId) => _guard(() async {
    await _pieceJointeService.delete(pieceId);
    await _touchUpdatedAt();
  });

  // ─────────────────────────────────────────────
  // Interventions
  // ─────────────────────────────────────────────

  Future<void> addIntervention(Intervention intervention) => _guard(() async {
    await _interventionService.save(
      intervention.copyWith(
        id: _uuid.v4(),
        chantierId: chantierId,
        updatedAt: DateTime.now(),
      ),
    );
    await recalculateFactureDraft();
    await _touchUpdatedAt();
  });

  // ─────────────────────────────────────────────
  // Chantier
  // ─────────────────────────────────────────────

  Future<void> updateChantier(Chantier chantier) => _guard(() async {
    final isNew = chantier.id.isEmpty;
    await save(chantier.copyWith(updatedAt: DateTime.now()));
    if (isNew) await createFactureDraft();
  });

  // ─────────────────────────────────────────────
  // Facture Draft
  // ─────────────────────────────────────────────

  Future<void> createFactureDraft() async {
    final chantier = state.value;
    if (chantier == null) return;

    final allEtapes = await _etapeService.getAllLocal();
    final allPieces = await _pieceService.getAllLocal();
    final allInterventions = await _interventionService.getAllLocal();
    final lignes = <CustomLigneFacture>[];

    for (final e in allEtapes.where((e) => e.chantierId == chantierId)) {
      final montant = allPieces
          .where((p) => p.id == e.id)
          .fold<double>(0, (t, p) => t + p.getBudgetTotalSansMainOeuvre());

      lignes.add(
        CustomLigneFacture(
          ctlId: _uuid.v4(),
          description: 'Étape: ${e.description}',
          montant: montant,
          quantite: 1,
          total: montant,
          ctlUpdatedAt: DateTime.now(),
        ),
      );
    }

    for (final i in allInterventions.where((i) => i.chantierId == chantierId)) {
      final montant = i.facture?.totalHT ?? 0;
      lignes.add(
        CustomLigneFacture(
          ctlId: _uuid.v4(),
          description: 'Intervention: ${i.description}',
          montant: montant,
          quantite: 1,
          total: montant,
          ctlUpdatedAt: i.updatedAt,
        ),
      );
    }

    await _factureDraftService.save(
      FactureDraft(
        factureId: chantierId,
        chantierId: chantier.id,
        clientId: chantier.clientId,
        lignesManuelles: lignes,
        signature: Uint8List(0),
        isFinalized: false,
        remise: chantier.remiseParDefaut ?? 0,
        tauxTVA: chantier.tauxTVAParDefaut ?? 1.20,
        dateDerniereModification: DateTime.now(),
      ),
    );
  }

  Future<void> recalculateFactureDraft() async {
    final existing = await _factureDraftService.get(chantierId);
    if (existing != null && !existing.isFinalized) {
      await createFactureDraft();
    }
  }
}
