import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';

import '../../../models/data/json_model.dart';

part 'technicien.g.dart';

@HiveType(typeId: 2)
@JsonSerializable()
class Technicien extends JsonModel {
  @override
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String nom;
  @HiveField(2)
  final String email;
  @HiveField(3)
  final List<String> competences;
  @HiveField(4)
  final String? specialite;
  @HiveField(5)
  bool disponible = true;
  @HiveField(6)
  String? localisation;

  Technicien({
    required this.id,
    required this.nom,
    required this.email,
    required this.competences,
    this.specialite,
    this.disponible = true,
    this.localisation,
  });

  @override
  Technicien fromJson(Map<String, dynamic> json) => Technicien(
    id: json['id'] ?? '',
    nom: json['nom'] ?? '',
    specialite: json['specialite'],
    email: json['email'] ?? '',
    competences: List<String>.from(json['competences']),
    disponible: json['disponible'] ?? true,
    localisation: json['localisation'],
  );

  factory Technicien.fromJson(Map<String, dynamic> json) =>
      _$TechnicienFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$TechnicienToJson(this);

  Map<String, dynamic> toMap() => toJson();
  factory Technicien.fromMap(Map<String, dynamic> map) =>
      Technicien.fromJson(map);

  @override
  Technicien copyWithId(String? id) => Technicien(
    id: id ?? this.id,
    nom: nom,
    email: email,
    competences: competences,
    specialite: specialite,
    disponible: disponible,
    localisation: localisation,
  );

  factory Technicien.mock() => Technicien(
    id: const Uuid().v4(),
    nom: 'Technicien Test',
    email: 'tech@example.com',
    competences: ['Plomberie', 'Electricite'],
    specialite: 'Electricite',
    disponible: true,
    localisation: 'Paris',
  );
}
