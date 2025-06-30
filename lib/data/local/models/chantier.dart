import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';

import '../../../models/data/json_model.dart';
import 'chantier_etapes.dart';

part 'chantier.g.dart';

@HiveType(typeId: 0)
@JsonSerializable()
class Chantier extends JsonModel {
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

  @HiveField(8)
  List<String> photos;

  @HiveField(9)
  List<String> documents;

  @HiveField(10)
  List<ChantierEtape> etapes;

  @HiveField(11)
  String? commentaire;

  @HiveField(12)
  double? budgetPrevu;

  @HiveField(13)
  double? budgetReel;

  Chantier({
    required this.id,
    required this.nom,
    required this.adresse,
    required this.clientId,
    required this.dateDebut,
    this.dateFin,
    this.etat,
    List<String>? technicienIds,
    List<String>? photos,
    List<String>? documents,
    List<ChantierEtape>? etapes,
    this.commentaire,
    this.budgetPrevu,
    this.budgetReel,
  }) : technicienIds = technicienIds ?? [],
       photos = photos ?? [],
       documents = documents ?? [],
       etapes = etapes ?? [];

  // JSON
  factory Chantier.fromJson(Map<String, dynamic> json) =>
      _$ChantierFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$ChantierToJson(this);

  // Firebase
  Map<String, dynamic> toMap() => toJson();
  factory Chantier.fromMap(Map<String, dynamic> map) => Chantier.fromJson(map);

  factory Chantier.mock() {
    final etapes = [
      ChantierEtape.mock(titre: 'Préparation', terminee: true),
      ChantierEtape.mock(titre: 'Travaux', terminee: false),
    ];

    return Chantier(
      id: const Uuid().v4(),
      nom: 'Chantier de démonstration',
      adresse: '10 rue des Demoiselles, Toulouse',
      clientId: 'client_001',
      dateDebut: DateTime.now(),
      dateFin: DateTime.now().add(const Duration(days: 60)),
      etat: 'En cours',
      technicienIds: ['tech_001', 'tech_002'],
      photos: ['photo1.jpg', 'photo2.jpg'],
      documents: ['devis.pdf', 'facture.pdf'],
      etapes: etapes,
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
    photos: List<String>.from(photos),
    documents: List<String>.from(documents),
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
    List<String>? photos,
    List<String>? documents,
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
      photos: photos ?? this.photos,
      documents: documents ?? this.documents,
      etapes: etapes ?? this.etapes,
      commentaire: commentaire ?? this.commentaire,
      budgetPrevu: budgetPrevu ?? this.budgetPrevu,
      budgetReel: budgetReel ?? this.budgetReel,
    );
  }
}
