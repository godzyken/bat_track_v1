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

  Piece({
    this.id,
    required this.nom,
    required this.surfaceM2,
    required this.materiaux,
    required this.materiels,
    required this.mainOeuvre,
  });

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
  );

  Piece copyWith({
    String? id,
    String? nom,
    double? surfaceM2,
    List<Materiau>? materiaux,
    List<Materiel>? materiels,
    MainOeuvre? mainOeuvre,
  }) {
    return Piece(
      id: id ?? this.id,
      nom: nom ?? this.nom,
      surfaceM2: surfaceM2 ?? this.surfaceM2,
      materiaux: materiaux ?? this.materiaux,
      materiels: materiels ?? this.materiels,
      mainOeuvre: mainOeuvre ?? this.mainOeuvre,
    );
  }

  factory Piece.mock({
    String? id,
    String nom = 'Nom de la pièce',
    double? surfaceM2,
    List<Materiau>? materiaux,
    List<Materiel>? materiels,
    MainOeuvre? mainOeuvre,
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
  );
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

  Materiau({
    required this.id,
    required this.nom,
    required this.prixUnitaire,
    required this.unite,
    this.coefficientSurface,
    this.quantiteFixe,
  });

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
  );

  factory Materiau.mock({
    String? id,
    String nom = 'Bois',
    double? prixUnitaire,
    String unite = 'm²',
    double? coefficientSurface,
    double? quantiteFixe,
  }) => Materiau(
    id: id ?? '1',
    nom: nom,
    prixUnitaire: prixUnitaire ?? 100,
    unite: unite,
    coefficientSurface: coefficientSurface ?? 2.5,
    quantiteFixe: quantiteFixe ?? 5.0,
  );
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

  Materiel({
    required this.id,
    required this.nom,
    required this.prixUnitaire,
    required this.quantiteFixe,
    this.joursLocation,
    this.prixLocation,
  });

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
  );

  factory Materiel.mock({
    String? id,
    String nom = 'Marteau',
    double? prixUnitaire,
    double? quantiteFixe,
    double? joursLocation,
    double? prixLocation,
  }) {
    return Materiel(
      id: id ?? '1',
      nom: nom,
      prixUnitaire: prixUnitaire ?? 10,
      quantiteFixe: quantiteFixe ?? 10,
      joursLocation: joursLocation ?? 5.0,
      prixLocation: prixLocation ?? 500,
    );
  }
}

@HiveType(typeId: 9)
@JsonSerializable()
class MainOeuvre extends JsonModel {
  @HiveField(0)
  final String idTechnicien;

  @HiveField(1)
  final double heuresEstimees;

  MainOeuvre({required this.idTechnicien, required this.heuresEstimees});

  factory MainOeuvre.fromJson(Map<String, dynamic> json) =>
      _$MainOeuvreFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$MainOeuvreToJson(this);

  @override
  MainOeuvre fromJson(Map<String, dynamic> json) => MainOeuvre.fromJson(json);

  @override
  MainOeuvre copyWithId(String? id) =>
      MainOeuvre(idTechnicien: idTechnicien, heuresEstimees: heuresEstimees);

  MainOeuvre copyWith({String? idTechnicien, double? heuresEstimees}) {
    return MainOeuvre(
      idTechnicien: idTechnicien ?? this.idTechnicien,
      heuresEstimees: heuresEstimees ?? this.heuresEstimees,
    );
  }

  factory MainOeuvre.mock({String? idTechnicien, double? heuresEstimees}) =>
      MainOeuvre(
        idTechnicien: idTechnicien ?? 'demo-tech',
        heuresEstimees: heuresEstimees ?? 10,
      );

  @override
  String? get id => Technicien.mock().id;
}
