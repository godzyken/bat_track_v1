import 'dart:typed_data';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:uuid/uuid.dart';

import '../../../../models/data/json_model.dart';
import '../../adapters/signture_converter.dart';

part 'facture_draft.freezed.dart';
part 'facture_draft.g.dart';

@freezed
class FactureDraft
    with
        _$FactureDraft,
        JsonModel<FactureDraft>,
        JsonSerializableModel<FactureDraft> {
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
  double get totalHT => lignesManuelles.fold(
    0.0,
    (sum, ligne) => sum + ligne.montant * ligne.quantite,
  );

  double get remiseAmount => remise;

  double get totalApresRemise => totalHT - remiseAmount;

  double get tvaAmount => totalApresRemise * (tauxTVA / 100.0);

  double get totalTTC => totalApresRemise + tvaAmount;

  @override
  String get id => factureId;

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
}

@freezed
class CustomLigneFacture
    with
        _$CustomLigneFacture,
        JsonModel<CustomLigneFacture>,
        JsonSerializableModel<CustomLigneFacture> {
  const factory CustomLigneFacture({
    required String ctlId,
    required String description,
    required double montant,
    required int quantite,
    required double total,
    DateTime? ctlUpdatedAt,
  }) = _CustomLigneFacture;

  factory CustomLigneFacture.fromJson(Map<String, dynamic> json) =>
      _$CustomLigneFactureFromJson(json);

  const CustomLigneFacture._();

  @override
  String get id => ctlId;

  @override
  DateTime? get updatedAt => ctlUpdatedAt;

  factory CustomLigneFacture.mock() => CustomLigneFacture(
    ctlId: const Uuid().v4(),
    description: 'ravalement façade',
    montant: 300,
    quantite: 2,
    total: 600,
    ctlUpdatedAt: DateTime.now(),
  );
}
