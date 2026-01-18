import 'package:bat_track_v1/data/local/models/entities/chantier_etapes_entity.dart';
import 'package:bat_track_v1/data/local/models/entities/intervention_entity.dart';
import 'package:bat_track_v1/data/local/models/entities/pieces_jointes_entity.dart';
import 'package:hive_ce/hive.dart';

import '../../../../models/data/hive_model.dart';
import '../chantiers/chantier.dart';

part 'chantier_entity.g.dart';

@HiveType(typeId: 0)
class ChantierEntity extends HiveObject implements HiveModel<Chantier> {
  @HiveField(0)
  final String cid;
  @HiveField(1)
  final String nom;
  @HiveField(2)
  final String adresse;
  @HiveField(3)
  final String clientId;
  @HiveField(4)
  final DateTime dateDebut;
  @HiveField(5)
  final DateTime? dateFin;
  @HiveField(6)
  final String? etat;
  @HiveField(7)
  final List<String> technicienIds;
  @HiveField(8)
  final List<PieceJointeEntity> documents;
  @HiveField(9)
  final List<ChantierEtapesEntity> etapes;
  @HiveField(10)
  final String? commentaire;
  @HiveField(11)
  final double? budgetPrevu;
  @HiveField(12)
  final double? budgetReel;
  @HiveField(13)
  final List<InterventionEntity> interventions;
  @HiveField(14)
  final String? chefDeProjetId;
  @HiveField(15)
  final DateTime? chUpdatedAt;
  @HiveField(16)
  final bool clientValide;
  @HiveField(17)
  final bool chefDeProjetValide;
  @HiveField(18)
  final bool techniciensValides;
  @HiveField(19)
  final bool superUtilisateurValide;
  @HiveField(20)
  final bool isCloudOnly;
  @HiveField(21)
  final double tauxTVA;
  @HiveField(22)
  final double? remise;

  ChantierEntity({
    required this.cid,
    required this.nom,
    required this.adresse,
    required this.clientId,
    required this.dateDebut,
    required this.dateFin,
    required this.etat,
    required this.technicienIds,
    required this.documents,
    required this.etapes,
    required this.commentaire,
    required this.budgetPrevu,
    required this.budgetReel,
    required this.interventions,
    required this.chefDeProjetId,
    required this.clientValide,
    required this.chefDeProjetValide,
    required this.techniciensValides,
    required this.superUtilisateurValide,
    required this.isCloudOnly,
    required this.tauxTVA,
    this.chUpdatedAt,
    this.remise = 0.0,
  });

  @override
  Chantier toModel() => Chantier(
    id: id,
    nom: nom,
    adresse: adresse,
    clientId: clientId,
    dateDebut: dateDebut,
    dateFin: dateFin,
    etat: etat,
    commentaire: commentaire,
    etapes: etapes.map((e) => e.toModel()).toList(),
    documents: documents.map((e) => e.toModel()).toList(),
    interventions: interventions.map((e) => e.toModel()).toList(),
    chefDeProjetId: chefDeProjetId,
    technicienIds: technicienIds,
    budgetPrevu: budgetPrevu,
    budgetReel: budgetReel,
    clientValide: clientValide,
    chefDeProjetValide: chefDeProjetValide,
    techniciensValides: techniciensValides,
    superUtilisateurValide: superUtilisateurValide,
    isCloudOnly: isCloudOnly,
    updatedAt: updatedAt,
    tauxTVAParDefaut: tauxTVA,
    remiseParDefaut: remise,
  );

  @override
  String get id => cid;

  @override
  DateTime? get updatedAt => chUpdatedAt;

  factory ChantierEntity.fromModel(Chantier model) {
    return ChantierEntity(
      cid: model.id,
      nom: model.nom,
      adresse: model.adresse,
      clientId: model.clientId,
      dateDebut: model.dateDebut,
      dateFin: model.dateFin,
      etat: model.etat,
      technicienIds: model.technicienIds,
      documents: model.documents
          .map((e) => PieceJointeEntity.fromModel(e))
          .toList(),
      etapes: model.etapes
          .map((e) => ChantierEtapesEntity.fromModel(e))
          .toList(),
      commentaire: model.commentaire,
      budgetPrevu: model.budgetPrevu,
      budgetReel: model.budgetReel,
      interventions: model.interventions
          .map((e) => InterventionEntity.fromModel(e))
          .toList(),
      chefDeProjetId: model.chefDeProjetId,
      clientValide: model.clientValide,
      chefDeProjetValide: model.chefDeProjetValide,
      techniciensValides: model.techniciensValides,
      superUtilisateurValide: model.superUtilisateurValide,
      isCloudOnly: model.isCloudOnly,
      chUpdatedAt: model.updatedAt,
      tauxTVA: model.tauxTVAParDefaut,
      remise: model.remiseParDefaut,
    );
  }

  @override
  ChantierEntity fromModel(Chantier model) => ChantierEntity.fromModel(model);
}
