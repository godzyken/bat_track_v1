import 'package:flutter/material.dart';
import 'package:shared_models/shared_models.dart';

import '../projets/projet.dart';
import 'json_adapter.dart';

class ProjetAdapter implements JsonAdapter<Projet> {
  @override
  Map<String, dynamic> toJson(Projet model) => {
    'id': model.id,
    'nom': model.nom,
    'description': model.description,
    'dateDebut': model.dateDebut.toIso8601String(),
    'dateFin': model.dateFin.toIso8601String(),
    'deadLine': model.deadLine?.toIso8601String(),
    'company': model.company,
    'createdBy': model.createdBy,
    'members': model.members,
    'assignedUserIds': model.assignedUserIds,
    'status': model.status,
    'clientValide': model.clientValide,
    'chefDeProjetValide': model.chefDeProjetValide,
    'techniciensValides': model.techniciensValides,
    'superUtilisateurValide': model.superUtilisateurValide,
    'specialite': model.specialite,
    'localisation': model.localisation,
    'budgetEstime': model.budgetEstime,
    'currentUserId': model.currentUserId,
  };

  @override
  Projet fromJson(Map<String, dynamic> json) => Projet(
    id: json['id'] as String,
    nom: json['nom'] as String,
    description: json['description'] as String,
    dateDebut: DateTime.parse(json['dateDebut']),
    dateFin: DateTime.parse(json['dateFin']),
    deadLine: tryParseDate(json['deadLine']),
    company: json['company'] as String,
    createdBy: json['createdBy'] as String,
    members: (json['members'] as List<dynamic>).cast<String>(),
    assignedUserIds:
        (json['assignedUserIds'] as List<dynamic>?)?.cast<String>() ?? [],
    status: ProjetStatus.values.firstWhere(
      (e) => e.toString() == 'ProjetStatus.${json['status']}',
      orElse: () => ProjetStatus.draft,
    ),
    clientValide: json['clientValide'] as bool,
    chefDeProjetValide: json['chefDeProjetValide'] as bool,
    techniciensValides: json['techniciensValides'] as bool,
    superUtilisateurValide: json['superUtilisateurValide'] as bool,
    specialite: json['specialite'] as String?,
    localisation: json['localisation'] as String?,
    budgetEstime: (json['budgetEstime'] as num?)?.toDouble(),
    currentUserId: json['currentUserId'] as String?,
    cloudVersion: {},
    localDraft: {},
    chantiers: [],
  );

  @override
  List<JsonField> get fields => [
    JsonField(
      name: 'nom',
      label: 'Nom du projet',
      type: FieldType.text,
      required: true,
      icon: Icons.wb_shade_outlined,
    ),
    JsonField(
      name: 'description',
      label: 'Description',
      type: FieldType.text,
      icon: Icons.description,
    ),
    JsonField(
      name: 'dateDebut',
      label: 'Date de début',
      type: FieldType.date,
      icon: Icons.calendar_today,
    ),
    JsonField(
      name: 'dateFin',
      label: 'Date de fin',
      type: FieldType.date,
      icon: Icons.event,
    ),
    JsonField(
      name: 'specialite',
      label: 'Spécialité',
      type: FieldType.text,
      icon: Icons.workspace_premium_outlined,
    ),
    JsonField(
      name: 'localisation',
      label: 'Localisation',
      type: FieldType.text,
      icon: Icons.share_location_outlined,
    ),
    JsonField(
      name: 'budgetEstime',
      label: 'Budget estimé',
      type: FieldType.number,
      icon: Icons.attach_money,
    ),
  ];

  @override
  // TODO: implement initialData
  Map<String, dynamic> get initialData => throw UnimplementedError();
}
