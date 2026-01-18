import 'package:bat_track_v1/data/local/models/index_model_extention.dart';
import 'package:hive_ce/hive_ce.dart';

import '../../../../models/data/hive_model.dart';

part 'equipement_entity.g.dart';

@HiveType(typeId: 19)
class EquipementEntity extends HiveObject implements HiveModel<Equipement> {
  @override
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String nom;
  @HiveField(2)
  final String type; // extincteur, détecteur, etc.
  @HiveField(3)
  final String? localisation;
  @HiveField(4)
  final DateTime dateInstallation;
  @HiveField(5)
  final DateTime? dateProchaineVerification;
  @HiveField(6)
  final bool enService; // actif, hors service, à vérifier
  @HiveField(7)
  final String? homologation;
  @HiveField(8)
  final String? commentaire;
  @override
  @HiveField(9)
  final DateTime? updatedAt;
  @HiveField(10)
  final String chantierId;
  @HiveField(11)
  final String createdBy;
  @HiveField(12)
  final List<String>? technicienIds;
  @HiveField(13)
  final bool clientValide;
  @HiveField(14)
  final bool chefDeProjetValide;
  @HiveField(15)
  final bool techniciensValides;
  @HiveField(16)
  final bool superUtilisateurValide;
  @HiveField(17)
  final bool isCloudOnly;

  EquipementEntity({
    required this.id,
    required this.nom,
    required this.type,
    required this.localisation,
    required this.dateInstallation,
    required this.dateProchaineVerification,
    required this.enService,
    required this.homologation,
    required this.commentaire,
    required this.updatedAt,
    required this.chantierId,
    required this.createdBy,
    required this.technicienIds,
    required this.clientValide,
    required this.chefDeProjetValide,
    required this.techniciensValides,
    required this.superUtilisateurValide,
    required this.isCloudOnly,
  });

  @override
  HiveModel<Equipement> fromModel(Equipement model) => EquipementEntity(
    id: model.id,
    nom: model.nom,
    type: model.type,
    dateInstallation: model.dateInstallation,
    chantierId: model.chantierId,
    createdBy: model.createdBy,
    technicienIds: model.technicienIds,
    clientValide: model.clientValide,
    chefDeProjetValide: model.chefDeProjetValide,
    techniciensValides: model.techniciensValides,
    superUtilisateurValide: model.superUtilisateurValide,
    isCloudOnly: model.isCloudOnly,
    updatedAt: model.updatedAt,
    dateProchaineVerification: model.dateProchaineVerification,
    enService: model.enService,
    commentaire: model.commentaire,
    homologation: model.homologation,
    localisation: model.localisation,
  );

  @override
  Equipement toModel() => Equipement(
    id: id,
    nom: nom,
    type: type,
    dateInstallation: dateInstallation,
    chantierId: chantierId,
    createdBy: createdBy,
    technicienIds: technicienIds,
    clientValide: clientValide,
    chefDeProjetValide: chefDeProjetValide,
    techniciensValides: techniciensValides,
    superUtilisateurValide: superUtilisateurValide,
    isCloudOnly: isCloudOnly,
    updatedAt: updatedAt,
    dateProchaineVerification: dateProchaineVerification,
    enService: enService,
    commentaire: commentaire,
    homologation: homologation,
    localisation: localisation,
    count: null,
  );

  factory EquipementEntity.fromModel(Equipement model) {
    return EquipementEntity(
      id: model.id,
      nom: model.nom,
      type: model.type,
      localisation: model.localisation,
      dateInstallation: model.dateInstallation,
      dateProchaineVerification: model.dateProchaineVerification,
      enService: model.enService,
      homologation: model.homologation,
      commentaire: model.commentaire,
      updatedAt: model.updatedAt,
      chantierId: model.chantierId,
      createdBy: model.createdBy,
      technicienIds: model.technicienIds,
      clientValide: model.clientValide,
      chefDeProjetValide: model.chefDeProjetValide,
      techniciensValides: model.techniciensValides,
      superUtilisateurValide: model.superUtilisateurValide,
      isCloudOnly: model.isCloudOnly,
    );
  }
}
