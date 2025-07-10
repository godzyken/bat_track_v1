import 'package:bat_track_v1/data/local/models/pieces_jointes.dart';
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
  final List<PieceJointe>? document;
  @HiveField(7)
  final String? titre;
  @HiveField(8)
  final String? commentaire;

  Intervention({
    required this.id,
    required this.chantierId,
    required this.technicienId,
    required this.description,
    required this.date,
    required this.statut,
    this.document = const [],
    this.titre,
    this.commentaire,
  });

  factory Intervention.fromJson(Map<String, dynamic> json) =>
      _$InterventionFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$InterventionToJson(this);

  Map<String, dynamic> toMap() => toJson();
  factory Intervention.fromMap(Map<String, dynamic> map) =>
      Intervention.fromJson(map);

  factory Intervention.mock({
    String? id,
    String? chantierId,
    String? technicienId,
    String? description,
    DateTime? date,
    String? statut,
    List<PieceJointe>? document,
    String? titre,
    String? commentaire,
  }) => Intervention(
    id: id ?? const Uuid().v4(),
    chantierId: chantierId ?? 'chantier_001',
    technicienId: technicienId ?? 'technicien_001',
    description: description ?? 'Inspection de routine',
    date: date ?? DateTime.now(),
    statut: statut ?? 'Planifiée',
    document:
        document ??
        [
          PieceJointe.mock(
            id: 'pj_001',
            nom: 'document_001.pdf',
            url: 'https://exemple.com/document_001.pdf',
            type: 'pdf',
          ),
          PieceJointe.mock(
            id: 'pj_002',
            nom: 'video_001.mp4',
            url: 'https://exemple.com/video_001.mp4',
            type: 'video',
          ),
          PieceJointe.mock(
            id: 'pj_003',
            nom: 'photo_001.jpg',
            url: 'https://exemple.com/photo_001.jpg',
            type: 'image',
          ),
        ],
    titre: titre ?? 'Inspection',
    commentaire: commentaire ?? 'RAS',
  );

  @override
  Intervention fromJson(Map<String, dynamic> json) => Intervention(
    id: json['id'] ?? '',
    chantierId: json['chantierId'] ?? '',
    technicienId: json['technicienId'] ?? '',
    description: json['description'] ?? '',
    date: DateTime.parse(json['date']),
    statut: json['statut'] ?? '',
    document: json['document'],
    titre: json['titre'],
    commentaire: json['commentaire'],
  );

  @override
  Intervention copyWithId(String? id) => Intervention(
    id: id ?? this.id,
    chantierId: chantierId,
    technicienId: technicienId,
    description: description,
    date: date,
    statut: statut,
    document: document,
    titre: titre,
    commentaire: commentaire,
  );

  @override
  Intervention fromDolibarrJson(Map<String, dynamic> json) {
    return Intervention(
      id: json['id'] ?? '',
      chantierId: json['chantierId'] ?? '',
      technicienId: json['technicienId'] ?? '',
      description: json['description'] ?? '',
      date: DateTime.parse(json['date']),
      statut: json['statut'] ?? '',
      document: json['document'],
      titre: json['titre'],
      commentaire: json['commentaire'],
    );
  }
}
