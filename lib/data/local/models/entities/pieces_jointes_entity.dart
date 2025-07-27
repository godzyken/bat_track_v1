import 'dart:io';

import 'package:bat_track_v1/data/local/models/documents/pieces_jointes.dart';
import 'package:bat_track_v1/models/data/hive_model.dart';
import 'package:hive/hive.dart';

import '../base/has_files.dart';

part 'pieces_jointes_entity.g.dart';

@HiveType(typeId: 5, adapterName: 'PieceJointeAdapter')
class PieceJointeEntity extends HiveObject
    implements HiveModel<PieceJointe>, HasFile {
  @HiveField(0)
  String pjId;
  @HiveField(1)
  String? nom;
  @HiveField(2)
  String? url;
  @HiveField(3)
  String? typeMime;
  @HiveField(4)
  DateTime createdAt;
  @HiveField(5)
  String? type;
  @HiveField(6)
  String? parentType;
  @HiveField(7)
  String? parentId;
  @HiveField(8)
  double taille;
  @HiveField(9)
  DateTime? pjUpdatedAt;

  PieceJointeEntity({
    required this.pjId,
    required this.nom,
    required this.url,
    required this.typeMime,
    required this.createdAt,
    required this.type,
    required this.parentType,
    required this.parentId,
    required this.taille,
    this.pjUpdatedAt,
  });

  factory PieceJointeEntity.fromModel(PieceJointe model) {
    return PieceJointeEntity(
      pjId: model.id,
      nom: model.nom,
      url: model.url,
      typeMime: model.typeMime,
      createdAt: model.createdAt,
      type: model.type,
      parentType: model.parentType,
      parentId: model.parentId,
      taille: model.taille,
      pjUpdatedAt: model.updatedAt,
    );
  }

  @override
  PieceJointeEntity fromModel(PieceJointe model) =>
      PieceJointeEntity.fromModel(model);

  @override
  PieceJointe toModel() => PieceJointe(
    id: id,
    nom: nom!,
    url: url!,
    typeMime: typeMime!,
    createdAt: createdAt,
    type: type!,
    parentType: parentType!,
    parentId: parentId!,
    taille: taille,
    updatedAt: updatedAt,
  );

  @override
  String get id => pjId;

  @override
  DateTime? get updatedAt => pjUpdatedAt;

  @override
  File getFile() {
    return File(url!);
  }
}
