import 'package:bat_track_v1/data/local/models/index_model_extention.dart';
import 'package:hive_ce/hive.dart';

import '../../../../models/data/hive_model.dart';

part 'projet_entity.g.dart';

@HiveType(typeId: 1)
class ProjetEntity extends HiveObject implements HiveModel<Projet> {
  @HiveField(0)
  final String pid;

  @HiveField(1)
  final String nom;

  @HiveField(2)
  final String description;

  @HiveField(3)
  final DateTime dateDebut;

  @HiveField(4)
  final DateTime dateFin;

  @HiveField(5)
  final bool clientValide;

  @HiveField(6)
  final bool chefDeProjetValide;

  @HiveField(7)
  final bool techniciensValides;

  @HiveField(8)
  final bool superUtilisateurValide;

  @HiveField(9)
  final String createBy;

  @HiveField(10)
  final List<String> members;

  @HiveField(11)
  DateTime? pupdatedAt;

  @HiveField(12)
  final String company;

  @HiveField(13)
  final Map<String, dynamic> cloudVersion;

  @HiveField(14)
  final Map<String, dynamic>? localDraft;

  ProjetEntity({
    required this.pid,
    required this.nom,
    required this.description,
    required this.company,
    required this.dateDebut,
    required this.dateFin,
    required this.clientValide,
    required this.chefDeProjetValide,
    required this.techniciensValides,
    required this.superUtilisateurValide,
    required this.createBy,
    required this.members,
    required this.cloudVersion,
    required this.localDraft,
    this.pupdatedAt,
  });

  // Constructeur à partir du modèle Projet
  factory ProjetEntity.fromModel(Projet model) {
    return ProjetEntity(
      pid: model.id,
      nom: model.nom,
      company: model.company,
      description: model.description,
      dateDebut: model.dateDebut,
      dateFin: model.dateFin,
      clientValide: model.clientValide,
      chefDeProjetValide: model.chefDeProjetValide,
      techniciensValides: model.techniciensValides,
      superUtilisateurValide: model.superUtilisateurValide,
      createBy: model.ownerId,
      members: model.members,
      pupdatedAt: model.updatedAt,
      cloudVersion: model.cloudVersion,
      localDraft: model.localDraft,
    );
  }

  @override
  ProjetEntity fromModel(Projet model) => ProjetEntity.fromModel(model);

  // Convertir en modèle Projet
  @override
  Projet toModel() => Projet(
    id: id,
    nom: nom,
    company: company,
    description: description,
    dateDebut: dateDebut,
    dateFin: dateFin,
    clientValide: clientValide,
    chefDeProjetValide: chefDeProjetValide,
    techniciensValides: techniciensValides,
    superUtilisateurValide: superUtilisateurValide,
    updatedAt: updatedAt,
    createdBy: createBy,
    members: members,
    cloudVersion: cloudVersion,
    localDraft: localDraft,
    deadLine: dateFin,
  );

  @override
  String get id => pid;

  @override
  DateTime? get updatedAt => pupdatedAt;
}
