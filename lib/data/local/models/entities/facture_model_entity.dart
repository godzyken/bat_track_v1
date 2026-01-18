import 'dart:typed_data';

import 'package:bat_track_v1/data/local/adapters/mappers.dart';
import 'package:bat_track_v1/data/local/models/entities/facture_draft_entity.dart';
import 'package:hive_ce/hive.dart';

import '../../../../models/data/hive_model.dart';
import '../documents/facture_model.dart';

part 'facture_model_entity.g.dart';

@HiveType(typeId: 14)
class FactureModelEntity extends HiveObject implements HiveModel<FactureModel> {
  @HiveField(0)
  final String factId;

  @HiveField(1)
  final String chantierId;

  @HiveField(2)
  final String reference;

  @HiveField(3)
  final List<CustomLigneFactureEntity> lignes;

  @HiveField(4)
  final double montant;

  @HiveField(5)
  final String clientId;

  @HiveField(6)
  final DateTime date;

  @HiveField(7)
  final Uint8List? signature;

  @HiveField(8)
  final FactureStatusEntity status;

  @HiveField(9)
  DateTime? factUpdatedAt;

  FactureModelEntity({
    required this.factId,
    required this.chantierId,
    required this.reference,
    required this.lignes,
    required this.montant,
    required this.clientId,
    required this.date,
    this.signature,
    this.status = FactureStatusEntity.brouillon,
    this.factUpdatedAt,
  });

  factory FactureModelEntity.fromModel(FactureModel model) {
    return FactureModelEntity(
      factId: model.id,
      chantierId: model.chantierId,
      reference: model.reference,
      lignes: model.lignes
          .map((e) => CustomLigneFactureEntity.fromModel(e))
          .toList(),
      montant: model.montant,
      clientId: model.clientId,
      date: model.createdAt,
      signature: model.signature,
      status: model.status.toEntity(),
      factUpdatedAt: model.updatedAt,
    );
  }

  @override
  FactureModelEntity fromModel(FactureModel model) =>
      FactureModelEntity.fromModel(model);

  @override
  FactureModel toModel() => FactureModel(
    id: id,
    chantierId: chantierId,
    reference: reference,
    lignes: lignes.map((e) => e.toModel()).toList(),
    montant: montant,
    clientId: clientId,
    createdAt: date,
    status: status.toModel(),
    signature: signature,
    updatedAt: updatedAt,
  );

  @override
  String get id => factId;

  @override
  DateTime? get updatedAt => factUpdatedAt;
}

@HiveType(typeId: 13)
enum FactureStatusEntity {
  @HiveField(0)
  brouillon,
  @HiveField(1)
  validee,
  @HiveField(2)
  envoyee,
  @HiveField(3)
  payee,
}
