import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';

import '../../../models/data/json_model.dart';

part 'client.g.dart';

@HiveType(typeId: 1)
@JsonSerializable()
class Client extends JsonModel {
  @HiveField(0)
  @override
  final String id;

  @HiveField(1)
  final String nom;

  @HiveField(2)
  final String email;

  @HiveField(3)
  final String telephone;

  @HiveField(4)
  final String adresse;

  @HiveField(5)
  final int interventionsCount;

  @HiveField(6)
  final DateTime lastInterventionDate;

  @HiveField(7)
  final String status;

  @HiveField(8)
  final String priority;

  @HiveField(9)
  final String? contactName;

  @HiveField(10)
  final double? budgetPrevu;

  @HiveField(11)
  DateTime? _updatedAt;

  Client({
    required this.id,
    required this.nom,
    required this.email,
    required this.telephone,
    required this.adresse,
    required this.interventionsCount,
    required this.lastInterventionDate,
    required this.status,
    required this.priority,
    this.contactName,
    this.budgetPrevu,
    DateTime? updatedAt,
  }) : _updatedAt = updatedAt;

  @override
  DateTime? get updatedAt => _updatedAt;

  @override
  set updatedAt(DateTime? value) => _updatedAt = value;

  /// Désérialisation sécurisée
  factory Client.fromJson(Map<String, dynamic> json) => _$ClientFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$ClientToJson(this);

  Map<String, dynamic> toMap() => toJson();

  factory Client.fromMap(Map<String, dynamic> map) => Client.fromJson(map);

  @override
  Client fromJson(Map<String, dynamic> json) => Client.fromJson(json);

  @override
  Client copyWithId(String? id) => Client(
    id: id ?? this.id,
    nom: nom,
    email: email,
    telephone: telephone,
    adresse: adresse,
    interventionsCount: interventionsCount,
    lastInterventionDate: lastInterventionDate,
    status: status,
    priority: priority,
    contactName: contactName,
    budgetPrevu: budgetPrevu,
    updatedAt: updatedAt,
  );

  factory Client.mock() => Client(
    id: const Uuid().v4(),
    nom: 'Client de test',
    email: 'test@exemple.com',
    telephone: '0601020304',
    adresse: '2 rue des Tests, Toulouse',
    interventionsCount: 0,
    lastInterventionDate: DateTime.now(),
    status: 'Actif',
    priority: 'Moyen',
    contactName: 'jhon',
    budgetPrevu: 10000.0,
    updatedAt: DateTime.now(),
  );

  @override
  Client fromDolibarrJson(Map<String, dynamic> json) {
    return Client(
      id: json['id'] ?? const Uuid().v4(),
      nom: json['name'] ?? '',
      email: json['email'] ?? '',
      telephone: json['phone'] ?? '',
      adresse: json['address'] ?? '',
      interventionsCount: json['interventionsCount'] ?? 0,
      lastInterventionDate:
          json['lastInterventionDate'] != null
              ? DateTime.tryParse(json['lastInterventionDate']) ??
                  DateTime.now()
              : DateTime.now(),
      status: json['status'] ?? '',
      priority: json['priority'] ?? 'low',
      contactName: json['contactName'],
      budgetPrevu: json['budgetPrevu'],
      updatedAt: DateTime.tryParse(json['updatedAt']) ?? DateTime.now(),
    );
  }

  factory Client.fromDolibarr(Map<String, dynamic> json) =>
      Client.fromJson(json);
}
