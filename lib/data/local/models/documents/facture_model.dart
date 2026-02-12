import 'dart:typed_data';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shared_models/shared_models.dart';
import 'package:uuid/uuid.dart';

import '../extensions/budget_extentions.dart';
import 'facture_draft.dart';

part 'facture_model.freezed.dart';
part 'facture_model.g.dart';

@freezed
sealed class FactureModel
    with _$FactureModel, AccessControlMixin, ValidationMixin
    implements UnifiedModel {
  const FactureModel._();

  const factory FactureModel({
    required String id,
    required String chantierId,
    required String reference,
    required List<CustomLigneFacture> lignes,
    required double montant,
    required String clientId,
    @DateTimeIsoConverter() required DateTime createdAt,
    @NullableDateTimeIsoConverter() DateTime? signedAt,
    @Uint8ListBase64Converter() Uint8List? signature,
    required FactureStatus status,
    @NullableDateTimeIsoConverter() DateTime? updatedAt,
    @Default(false) bool clientValide,
    @Default(false) bool chefDeProjetValide,
    @Default(false) bool techniciensValides,
    @Default(false) bool superUtilisateurValide,

    @Default(false) bool isCloudOnly,
  }) = _FactureModel;

  factory FactureModel.fromJson(Map<String, dynamic> json) =>
      _$FactureModelFromJson(json);

  factory FactureModel.mock() => FactureModel(
    id: const Uuid().v4(),
    chantierId: 'chId_123',
    reference: 'FAC-2025-001',
    lignes: [
      CustomLigneFacture(
        ctlId: const Uuid().v4(),
        description: 'Maçonnerie',
        montant: 1200,
        quantite: 1,
        total: 1200,
      ),
      CustomLigneFacture(
        ctlId: const Uuid().v4(),
        description: 'Peinture',
        montant: 340,
        quantite: 1,
        total: 340,
      ),
    ],
    montant: 1540,
    clientId: 'cl_001',
    createdAt: DateTime.now(),
    status: FactureStatus.brouillon,
    signature: Uint8List.fromList([0, 1, 2, 3]),
    updatedAt: DateTime.now(),
  );

  factory FactureModel.fromDraft(FactureDraft draft) => FactureModel(
    id: const Uuid().v4(),
    chantierId: draft.chantierId,
    reference: draft.factureId,
    lignes: draft.lignesManuelles,
    montant: draft.lignesManuelles.fold(0.0, (sum, l) => sum + l.total),
    clientId: draft.clientId,
    createdAt: draft.dateDerniereModification ?? DateTime.now(),
    signature: draft.signature,
    signedAt: draft.signedAt,
    status: FactureStatus.brouillon,
    updatedAt: draft.updatedAt ?? DateTime.now(),
  );

  @override
  bool get isUpdated => updatedAt != null;

  @override
  UnifiedModel copyWithId(String newId) => copyWith(id: newId);

  @override
  bool get toutesPartiesOntValide => ValidationHelper.computeValidationStatus(
    clientValide: clientValide,
    chefDeProjetValide: chefDeProjetValide,
    techniciensValides: techniciensValides,
    superUtilisateurValide: superUtilisateurValide,
  );

  @override
  String? get ownerId => clientId;
}

enum FactureStatus { brouillon, validee, envoyee, payee }
