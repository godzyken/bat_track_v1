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

  Client({
    required this.id,
    required this.nom,
    required this.email,
    required this.telephone,
    required this.adresse,
  });

  @override
  factory Client.fromJson(Map<String, dynamic> json) => _$ClientFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$ClientToJson(this);

  Map<String, dynamic> toMap() => toJson();
  factory Client.fromMap(Map<String, dynamic> map) => Client.fromJson(map);

  @override
  Client fromJson(Map<String, dynamic> json) => Client(
    id: json['id'] ?? '',
    nom: json['nom'] ?? '',
    email: json['email'] ?? '',
    telephone: json['telephone'] ?? '',
    adresse: json['adresse'] ?? '',
  );

  @override
  Client copyWithId(String? id) => Client(
    id: id ?? this.id,
    nom: nom,
    email: email,
    telephone: telephone,
    adresse: adresse,
  );

  factory Client.mock() => Client(
    id: const Uuid().v4(),
    nom: 'Client de test',
    email: 'test@exemple.com',
    telephone: '0601020304',
    adresse: '2 rue des Tests, Toulouse',
  );
}
