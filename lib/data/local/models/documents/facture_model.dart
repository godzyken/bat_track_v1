import 'dart:typed_data';

import 'package:bat_track_v1/data/local/adapters/signture_converter.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:uuid/uuid.dart';

import '../../../../models/data/json_model.dart';
import 'facture_draft.dart';

part 'facture_model.freezed.dart';
part 'facture_model.g.dart';

@freezed
class FactureModel
    with
        _$FactureModel,
        JsonModel<FactureModel>,
        JsonSerializableModel<FactureModel> {
  const factory FactureModel({
    required String id,
    required String chantierId,
    required String reference,
    required List<CustomLigneFacture> lignes,
    required double montant,
    required String clientId,
    @DateTimeIsoConverter() required DateTime date,
    @Uint8ListBase64Converter() Uint8List? signature,
    required FactureStatus status,
    @NullableDateTimeIsoConverter() DateTime? updatedAt,
  }) = _FactureModel;

  factory FactureModel.fromJson(Map<String, dynamic> json) =>
      _$FactureModelFromJson(json);

  /* @override
  FactureModel fromJson(Map<String, dynamic> json) =>
      FactureModel.fromJson(json);

  @override
  Map<String, dynamic> toJson() => _$FactureModelToJson(this);

  @override
  FactureModel copyWithId(String? id) => copyWith(id: id ?? this.id);*/

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
    date: DateTime.now(),
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
    date: draft.dateDerniereModification ?? DateTime.now(),
    status: FactureStatus.brouillon,
    updatedAt: draft.updatedAt ?? DateTime.now(),
  );
}

enum FactureStatus { brouillon, validee, envoyee, payee }
