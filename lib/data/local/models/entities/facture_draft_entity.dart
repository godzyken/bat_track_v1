import 'dart:typed_data';

import 'package:bat_track_v1/data/local/models/documents/facture_draft.dart';
import 'package:bat_track_v1/models/data/hive_model.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'facture_draft_entity.g.dart';

@HiveType(typeId: 17)
class FactureDraftEntity extends HiveObject implements HiveModel<FactureDraft> {
  @HiveField(0)
  final String chantierId;

  @HiveField(1)
  final List<CustomLigneFactureEntity> lignesManuelles;

  @HiveField(2)
  final Uint8List? signature;

  @HiveField(3)
  final bool isFinalized;

  @HiveField(4)
  final String? factureId;

  @HiveField(5)
  DateTime? dateDerniereModification;

  @HiveField(6)
  final double? remise;

  @HiveField(7)
  final double? tauxTVA;

  @HiveField(8)
  final String clientId;

  FactureDraftEntity({
    required this.factureId,
    required this.chantierId,
    required this.clientId,
    required this.lignesManuelles,
    required this.signature,
    required this.isFinalized,
    required this.remise,
    required this.tauxTVA,
    this.dateDerniereModification,
  });

  factory FactureDraftEntity.fromModel(FactureDraft model) {
    return FactureDraftEntity(
      factureId: model.id,
      chantierId: model.chantierId,
      clientId: model.clientId,
      lignesManuelles:
          model.lignesManuelles
              .map((e) => CustomLigneFactureEntity.fromModel(e))
              .toList(),
      signature: model.signature,
      isFinalized: model.isFinalized,
      remise: model.remise,
      tauxTVA: model.tauxTVA,
      dateDerniereModification: model.updatedAt,
    );
  }

  @override
  FactureDraftEntity fromModel(FactureDraft model) =>
      FactureDraftEntity.fromModel(model);

  @override
  FactureDraft toModel() => FactureDraft(
    factureId: factureId!,
    chantierId: chantierId,
    clientId: clientId,
    lignesManuelles: lignesManuelles.map((e) => e.toModel()).toList(),
    signature: signature!,
    isFinalized: isFinalized,
    remise: remise ?? 0,
    tauxTVA: tauxTVA ?? 0,
    dateDerniereModification: dateDerniereModification,
  );

  @override
  String get id => factureId!;

  @override
  DateTime? get updatedAt => dateDerniereModification;
}

@HiveType(typeId: 16)
class CustomLigneFactureEntity extends HiveObject
    implements HiveModel<CustomLigneFacture> {
  @HiveField(0)
  final String description;

  @HiveField(1)
  final double montant;

  @HiveField(2)
  int quantite;

  @HiveField(3)
  double total;

  CustomLigneFactureEntity({
    required this.description,
    required this.montant,
    required this.quantite,
    required this.total,
  });

  factory CustomLigneFactureEntity.fromModel(CustomLigneFacture model) {
    return CustomLigneFactureEntity(
      description: model.description,
      montant: model.montant,
      quantite: model.quantite,
      total: model.total,
    );
  }

  @override
  CustomLigneFactureEntity fromModel(CustomLigneFacture model) =>
      CustomLigneFactureEntity.fromModel(model);

  @override
  CustomLigneFacture toModel() => CustomLigneFacture(
    ctlId: id,
    description: description,
    montant: montant,
    quantite: quantite,
    total: total,
    ctlUpdatedAt: updatedAt,
  );

  @override
  String get id => const Uuid().v4();

  @override
  DateTime? get updatedAt => DateTime.now();
}
