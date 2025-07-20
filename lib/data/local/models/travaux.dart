import 'package:bat_track_v1/data/local/models/technicien.dart';
import 'package:bat_track_v1/models/data/json_model.dart';
import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../../features/documents/controllers/generator/calculator.dart';

part 'travaux.g.dart';

@HiveType(typeId: 6)
@JsonSerializable()
class Piece extends JsonModel {
  @override
  @HiveField(0)
  String? id;

  @HiveField(1)
  final String nom;

  @HiveField(2)
  final double surfaceM2;

  @HiveField(3)
  final List<Materiau> materiaux;

  @HiveField(4)
  final List<Materiel> materiels;

  @HiveField(5)
  final MainOeuvre mainOeuvre;

  @HiveField(6)
  DateTime? _updatedAt;

  Piece({
    this.id,
    required this.nom,
    required this.surfaceM2,
    required this.materiaux,
    required this.materiels,
    required this.mainOeuvre,
    DateTime? updatedAt,
  }) : _updatedAt = updatedAt;

  @override
  DateTime? get updatedAt => _updatedAt;

  @override
  set updatedAt(DateTime? value) => _updatedAt = value;

  double getBudgetTotal(List<Technicien> techniciens) {
    return BudgetGen.calculerTotal(
      surface: surfaceM2,
      materiaux: materiaux,
      materiels: materiels,
      mainOeuvre: mainOeuvre,
      techniciens: techniciens,
    );
  }

  double getBudgetTotalSansMainOeuvre() {
    return BudgetGen.calculerTotalPartielSansMainOeuvre(
      surface: surfaceM2,
      materiaux: materiaux,
      materiels: materiels,
    );
  }

  factory Piece.fromJson(Map<String, dynamic> json) => _$PieceFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$PieceToJson(this);

  @override
  Piece fromJson(Map<String, dynamic> json) => Piece.fromJson(json);

  @override
  Piece copyWithId(String? id) => Piece(
    id: id ?? this.id,
    nom: nom,
    surfaceM2: surfaceM2,
    materiaux: materiaux,
    materiels: materiels,
    mainOeuvre: mainOeuvre,
    updatedAt: updatedAt,
  );

