import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

import '../../../models/data/interface/doli_barr_adaptable.dart';
import '../../../models/data/json_model.dart';

part 'projet.g.dart';

@HiveType(typeId: 23)
class Projet extends JsonModel<Projet> implements DolibarrAdaptable<Projet> {
  @override
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String nom;
  @HiveField(2)
  final String description;
  @HiveField(3)
  final DateTime dateDebut;
  @HiveField(4)
  final DateTime dateFin;
  @HiveField(5)
  DateTime? _updatedAt;

  Projet({
    required this.id,
    required this.nom,
    required this.description,
    required this.dateDebut,
    required this.dateFin,
    DateTime? updatedAt,
  }) : _updatedAt = updatedAt;

  @override
  DateTime? get updatedAt => _updatedAt;

  @override
  set updatedAt(DateTime? value) => _updatedAt = value;

  factory Projet.fromJson(Map<String, dynamic> json) => Projet(
    id: json['id'] ?? const Uuid().v4(),
    nom: json['nom'] ?? '',
    description: json['description'] ?? '',
    dateDebut: DateTime.tryParse(json['dateDebut'] ?? '') ?? DateTime.now(),
    dateFin: DateTime.tryParse(json['dateFin'] ?? '') ?? DateTime.now(),
    updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
  );

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'nom': nom,
    'description': description,
    'dateDebut': dateDebut.toIso8601String(),
    'dateFin': dateFin.toIso8601String(),
    'updatedAt': updatedAt!.toIso8601String(),
  };

  @override
  Projet fromJson(Map<String, dynamic> json) => Projet.fromJson(json);

  @override
  Projet copyWithId(String? newId) => copyWith(id: newId);

  Projet copyWith({
    String? id,
    String? nom,
    String? description,
    DateTime? dateDebut,
    DateTime? dateFin,
    DateTime? updatedAt,
  }) {
    return Projet(
      id: id ?? this.id,
      nom: nom ?? this.nom,
      description: description ?? this.description,
      dateDebut: dateDebut ?? this.dateDebut,
      dateFin: dateFin ?? this.dateFin,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Projet fromDolibarrJson(Map<String, dynamic> json) => Projet(
    id: const Uuid().v4(),
    nom: json['title'] ?? '',
    description: json['note_public'] ?? '',
    dateDebut: DateTime.tryParse(json['date_start'] ?? '') ?? DateTime.now(),
    dateFin: DateTime.tryParse(json['date_end'] ?? '') ?? DateTime.now(),
    updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
  );

  @override
  Map<String, dynamic> toDolibarrJson() => {
    'title': nom,
    'note_public': description,
    'date_start': dateDebut.toIso8601String(),
    'date_end': dateFin.toIso8601String(),
    'updatedAt': updatedAt!.toIso8601String(),
  };

  factory Projet.mock() => Projet(
    id: const Uuid().v4(),
    nom: 'Construction École',
    description: 'Projet de construction modulaire pour école primaire.',
    dateDebut: DateTime.now(),
    dateFin: DateTime.now().add(const Duration(days: 120)),
    updatedAt: DateTime.now(),
  );
}
