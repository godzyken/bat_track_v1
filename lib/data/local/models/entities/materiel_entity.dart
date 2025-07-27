import 'package:bat_track_v1/data/local/models/index_model_extention.dart';
import 'package:hive/hive.dart';

import '../../../../models/data/hive_model.dart';

part 'materiel_entity.g.dart';

@HiveType(typeId: 7)
class MaterielEntity extends HiveObject implements HiveModel<Materiel> {
  @HiveField(0)
  final String matId;
  @HiveField(1)
  final String nom;
  @HiveField(2)
  final double prixUnitaire;
  @HiveField(3)
  final double quantiteFixe;
  @HiveField(4)
  final double? joursLocation;
  @HiveField(5)
  final double? prixLocation;
  @HiveField(6)
  final DateTime? matUpdatedAt;

  MaterielEntity({
    required this.matId,
    required this.nom,
    required this.prixUnitaire,
    required this.quantiteFixe,
    required this.prixLocation,
    required this.joursLocation,
    this.matUpdatedAt,
  });

  factory MaterielEntity.fromModel(Materiel model) {
    return MaterielEntity(
      matId: model.id,
      nom: model.nom,
      prixUnitaire: model.prixUnitaire,
      quantiteFixe: model.quantiteFixe,
      prixLocation: model.prixLocation,
      joursLocation: model.joursLocation,
      matUpdatedAt: model.updatedAt,
    );
  }

  @override
  MaterielEntity fromModel(Materiel model) => MaterielEntity.fromModel(model);

  @override
  Materiel toModel() => Materiel(
    id: id,
    nom: nom,
    prixUnitaire: prixUnitaire,
    quantiteFixe: quantiteFixe,
    prixLocation: prixLocation,
    joursLocation: joursLocation,
    updatedAt: updatedAt,
  );

  @override
  String get id => matId;

  @override
  DateTime? get updatedAt => matUpdatedAt;
}
