import 'dart:io';
import 'dart:typed_data';

import 'package:bat_track_v1/data/local/models/base/has_files.dart';
import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../../models/data/json_model.dart';

part 'pieces_jointes.g.dart';

@HiveType(typeId: 5, adapterName: 'PieceJointeAdapter')
@JsonSerializable()
class PieceJointe extends JsonModel implements HasFile {
  @override
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String? nom;
  @HiveField(2)
  final String? url;
  @HiveField(3)
  final String? typeMime;
  @HiveField(4)
  final DateTime createdAt;
  @HiveField(5)
  final String? type; // exemple : 'facture', 'video', 'document'

  @HiveField(6)
  final String? parentType; // ex: Chantier, Intervention
  @HiveField(7)
  final String? parentId;

  @HiveField(8)
  final int taille;

  @HiveField(9)
  DateTime? _updatedAt;

  PieceJointe({
    required this.id,
    this.nom,
    this.url,
    this.typeMime,
    required this.createdAt,
    this.type,
    this.parentType,
    this.parentId,
    required this.taille,
    DateTime? updatedAt,
  }) : _updatedAt = updatedAt;

  @override
  DateTime? get updatedAt => _updatedAt;

  @override
  set updatedAt(DateTime? value) => _updatedAt = value;

  @override
  File getFile() {
    if (url == null) {
      throw Exception('Path is null for PieceJointe $id');
    }
    return File(url!);
  }

  Uint8List getUintList() => Uint8List(taille);

  // JSON serialization
  factory PieceJointe.fromJson(Map<String, dynamic> json) =>
      _$PieceJointeFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$PieceJointeToJson(this);

  // Firebase compatible
  Map<String, dynamic> toMap() => toJson();

  factory PieceJointe.fromMap(Map<String, dynamic> map) =>
      PieceJointe.fromJson(map);

  // Override JsonModel methods
  @override
  PieceJointe fromJson(Map<String, dynamic> json) => PieceJointe.fromJson(json);

  @override
  PieceJointe copyWithId(String? id) => PieceJointe(
    id: id ?? this.id,
    nom: nom,
    url: url,
    type: type,
    createdAt: createdAt,
    typeMime: typeMime,
    parentType: parentType,
    parentId: parentId,
    taille: taille,
    updatedAt: updatedAt,
  );

  // Mock
  factory PieceJointe.mock({
    String? id,
    String nom = 'document.pdf',
    String url = 'https://example.com/document.pdf',
    String type = 'facture',
    String parentType = "Chantier",
    String parentId = "ch_01",
    String typeMime = "application/pdf",
    DateTime? createAt,
    int taille = 1024,
    DateTime? updatedAt,
  }) {
    return PieceJointe(
      id: id ?? 'mock_pj_001',
      nom: nom,
      url: url,
      type: type,
      taille: 1024,
      createdAt: createAt!,
      parentType: parentType,
      parentId: parentId,
      typeMime: typeMime,
      updatedAt: updatedAt,
    );
  }

  @override
  PieceJointe fromDolibarrJson(Map<String, dynamic> json) {
    return PieceJointe(
      id: json['id'] ?? '',
      nom: json['nom'] ?? '',
      url: json['url'] ?? '',
      type: json['type'] ?? '',
      taille: json['taille'] ?? 0,
      createdAt:
          json['createdAt'] ?? DateTime.tryParse(createdAt.toIso8601String()),
      typeMime: json['typeMime'] ?? '',
      parentType: json['parentType'] ?? '',
      parentId: json['parentId'] ?? '',
      updatedAt:
          DateTime.tryParse(updatedAt!.toIso8601String()) ?? DateTime.now(),
    );
  }
}
