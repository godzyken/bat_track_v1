import 'package:bat_track_v1/data/local/models/base/safe_map_list.dart';
import 'package:bat_track_v1/data/local/models/index_model_extention.dart';
import 'package:bat_track_v1/models/data/interface/doli_barr_adaptable.dart';
import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';

import '../../../models/data/json_model.dart';

part 'chantier.g.dart';

@HiveType(typeId: 0, adapterName: 'ChantierAdapter')
@JsonSerializable()
class Chantier extends JsonModel<Chantier>
    implements DolibarrAdaptable<Chantier> {
  @HiveField(0)
  @override
  final String id;

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
  String? etat;

  @HiveField(7)
  List<String> technicienIds;

  @JsonKey(fromJson: _documentsFromJson, toJson: _documentsToJson)
  @HiveField(8)
  List<PieceJointe> documents;

  @HiveField(9)
  List<ChantierEtape> etapes;

  @HiveField(10)
  String? commentaire;

  @HiveField(11)
  double? budgetPrevu;

  @HiveField(12)
  double? budgetReel;

  Chantier({
    required this.id,
    required this.nom,
    required this.adresse,
    required this.clientId,
    required this.dateDebut,
    this.dateFin,
    this.etat,
    this.technicienIds = const [],
    this.documents = const [],
    this.etapes = const [],
    this.commentaire,
    this.budgetPrevu,
    this.budgetReel,
  });

  // JSON
  factory Chantier.fromJson(Map<String, dynamic> json) => Chantier(
    id: json['id'],
    nom: json['name'] ?? '',
    adresse: json['adresse'] ?? '',
    clientId: json['clientId'] ?? '',
    dateDebut: DateTime.tryParse(json['debut'] ?? '') ?? DateTime.now(),
    dateFin: json['fin'] != null ? DateTime.tryParse(json['fin']) : null,
    etat: json['etat'],
    technicienIds: List<String>.from(json['technicienIds'] ?? []),
    documents: safeMapList(json['documents'], PieceJointe.fromJson),
    etapes: safeMapList(json['etapes'], ChantierEtape.fromJson),
    commentaire: json['commentaire'],
    budgetPrevu: (json['budgetPrevu'] as num?)?.toDouble(),
    budgetReel: (json['budgetReel'] as num?)?.toDouble(),
  );

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'nom': nom,
    'commentaire': commentaire,
    'dateDebut': dateDebut.toIso8601String(),
    'dateFin': dateFin?.toIso8601String(),
  };

  // Firebase
  Map<String, dynamic> toMap() => toJson();

  factory Chantier.fromMap(Map<String, dynamic> map) => Chantier.fromJson(map);

  factory Chantier.mock({
    String? id,
    String? nom,
    String? adresse,
    String? clientId,
    DateTime? dateDebut,
    DateTime? dateFin,
    String? etat,
    List<String>? technicienIds,
    List<PieceJointe>? documents,
    List<ChantierEtape>? etapes,
    String? commentaire,
    double? budgetPrevu,
    double? budgetReel,
  }) {
    return Chantier(
      id: id ?? const Uuid().v4(),
      nom: nom ?? 'Chantier de démonstration',
      adresse: adresse ?? '10 rue des Demoiselles, Toulouse',
      clientId: clientId ?? 'client_001',
      dateDebut: dateDebut ?? DateTime.now(),
      dateFin: dateFin ?? DateTime.now().add(const Duration(days: 60)),
      etat: etat ?? 'En cours',
      technicienIds: technicienIds ?? ['tech_001', 'tech_002'],
      documents:
          documents ??
          [
            PieceJointe(
              id: 'doc_001',
              nom: 'devis.pdf',
              url: 'https://images.app.goo.gl/tjBoLaHSYnfsvPBZ8',
              type: 'pdf',
              taille: 1024,
            ),
            PieceJointe(
              id: 'doc_002',
              nom: 'facture.pdf',
              url: 'https://images.app.goo.gl/FHWsUrpzTMUx5xFX8',
              type: 'pdf',
              taille: 2048,
            ),
          ],
      etapes:
          etapes ??
          [
            ChantierEtape.mock(titre: 'Préparation', terminee: true),
            ChantierEtape.mock(titre: 'Travaux', terminee: false),
          ],
      commentaire: 'Urgence à traiter avant fin de mois',
      budgetPrevu: 15000.0,
      budgetReel: 12000.0,
    );
  }

  @override
  Chantier fromJson(Map<String, dynamic> json) => Chantier.fromJson(json);

  @override
  Chantier copyWithId(String? id) => Chantier(
    id: id ?? this.id,
    nom: nom,
    adresse: adresse,
    clientId: clientId,
    dateDebut: dateDebut,
    dateFin: dateFin,
    etat: etat,
    technicienIds: List<String>.from(technicienIds),
    documents: List<PieceJointe>.from(documents),
    etapes: List<ChantierEtape>.from(etapes),
    commentaire: commentaire,
    budgetPrevu: budgetPrevu,
    budgetReel: budgetReel,
  );

  @override
  String toString() {
    return 'Chantier(id: $id, nom: $nom, etat: $etat, budgetPrevu: $budgetPrevu, budgetReel: $budgetReel)';
  }

  Chantier copyWith({
    String? id,
    String? nom,
    String? adresse,
    String? clientId,
    DateTime? dateDebut,
    DateTime? dateFin,
    String? etat,
    List<String>? technicienIds,
    List<PieceJointe> documents = const [],
    List<ChantierEtape>? etapes,
    String? commentaire,
    double? budgetPrevu,
    double? budgetReel,
  }) {
    return Chantier(
      id: id ?? this.id,
      nom: nom ?? this.nom,
      adresse: adresse ?? this.adresse,
      clientId: clientId ?? this.clientId,
      dateDebut: dateDebut ?? this.dateDebut,
      dateFin: dateFin ?? this.dateFin,
      etat: etat ?? this.etat,
      technicienIds: technicienIds ?? this.technicienIds,
      documents: documents,
      etapes: etapes ?? this.etapes,
      commentaire: commentaire ?? this.commentaire,
      budgetPrevu: budgetPrevu ?? this.budgetPrevu,
      budgetReel: budgetReel ?? this.budgetReel,
    );
  }

  // Dolibarr
  @override
  Map<String, dynamic> toDolibarrJson() => {
    'ref': nom,
    'note_private': commentaire ?? '',
    'date_start': dateDebut.toIso8601String(),
    'date_end': dateFin?.toIso8601String(),
  };

  @override
  Chantier fromDolibarrJson(Map<String, dynamic> json) =>
      Chantier.fromJson(json);

  static List<PieceJointe> _documentsFromJson(List<dynamic>? json) {
    if (json == null) return [];
    return json
        .whereType<Map<String, dynamic>>()
        .map(PieceJointe.fromJson)
        .toList();
  }

  static List<Map<String, dynamic>> _documentsToJson(
    List<PieceJointe> documents,
  ) {
    return documents.map((doc) => doc.toJson()).toList();
  }
}
