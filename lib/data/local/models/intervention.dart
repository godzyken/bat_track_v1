import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';

import '../../../models/data/json_model.dart';

part 'intervention.g.dart';

@HiveType(typeId: 3)
@JsonSerializable()
class Intervention extends JsonModel {
  @override
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String chantierId;
  @HiveField(2)
  final String technicienId;
  @HiveField(3)
  final String description;
  @HiveField(4)
  final DateTime date;
  @HiveField(5)
  final String statut;
  @HiveField(6)
  final String? photo;
  @HiveField(7)
  final String? video;
  @HiveField(8)
  final String? document;
  @HiveField(9)
  final String? titre;

  Intervention({
    required this.id,
    required this.chantierId,
    required this.technicienId,
    required this.description,
    required this.date,
    required this.statut,
    this.photo,
    this.video,
    this.document,
    this.titre,
  });

  factory Intervention.fromJson(Map<String, dynamic> json) =>
      _$InterventionFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$InterventionToJson(this);

  Map<String, dynamic> toMap() => toJson();
  factory Intervention.fromMap(Map<String, dynamic> map) =>
      Intervention.fromJson(map);

  factory Intervention.mock() => Intervention(
    id: const Uuid().v4(),
    chantierId: 'chantier_001',
    technicienId: 'technicien_001',
    date: DateTime.now(),
    statut: 'Planifiée',
    description: 'Inspection de routine',
    titre: 'Inspection',
    photo: 'photo_001.jpg',
    video: 'video_001.mp4',
    document: 'document_001.pdf',
  );

  @override
  Intervention fromJson(Map<String, dynamic> json) => Intervention(
    id: json['id'] ?? '',
    chantierId: json['chantierId'] ?? '',
    technicienId: json['technicienId'] ?? '',
    description: json['description'] ?? '',
    date: DateTime.parse(json['date']),
    statut: json['statut'] ?? '',
    photo: json['photo'],
    video: json['video'],
    document: json['document'],
    titre: json['titre'],
  );

  @override
  Intervention copyWithId(String? id) => Intervention(
    id: id ?? this.id,
    chantierId: chantierId,
    technicienId: technicienId,
    description: description,
    date: date,
    statut: statut,
    photo: photo,
    video: video,
    document: document,
    titre: titre,
  );
}
