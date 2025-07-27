/*
import 'package:bat_track_v1/data/local/models/utilisateurs/technicien.dart';
import 'package:bat_track_v1/models/data/json_model.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive/hive.dart';

import '../../../../features/documents/controllers/generator/calculator.dart';

part 'travaux.freezed.dart';
part 'travaux.g.dart';

/// ----------------------- PIECE -----------------------
@freezed
@HiveType(typeId: 6, adapterName: 'PieceAdapter')
@JsonSerializable()
class Piece with _$Piece implements JsonModel<Piece> {
  const Piece._(); // nécessaire pour les méthodes personnalisées

  const factory Piece({
    @HiveField(0) required String id,
    @HiveField(1) required String nom,
    @HiveField(2) required double surface,
    @HiveField(3) @Default(<Materiau>[]) List<Materiau> materiaux,
    @HiveField(4) @Default(<Materiel>[]) List<Materiel> materiels,
    @HiveField(5) required MainOeuvre mainOeuvre,
    @HiveField(6) DateTime? updatedAt,
  }) = _Piece;

  double getBudgetTotal(List<Technicien> techniciens) {
    return BudgetGen.calculerTotal(
      surface: surface,
      materiaux: materiaux,
      materiels: materiels,
      mainOeuvre: mainOeuvre,
      techniciens: techniciens,
    );
  }

  double getBudgetTotalSansMainOeuvre() {
    return BudgetGen.calculerTotalPartielSansMainOeuvre(
      surface: surface,
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
  Piece copyWithId(String? id) => copyWith(id: id ?? this.id);

  @override
  Piece fromDolibarrJson(Map<String, dynamic> json) {
    return Piece(
      id: json['id'] ?? '',
      nom: json['nom'] ?? '',
      surface: (json['surface'] ?? 0).toDouble(),
      materiaux: (json['materiaux'] as List<dynamic>? ?? [])
          .map((e) => Materiau.fromJson(e as Map<String, dynamic>))
          .toList(),
      materiels: (json['materiels'] as List<dynamic>? ?? [])
          .map((e) => Materiel.fromJson(e as Map<String, dynamic>))
          .toList(),
      mainOeuvre: json['mainOeuvre'] != null
          ? MainOeuvre.fromJson(json['mainOeuvre'])
          : MainOeuvre.mock(),
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? ''),
    );
  }

  factory Piece.mock({
    String? id,
    String nom = 'Bureau',
    double? surface,
    List<Materiau>? materiaux,
    List<Materiel>? materiels,
    MainOeuvre? mainOeuvre,
    DateTime? updatedAt,
  }) => Piece(
    id: id ?? '1',
    nom: nom,
    surface: surface ?? 100,
    materiaux:
        materiaux ??
        [
          Materiau.mock(
            id: 'm_fr01',
            nom: 'Bois',
            prixUnitaire: 100,
            unite: 'm²',
          ),
          Materiau.mock(
            id: 'm_fr02',
            nom: 'Pierre',
            prixUnitaire: 50,
            unite: 'm²',
          ),
        ],
    materiels:
        materiels ??
        [
          Materiel.mock(
            id: 'mat_bt_01',
            nom: 'Marteau',
            prixUnitaire: 10,
            quantiteFixe: 10,
          ),
          Materiel.mock(
            id: 'mat_bt_02',
            nom: 'Pelle',
            prixUnitaire: 5,
            quantiteFixe: 5,
          ),
        ],
    mainOeuvre:
        mainOeuvre ??
        MainOeuvre.mock(idTechnicien: 'tec_35', heuresEstimees: 10),
    updatedAt: updatedAt ?? DateTime.now(),
  );

  @override
  // TODO: implement id
  String get id => this;

  @override
  // TODO: implement updatedAt
  DateTime? get updatedAt => throw UnimplementedError();
}

/// ----------------------- MATERIAU -----------------------
@freezed
@HiveType(typeId: 7, adapterName: 'MateriauAdapter')
@JsonSerializable()
class Materiau with _$Materiau implements JsonModel<Materiau> {
  const Materiau._(); // Nécessaire pour méthodes personnalisées

  @JsonSerializable(explicitToJson: true)
  const factory Materiau({
    @HiveField(0) required String id,
    @HiveField(1) required String nom,
    @HiveField(2) required double prixUnitaire,
    @HiveField(3) required String unite,
    @HiveField(4) double? coefficientSurface,
    @HiveField(5) double? quantiteFixe,
    @HiveField(6) DateTime? updatedAt,
  }) = _Materiau;

  factory Materiau.fromJson(Map<String, dynamic> json) =>
      _$MateriauFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$MateriauToJson(this);

  @override
  Materiau fromJson(Map<String, dynamic> json) => Materiau.fromJson(json);

  @override
  Materiau copyWithId(String? id) => copyWith(id: id ?? this.id);

  @override
  Materiau fromDolibarrJson(Map<String, dynamic> json) {
    return Materiau(
      id: json['id'] ?? '',
      nom: json['nom'] ?? '',
      prixUnitaire: (json['prixUnitaire'] ?? 0).toDouble(),
      unite: json['unite'] ?? '',
      coefficientSurface: (json['coefficientSurface'] as num?)?.toDouble(),
      quantiteFixe: (json['quantiteFixe'] as num?)?.toDouble(),
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? ''),
    );
  }

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
  // TODO: implement id
  String get id => throw UnimplementedError();

  @override
  // TODO: implement updatedAt
  DateTime? get updatedAt => throw UnimplementedError();
}

/// ----------------------- MATERIEL -----------------------
@freezed
@HiveType(typeId: 8, adapterName: 'MaterielAdapter')
@JsonSerializable()
class Materiel with _$Materiel implements JsonModel<Materiel> {
  const Materiel._(); // Pour les méthodes personnalisées

  @JsonSerializable(explicitToJson: true)
  const factory Materiel({
    @HiveField(0) required String id,
    @HiveField(1) required String nom,
    @HiveField(2) required double prixUnitaire,
    @HiveField(3) required double quantiteFixe,
    @HiveField(4) double? joursLocation,
    @HiveField(5) double? prixLocation,
    @HiveField(6) DateTime? updatedAt,
  }) = _Materiel;

  /// JSON local

  factory Materiel.fromJson(Map<String, dynamic> json) =>
      _$MaterielFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$MaterielToJson(this);

  @override
  Materiel fromJson(Map<String, dynamic> json) => Materiel.fromJson(json);

  @override
  Materiel copyWithId(String? id) => copyWith(id: id);

  @override
  Materiel fromDolibarrJson(Map<String, dynamic> json) {
    return Materiel(
      id: json['id']?.toString() ?? '',
      nom: json['nom'] ?? '',
      prixUnitaire: (json['prixUnitaire'] ?? 0).toDouble(),
      quantiteFixe: (json['quantiteFixe'] as num?)!.toDouble(),
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? ''),
    );
  }

  factory Materiel.mock({
    String? id,
    String nom = 'Marteau',
    double? prixUnitaire,
    double? quantiteFixe,
    DateTime? updatedAt,
  }) => Materiel(
    id: id ?? '1',
    nom: nom,
    prixUnitaire: prixUnitaire ?? 10,
    quantiteFixe: quantiteFixe ?? 10,
    updatedAt: updatedAt,
  );

  @override
  // TODO: implement id
  String get id => throw UnimplementedError();

  @override
  // TODO: implement updatedAt
  DateTime? get updatedAt => throw UnimplementedError();
}

/// ----------------------- MAIN OEUVRE -----------------------

@freezed
@HiveType(typeId: 9, adapterName: 'MainOeuvreAdapter')
@JsonSerializable()
class MainOeuvre with _$MainOeuvre implements JsonModel<MainOeuvre> {
  const MainOeuvre._(); // Nécessaire pour méthodes custom

  @JsonSerializable(explicitToJson: true)
  const factory MainOeuvre({
    @HiveField(0) required String id,
    @HiveField(1) String? idTechnicien,
    @HiveField(2) @Default(0.0) double heuresEstimees,
    @HiveField(3) DateTime? updatedAt,
  }) = _MainOeuvre;

  factory MainOeuvre.fromJson(Map<String, dynamic> json) =>
      _$MainOeuvreFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$MainOeuvreToJson(this);

  @override
  MainOeuvre fromJson(Map<String, dynamic> json) => MainOeuvre.fromJson(json);

  @override
  MainOeuvre copyWithId(String? id) => copyWith(id: id);

  MainOeuvre copyWith({
    String? id,
    String? idTechnicien,
    double? heuresEstimees,
    DateTime? updatedAt,
  }) {
    return MainOeuvre(
      id: id ?? this.id,
      idTechnicien: idTechnicien ?? this.idTechnicien,
      heuresEstimees: heuresEstimees ?? this.heuresEstimees,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  MainOeuvre fromDolibarrJson(Map<String, dynamic> json) {
    return MainOeuvre(
      id: json['id']?.toString() ?? '',
      idTechnicien: json['idTechnicien']?.toString() ?? '',
      heuresEstimees: (json['heuresEstimees'] ?? 0).toDouble(),
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? ''),
    );
  }

  factory MainOeuvre.mock({
    String? id,
    String? idTechnicien,
    double heuresEstimees = 0,
    DateTime? updatedAt,
  }) => MainOeuvre(
    id: id ?? '1',
    idTechnicien: idTechnicien,
    heuresEstimees: heuresEstimees,
    updatedAt: updatedAt,
  );

  @override
  // TODO: implement id
  String get id => throw UnimplementedError();

  @override
  // TODO: implement updatedAt
  DateTime? get updatedAt => throw UnimplementedError();
}
*/
