import 'package:bat_track_v1/data/local/models/index_model_extention.dart';
import 'package:hive_ce/hive.dart';

import '../../../../models/data/hive_model.dart';

part 'materiau_entity.g.dart';

@HiveType(typeId: 6)
class MateriauEntity extends HiveObject implements HiveModel<Materiau> {
  @HiveField(0)
  final String maId;
  @HiveField(1)
  final String nom;
  @HiveField(2)
  final double prixUnitaire;
  @HiveField(3)
  final String unite;
  @HiveField(4)
  final double? coefficientSurface;
  @HiveField(5)
  final double quantiteFixe;
  @HiveField(6)
  final DateTime? maUpdatedAt;

  MateriauEntity({
    required this.maId,
    required this.nom,
    required this.prixUnitaire,
    required this.unite,
    this.coefficientSurface,
    required this.quantiteFixe,
    this.maUpdatedAt,
  });

  factory MateriauEntity.fromModel(Materiau model) {
    return MateriauEntity(
      maId: model.id,
      nom: model.nom,
      prixUnitaire: model.prixUnitaire,
      unite: model.unite,
      coefficientSurface: model.coefficientSurface,
      quantiteFixe: model.quantiteFixe!,
      maUpdatedAt: model.updatedAt,
    );
  }

  @override
  MateriauEntity fromModel(Materiau model) => MateriauEntity.fromModel(model);

  @override
  Materiau toModel() => Materiau(
    id: id,
    nom: nom,
    prixUnitaire: prixUnitaire,
    unite: unite,
    coefficientSurface: coefficientSurface,
    updatedAt: updatedAt,
  );

  @override
  String get id => maId;

  @override
  DateTime? get updatedAt => maUpdatedAt;
}
