import 'dart:typed_data';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shared_models/shared_models.dart';
import 'package:uuid/uuid.dart';

import '../extensions/budget_extentions.dart';

part 'facture_draft.freezed.dart';
part 'facture_draft.g.dart';

@freezed
sealed class FactureDraft
    with _$FactureDraft, AccessControlMixin, ValidationMixin
    implements UnifiedModel {
  const factory FactureDraft({
    required String chantierId,
    required String clientId,
    required List<CustomLigneFacture> lignesManuelles,
    @Uint8ListBase64Converter() required Uint8List signature,
    required bool isFinalized,
    required String factureId,
    required double remise,
    required double tauxTVA,
    @NullableDateTimeIsoConverter() DateTime? dateDerniereModification,
    @NullableDateTimeIsoConverter() DateTime? signedAt,
    @Default(false) bool? isSigned,
  }) = _FactureDraft;

  const FactureDraft._();

  factory FactureDraft.fromJson(Map<String, dynamic> json) =>
      _$FactureDraftFromJson(json);

  // --- Getters calculés ---
  double get totalHT =>
      lignesManuelles.fold(0.0, (sum, ligne) => sum + ligne.totalLigneHT);

  double get totalTVA => lignesManuelles.fold(
    0.0,
    (sum, ligne) => sum + (ligne.totalLigneHT * (ligne.tauxTVA / 100)),
  );

  double get totalTTC => totalHT + tauxTVA;

  @override
  String get id => factureId;

  @override
  String? get ownerId => clientId;

  @override
  DateTime? get updatedAt => dateDerniereModification;

  factory FactureDraft.mock() => FactureDraft(
    chantierId: 'ch_006',
    clientId: 'cl_007',
    lignesManuelles: [CustomLigneFacture.mock(), CustomLigneFacture.mock()],
    signature: Uint8List.fromList([0, 1, 2, 3]),
    isFinalized: false,
    signedAt: DateTime.now(),
    dateDerniereModification: DateTime.now(),
    isSigned: true,
    factureId: 'factureId',
    remise: 20,
    tauxTVA: 1.20,
  );

  @override
  bool get isUpdated => updatedAt != null;

  @override
  UnifiedModel copyWithId(String newId) => copyWith(factureId: newId);
}

@freezed
sealed class CustomLigneFacture
    with _$CustomLigneFacture, AccessControlMixin, ValidationMixin
    implements UnifiedModel {
  const factory CustomLigneFacture({
    required String ctlId,
    required String description,
    required double montant,
    required int quantite,
    required double total,
    DateTime? ctlUpdatedAt,
    @Default(0.0) double remisePourcentage,
    @Default(20.0) double tauxTVA,
    @Default('materiel') String type,
    @Default(false) bool clientValide,
    @Default(false) bool chefDeProjetValide,
    @Default(false) bool techniciensValides,
    @Default(false) bool superUtilisateurValide,

    @Default(false) bool isCloudOnly,
  }) = _CustomLigneFacture;

  factory CustomLigneFacture.fromJson(Map<String, dynamic> json) =>
      _$CustomLigneFactureFromJson(json);

  const CustomLigneFacture._();

  @override
  String get id => ctlId;

  @override
  String? get ownerId => ctlId;

  @override
  DateTime? get updatedAt => ctlUpdatedAt;

  factory CustomLigneFacture.mock() => CustomLigneFacture(
    ctlId: const Uuid().v4(),
    description: 'ravalement façade',
    montant: 300,
    quantite: 2,
    total: 600,
    ctlUpdatedAt: DateTime.now(),
    remisePourcentage: 10,
    tauxTVA: 20,
    type: 'materiel',
  );

  @override
  UnifiedModel copyWithId(String newId) => copyWith(ctlId: newId);

  @override
  bool get isUpdated => updatedAt != null;

  @override
  bool get toutesPartiesOntValide => ValidationHelper.computeValidationStatus(
    clientValide: clientValide,
    chefDeProjetValide: chefDeProjetValide,
    techniciensValides: techniciensValides,
    superUtilisateurValide: superUtilisateurValide,
  );

  // Calcul pour la ligne spécifique
  double get totalLigneHT =>
      (montant * quantite) * (1 - remisePourcentage / 100);
  double get totalLigneTTC => totalLigneHT * (1 + tauxTVA / 100);
}
