import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';

part 'technicien.g.dart';

@HiveType(typeId: 2)
@JsonSerializable()
class Technicien {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String nom;
  @HiveField(2)
  final String email;
  @HiveField(3)
  final List<String> competences;

  Technicien({
    required this.id,
    required this.nom,
    required this.email,
    required this.competences,
  });

  factory Technicien.fromJson(Map<String, dynamic> json) =>
      _$TechnicienFromJson(json);
  Map<String, dynamic> toJson() => _$TechnicienToJson(this);

  Map<String, dynamic> toMap() => toJson();
  factory Technicien.fromMap(Map<String, dynamic> map) =>
      Technicien.fromJson(map);

  factory Technicien.mock() => Technicien(
    id: const Uuid().v4(),
    nom: 'Technicien Test',
    email: 'tech@example.com',
    competences: ['Plomberie', 'Electricite'],
  );
}
