import 'package:bat_track_v1/data/local/models/index_model_extention.dart';
import 'package:hive_ce/hive.dart';

import '../../../../models/data/hive_model.dart';

part 'piece_entity.g.dart';

@HiveType(typeId: 8)
class PieceEntity extends HiveObject implements HiveModel<Piece> {
  @HiveField(0)
  final String pcId;
  @HiveField(1)
  final String nom;
  @HiveField(2)
  final double surface;
  @HiveField(3)
  final List<Materiau>? materiaux;
  @HiveField(4)
  final List<Materiel>? materiels;
  @HiveField(5)
  final List<MainOeuvre>? mainOeuvre;
  @HiveField(6)
  final DateTime? pcUpdatedAt;
  @HiveField(7)
  final String addBy;
  @HiveField(8)
  final bool? validatedBy;

  PieceEntity({
    required this.pcId,
    required this.nom,
    required this.surface,
    required this.materiaux,
    required this.materiels,
    required this.mainOeuvre,
    required this.addBy,
    this.pcUpdatedAt,
    this.validatedBy,
  });

  factory PieceEntity.fromModel(Piece model) {
    return PieceEntity(
      pcId: model.id,
      nom: model.nom,
      surface: model.surface,
      materiaux: model.materiaux,
      materiels: model.materiels,
      mainOeuvre: model.mainOeuvre,
      pcUpdatedAt: model.updatedAt,
      addBy: model.addedBy,
      validatedBy: model.validatedByTech,
    );
  }

  @override
  PieceEntity fromModel(Piece model) => PieceEntity.fromModel(model);

  @override
  Piece toModel() => Piece(
    id: id,
    nom: nom,
    surface: surface,
    materiaux: materiaux,
    materiels: materiels,
    mainOeuvre: mainOeuvre,
    updatedAt: updatedAt,
    addedBy: addBy,
    validatedByTech: validatedBy,
  );

  @override
  String get id => pcId;

  @override
  DateTime? get updatedAt => pcUpdatedAt;
}
