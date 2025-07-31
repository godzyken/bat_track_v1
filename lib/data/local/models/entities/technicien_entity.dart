import 'package:bat_track_v1/data/local/models/index_model_extention.dart';
import 'package:bat_track_v1/models/data/hive_model.dart';
import 'package:hive/hive.dart';

part 'technicien_entity.g.dart';

@HiveType(typeId: 9)
class TechnicienEntity extends HiveObject implements HiveModel<Technicien> {
  @HiveField(0)
  final String tId;
  @HiveField(1)
  final String nom;
  @HiveField(2)
  final String email;
  @HiveField(3)
  final List<String> competences;
  @HiveField(4)
  final String specialite;
  @HiveField(5)
  final bool disponible;
  @HiveField(6)
  final String? localisation;
  @HiveField(7)
  final double tauxHoraire;
  @HiveField(8)
  final List<String> chantiersAffectees;
  @HiveField(9)
  final List<String> etapesAffectees;
  @HiveField(10)
  final DateTime createdAt;
  @HiveField(11)
  final DateTime? deletedAt;
  @HiveField(12)
  final DateTime? tUpdatedAt;

  TechnicienEntity({
    required this.tId,
    required this.nom,
    required this.email,
    required this.competences,
    required this.specialite,
    required this.disponible,
    required this.localisation,
    required this.tauxHoraire,
    required this.chantiersAffectees,
    required this.etapesAffectees,
    required this.createdAt,
    this.deletedAt,
    this.tUpdatedAt,
  });

  factory TechnicienEntity.fromModel(Technicien model) {
    return TechnicienEntity(
      tId: model.id,
      nom: model.nom,
      email: model.email,
      competences: model.competences,
      specialite: model.specialite,
      disponible: model.disponible,
      localisation: model.localisation,
      tauxHoraire: model.tauxHoraire,
      chantiersAffectees: model.chantiersAffectees,
      etapesAffectees: model.etapesAffectees,
      createdAt: model.createdAt,
      deletedAt: model.dateDelete,
      tUpdatedAt: model.updatedAt,
    );
  }

  @override
  TechnicienEntity fromModel(Technicien model) =>
      TechnicienEntity.fromModel(model);

  @override
  Technicien toModel() => Technicien(
    id: id,
    nom: nom,
    email: email,
    competences: competences,
    specialite: specialite,
    disponible: disponible,
    tauxHoraire: tauxHoraire,
    chantiersAffectees: chantiersAffectees,
    etapesAffectees: etapesAffectees,
    createdAt: createdAt,
    dateDelete: deletedAt,
    updatedAt: updatedAt,
  );

  @override
  String get id => tId;

  @override
  DateTime? get updatedAt => tUpdatedAt;
}
