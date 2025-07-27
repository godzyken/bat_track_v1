import 'package:bat_track_v1/data/local/models/entities/pieces_jointes_entity.dart';
import 'package:bat_track_v1/data/local/models/index_model_extention.dart';
import 'package:bat_track_v1/models/data/hive_model.dart';
import 'package:hive/hive.dart';

part 'intervention_entity.g.dart';

@HiveType(typeId: 3)
class InterventionEntity extends HiveObject implements HiveModel<Intervention> {
  @HiveField(0)
  final String sId;
  @HiveField(1)
  final String chantierId;
  @HiveField(2)
  final String technicienId;
  @HiveField(3)
  final String description;
  @HiveField(4)
  final DateTime date;
  @HiveField(5)
  final String statut;
  @HiveField(6)
  final List<PieceJointeEntity> document;
  @HiveField(7)
  final String? titre;
  @HiveField(8)
  final String? commentaire;
  @HiveField(9)
  final FactureDraft? facture;
  @HiveField(10)
  final DateTime? sUpdatedAt;

  InterventionEntity({
    required this.sId,
    required this.chantierId,
    required this.technicienId,
    required this.description,
    required this.date,
    required this.statut,
    required this.document,
    required this.titre,
    required this.commentaire,
    required this.facture,
    this.sUpdatedAt,
  });

  factory InterventionEntity.fromModel(Intervention model) {
    return InterventionEntity(
      sId: model.id,
      chantierId: model.chantierId,
      technicienId: model.technicienId,
      description: model.description,
      date: model.date,
      statut: model.statut,
      document:
          model.document.map((e) => PieceJointeEntity.fromModel(e)).toList(),
      titre: model.titre,
      commentaire: model.commentaire,
      facture: model.facture,
      sUpdatedAt: model.updatedAt,
    );
  }

  @override
  InterventionEntity fromModel(Intervention model) =>
      InterventionEntity.fromModel(model);

  @override
  Intervention toModel() => Intervention(
    id: id,
    chantierId: chantierId,
    technicienId: technicienId,
    description: description,
    date: date,
    statut: statut,
    document: document.map((e) => PieceJointe.fromJson(e as dynamic)).toList(),
    titre: titre,
    commentaire: commentaire,
    facture: facture,
    updatedAt: updatedAt,
  );

  @override
  String get id => sId;

  @override
  DateTime? get updatedAt => sUpdatedAt;
}
