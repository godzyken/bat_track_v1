import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';

part 'chantier.g.dart';

@HiveType(typeId: 0)
@JsonSerializable()
class Chantier {
  @HiveField(0)
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

  Chantier({
    required this.id,
    required this.nom,
    required this.adresse,
    required this.clientId,
    required this.dateDebut,
    this.dateFin,
  });

  // JSON
  factory Chantier.fromJson(Map<String, dynamic> json) =>
      _$ChantierFromJson(json);
  Map<String, dynamic> toJson() => _$ChantierToJson(this);

  // Firebase
  Map<String, dynamic> toMap() => toJson();
  factory Chantier.fromMap(Map<String, dynamic> map) => Chantier.fromJson(map);

  // Mock
  factory Chantier.mock() {
    return Chantier(
      id: const Uuid().v4(),
      nom: 'Chantier de démonstration',
      adresse: '10 rue des Demoiselles, Toulouse',
      clientId: 'client_001',
      dateDebut: DateTime.now(),
      dateFin: DateTime.now().add(const Duration(days: 60)),
    );
  }
}
