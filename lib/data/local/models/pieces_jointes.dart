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
  final String nom;

  @HiveField(2)
  final String? url;

  @HiveField(3)
  final String type;

  @HiveField(4)
  final int taille;

  @HiveField(5)
  final String? path;

  PieceJointe({
    required this.id,
    required this.nom,
    required this.type,
    required this.taille,
    this.url,
    this.path,
  });

  @override
  File getFile() {
    if (path == null) {
      throw Exception('Path is null for PieceJointe $id');
    }
    return File(path!);
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
    taille: taille,
  );

  // Mock
  factory PieceJointe.mock({
    String? id,
    String nom = 'document.pdf',
    String url = 'https://example.com/document.pdf',
    String type = 'pdf',
    int taille = 1024,
  }) {
    return PieceJointe(
      id: id ?? 'mock_pj_001',
      nom: nom,
      url: url,
      type: type,
      taille: 1024,
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
    );
  }
}