  Piece copyWith({
    String? id,
    String? nom,
    double? surfaceM2,
    List<Materiau>? materiaux,
    List<Materiel>? materiels,
    MainOeuvre? mainOeuvre,
    DateTime? updatedAt,
  }) {
    return Piece(
      id: id ?? this.id,
      nom: nom ?? this.nom,
      surfaceM2: surfaceM2 ?? this.surfaceM2,
      materiaux: materiaux ?? this.materiaux,
      materiels: materiels ?? this.materiels,
      mainOeuvre: mainOeuvre ?? this.mainOeuvre,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory Piece.mock({
    String? id,
    String nom = 'Nom de la pièce',
    double? surfaceM2,
    List<Materiau>? materiaux,
    List<Materiel>? materiels,
    MainOeuvre? mainOeuvre,
    DateTime? updatedAt,
  }) => Piece(
    id: id ?? '1',
    nom: nom,
    surfaceM2: surfaceM2 ?? 100,
    materiaux:
        materiaux ??
        [
          Materiau(id: 'm_fr01', nom: 'Bois', prixUnitaire: 100, unite: 'm²'),
          Materiau(id: 'm_fr02', nom: 'Pierre', prixUnitaire: 50, unite: 'm²'),
        ],
    materiels:
        materiels ??
        [
          Materiel(
            id: 'mat_bt_01',
            nom: 'Marteau',
            prixUnitaire: 10,
            quantiteFixe: 10,
          ),
          Materiel(
            id: 'mat_bt_02',
            nom: 'Pelle',
            prixUnitaire: 5,
            quantiteFixe: 5,
          ),
        ],
    mainOeuvre:
        mainOeuvre ?? MainOeuvre(idTechnicien: 'tec_35', heuresEstimees: 10),
    updatedAt: updatedAt ?? DateTime.now(),
  );

  @override
  Piece fromDolibarrJson(Map<String, dynamic> json) {
    return Piece(
      id: json['id'] ?? '',
      nom: json['nom'] ?? '',
      surfaceM2: json['surfaceM2'] ?? 0,
      materiaux: List<Materiau>.from(json['materiaux']),
      materiels: List<Materiel>.from(json['materiels']),
      mainOeuvre: MainOeuvre(
        idTechnicien: json['mainOeuvre']['idTechnicien'] ?? '',
        heuresEstimees: json['mainOeuvre']['heuresEstimees'] ?? 0,
      ),
      updatedAt: DateTime.tryParse(json['updatedAt']),
    );
  }

  factory Piece.fromDolibarr(Map<String, dynamic> json) => Piece.fromJson(json);
}

@HiveType(typeId: 7)
@JsonSerializable()
class Materiau extends JsonModel {
  @HiveField(0)
  @override
  final String id;

  @HiveField(1)
  final String nom;

  @HiveField(2)
  final double prixUnitaire;

  @HiveField(3)
  final String unite;

  @HiveField(4)
  final double? coefficientSurface;

  @HiveField(5)
  final double? quantiteFixe;

  @HiveField(6)
  DateTime? _updatedAt;

  Materiau({
    required this.id,
    required this.nom,
    required this.prixUnitaire,
    required this.unite,
    this.coefficientSurface,
    this.quantiteFixe,
    DateTime? updatedAt,
  }) : _updatedAt = updatedAt;

  @override
  DateTime? get updatedAt => _updatedAt;

  @override
  set updatedAt(DateTime? value) => _updatedAt = value;

  factory Materiau.fromJson(Map<String, dynamic> json) =>
      _$MateriauFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$MateriauToJson(this);

  @override
  Materiau fromJson(Map<String, dynamic> json) => Materiau.fromJson(json);

  @override
  Materiau copyWithId(String? id) => Materiau(
    id: id ?? this.id,
    nom: nom,
    prixUnitaire: prixUnitaire,
    unite: unite,
    coefficientSurface: coefficientSurface,
    quantiteFixe: quantiteFixe,
    updatedAt: updatedAt,
  );

  factory Materiau.mock({
    String? id,
    String nom = 'Bois',
    double? prixUnitaire,
    String unite = 'm²',
    double? coefficientSurface,
    double? quantiteFixe,
    DateTime? updatedAt,
  }) => Materiau(
    id: id ?? '1',
    nom: nom,
    prixUnitaire: prixUnitaire ?? 100,
    unite: unite,
    coefficientSurface: coefficientSurface ?? 2.5,
    quantiteFixe: quantiteFixe ?? 5.0,
    updatedAt: updatedAt,
  );

  @override
  Materiau fromDolibarrJson(Map<String, dynamic> json) {
    return Materiau(
      id: json['id'] ?? '',
      nom: json['nom'] ?? '',
      prixUnitaire: json['prixUnitaire'] ?? 0,
      unite: json['unite'] ?? '',
      coefficientSurface: json['coefficientSurface'],
      quantiteFixe: json['quantiteFixe'],
      updatedAt: DateTime.tryParse(json['updatedAt']),
    );
  }

  factory Materiau.fromDolibarr(Map<String, dynamic> json) =>
      Materiau.fromJson(json);
}

@HiveType(typeId: 8)
@JsonSerializable()
class Materiel extends JsonModel {
  @HiveField(0)
  @override
  final String id;

  @HiveField(1)
  final String nom;

  @HiveField(2)
  final double prixUnitaire;

  @HiveField(3)
  final double quantiteFixe;

  @HiveField(4)
  final double? joursLocation;

  @HiveField(5)
  final double? prixLocation;

  @HiveField(6)
  DateTime? _updatedAt;

  Materiel({
    required this.id,
    required this.nom,
    required this.prixUnitaire,
    required this.quantiteFixe,
    this.joursLocation,
    this.prixLocation,
    DateTime? updatedAt,
  }) : _updatedAt = updatedAt;

  @override
  DateTime? get updatedAt => _updatedAt;

  @override
  set updatedAt(DateTime? value) => _updatedAt = value;

  factory Materiel.fromJson(Map<String, dynamic> json) =>
      _$MaterielFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$MaterielToJson(this);

  @override
  Materiel fromJson(Map<String, dynamic> json) => Materiel.fromJson(json);

  @override
  Materiel copyWithId(String? id) => Materiel(
    id: id ?? this.id,
    nom: nom,
    prixUnitaire: prixUnitaire,
    quantiteFixe: quantiteFixe,
    joursLocation: joursLocation,
    prixLocation: prixLocation,
    updatedAt: updatedAt,
  );

  factory Materiel.mock({
    String? id,
    String nom = 'Marteau',
    double? prixUnitaire,
    double? quantiteFixe,
    double? joursLocation,
    double? prixLocation,
    DateTime? updatedAt,
  }) {
    return Materiel(
      id: id ?? '1',
      nom: nom,
      prixUnitaire: prixUnitaire ?? 10,
      quantiteFixe: quantiteFixe ?? 10,
      joursLocation: joursLocation ?? 5.0,
      prixLocation: prixLocation ?? 500,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  @override
  Materiel fromDolibarrJson(Map<String, dynamic> json) {
    return Materiel(
      id: json['id'] ?? '',
      nom: json['nom'] ?? '',
      prixUnitaire: json['prixUnitaire'] ?? 0,
      quantiteFixe: json['quantiteFixe'] ?? 0,
      joursLocation: json['joursLocation'],
      prixLocation: json['prixLocation'],
      updatedAt: DateTime.tryParse(json['updatedAt']),
    );
  }

  factory Materiel.fromDolibarr(Map<String, dynamic> json) =>
      Materiel.fromJson(json);
}

@HiveType(typeId: 9)
@JsonSerializable()
class MainOeuvre extends JsonModel {
  @HiveField(0)
  final String idTechnicien;

  @HiveField(1)
  final double heuresEstimees;

  @HiveField(2)
  DateTime? _updatedAt;

  MainOeuvre({
    required this.idTechnicien,
    required this.heuresEstimees,
    DateTime? updatedAt,
  }) : _updatedAt = updatedAt;

  @override
  DateTime? get updatedAt => _updatedAt;

  @override
  set updatedAt(DateTime? value) => _updatedAt = value;

  factory MainOeuvre.fromJson(Map<String, dynamic> json) =>
      _$MainOeuvreFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$MainOeuvreToJson(this);

  @override
  MainOeuvre fromJson(Map<String, dynamic> json) => MainOeuvre.fromJson(json);

  @override
  MainOeuvre copyWithId(String? id) => MainOeuvre(
    idTechnicien: idTechnicien,
    heuresEstimees: heuresEstimees,
    updatedAt: updatedAt,
  );

  MainOeuvre copyWith({
    String? idTechnicien,
    double? heuresEstimees,
    DateTime? updatedAt,
  }) {
    return MainOeuvre(
      idTechnicien: idTechnicien ?? this.idTechnicien,
      heuresEstimees: heuresEstimees ?? this.heuresEstimees,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory MainOeuvre.mock({
    String? idTechnicien,
    double? heuresEstimees,
    DateTime? updatedAt,
  }) => MainOeuvre(
    idTechnicien: idTechnicien ?? 'demo-tech',
    heuresEstimees: heuresEstimees ?? 10,
    updatedAt: updatedAt ?? DateTime.now(),
  );

  @override
  String? get id => Technicien.mock().id;

  @override
  MainOeuvre fromDolibarrJson(Map<String, dynamic> json) {
    return MainOeuvre(
      idTechnicien: json['idTechnicien'] ?? '',
      heuresEstimees: json['heuresEstimees'] ?? 0,
      updatedAt: DateTime.tryParse(json['updatedAt']),
    );
  }

  factory MainOeuvre.fromDolibarr(Map<String, dynamic> json) =>
      MainOeuvre.fromJson(json);
}
