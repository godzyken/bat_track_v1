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
  final String type; // extincteur, détecteur, etc. / marque
  @HiveField(3)
  final String? localisation; // modèle
  @HiveField(4)
  final DateTime dateInstallation;
  @HiveField(5)
  final DateTime? dateProchaineVerification; // dateDerniereMaintenance
  @HiveField(6)
  final bool enService; // actif, hors service, à vérifier
  @HiveField(7)
  final String? homologation; // numeroSerie
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
    type: model.marque ?? '',
    dateInstallation: model.dateInstallation ?? DateTime.now(),
    chantierId: model.chantierId,
    createdBy: '',
    technicienIds: const [],
    clientValide: model.clientValide,
    chefDeProjetValide: model.chefDeProjetValide,
    techniciensValides: model.techniciensValides,
    superUtilisateurValide: model.superUtilisateurValide,
    isCloudOnly: model.isCloudOnly,
    updatedAt: model.updatedAt,
    dateProchaineVerification: model.dateDerniereMaintenance,
    enService: true,
    commentaire: null,
    homologation: model.numeroSerie,
    localisation: model.modele,
  );

  @override
  Equipement toModel() => Equipement(
    id: id,
    nom: nom,
    marque: type,
    modele: localisation,
    numeroSerie: homologation,
    dateInstallation: dateInstallation,
    dateDerniereMaintenance: dateProchaineVerification,
    chantierId: chantierId,
    clientValide: clientValide,
    chefDeProjetValide: chefDeProjetValide,
    techniciensValides: techniciensValides,
    superUtilisateurValide: superUtilisateurValide,
    isCloudOnly: isCloudOnly,
    updatedAt: updatedAt,
  );

  factory EquipementEntity.fromModel(Equipement model) {
    return EquipementEntity(
      id: model.id,
      nom: model.nom,
      type: model.marque ?? '',
      localisation: model.modele,
      dateInstallation: model.dateInstallation ?? DateTime.now(),
      dateProchaineVerification: model.dateDerniereMaintenance,
      enService: true,
      homologation: model.numeroSerie,
      commentaire: null,
      updatedAt: model.updatedAt,
      chantierId: model.chantierId,
      createdBy: '',
      technicienIds: const [],
      clientValide: model.clientValide,
      chefDeProjetValide: model.chefDeProjetValide,
      techniciensValides: model.techniciensValides,
      superUtilisateurValide: model.superUtilisateurValide,
      isCloudOnly: model.isCloudOnly,
    );
  }
}
