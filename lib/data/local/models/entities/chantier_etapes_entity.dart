import 'package:bat_track_v1/data/local/models/index_model_extention.dart';
import 'package:bat_track_v1/models/data/hive_model.dart';
import 'package:hive_flutter/hive_flutter.dart';

part 'chantier_etapes_entity.g.dart';

@HiveType(typeId: 2)
class ChantierEtapesEntity extends HiveObject
    implements HiveModel<ChantierEtape> {
  @HiveField(0)
  final String ceId;
  @HiveField(1)
  final String chantierId;
  @HiveField(2)
  final List<PieceJointe> piecesJointes;
  @HiveField(3)
  final List<String>? timeline;
  @HiveField(4)
  final String titre;
  @HiveField(5)
  final String description;
  @HiveField(6)
  final DateTime dateDebut;
  @HiveField(7)
  final DateTime dateFin;
  @HiveField(8)
  final bool terminee;
  @HiveField(9)
  final double? budget;
  @HiveField(10)
  final List<Piece> pieces;
  @HiveField(11)
  final int ordre;
  @HiveField(12)
  final DateTime? ceUpdatedAt;
  @HiveField(13)
  final String statut;
  @HiveField(14)
  final List<String>? techniciens;

  ChantierEtapesEntity({
    required this.ceId,
    required this.titre,
    required this.description,
    required this.chantierId,
    required this.timeline,
    required this.statut,
    required this.pieces,
    required this.piecesJointes,
    required this.dateDebut,
    required this.dateFin,
    required this.ordre,
    required this.budget,
    required this.terminee,
    required this.ceUpdatedAt,
    this.techniciens,
  });

  factory ChantierEtapesEntity.fromModel(ChantierEtape model) {
    return ChantierEtapesEntity(
      ceId: model.id,
      titre: model.titre,
      description: model.description,
      chantierId: model.chantierId,
      timeline: model.timeline,
      statut: model.statut,
      pieces: model.pieces,
      piecesJointes: model.piecesJointes,
      dateDebut: model.dateDebut,
      dateFin: model.dateFin,
      ordre: model.ordre,
      budget: model.budget,
      terminee: model.terminee,
      ceUpdatedAt: model.updatedAt,
      techniciens: model.techniciens,
    );
  }

  @override
  ChantierEtapesEntity fromModel(ChantierEtape model) =>
      ChantierEtapesEntity.fromModel(model);

  @override
  ChantierEtape toModel() => ChantierEtape(
    id: id,
    chantierId: chantierId,
    piecesJointes: piecesJointes,
    titre: titre,
    description: description,
    dateDebut: dateDebut,
    dateFin: dateFin,
    terminee: terminee,
    pieces: pieces,
    ordre: ordre,
    statut: statut,
    updatedAt: updatedAt,
    timeline: timeline,
    budget: budget,
    techniciens: techniciens,
  );

  @override
  String get id => ceId;

  @override
  DateTime? get updatedAt => ceUpdatedAt;
}
