import 'package:bat_track_v1/data/local/models/pieces_jointes.dart';
import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../../models/data/json_model.dart';

part 'chantier_etapes.g.dart';

@HiveType(typeId: 4)
@JsonSerializable()
class ChantierEtape extends JsonModel {
  @override
  @HiveField(5)
  final String? id;

  @HiveField(6)
  final String? chantierId;

  @HiveField(7)
  final List<PieceJointe>? piecesJointes;

  @HiveField(8)
  final List<String>? timeline;

  @HiveField(0)
  late final String titre;

  @HiveField(1)
  late final String description;

  @HiveField(2)
  final DateTime? dateDebut;

  @HiveField(3)
  final DateTime? dateFin;

  @HiveField(4)
  late final bool terminee;

  ChantierEtape({
    this.id, // Ne pas oublier ici aussi
    required this.titre,
    required this.description,
    this.dateDebut,
    this.dateFin,
    this.terminee = false,
    this.chantierId,
    List<PieceJointe>? piecesJointes,
    this.timeline,
  }) : piecesJointes = piecesJointes ?? [];

  factory ChantierEtape.fromJson(Map<String, dynamic> json) =>
      _$ChantierEtapeFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$ChantierEtapeToJson(this);

  @override
  ChantierEtape fromJson(Map<String, dynamic> json) =>
      ChantierEtape.fromJson(json);

  @override
  ChantierEtape copyWithId(String? id) => ChantierEtape(
    id: id,
    titre: titre,
    description: description,
    dateDebut: dateDebut,
    dateFin: dateFin,
    terminee: terminee,
    chantierId: chantierId,
    piecesJointes: piecesJointes,
    timeline: timeline,
  );

  ChantierEtape copyWith({
    String? titre,
    String? description,
    bool? terminee,
    DateTime? dateDebut,
    DateTime? dateFin,
    List<PieceJointe>? piecesJointes,
    List<String>? timeline,
  }) {
    return ChantierEtape(
      id: id,
      chantierId: chantierId,
      titre: titre ?? this.titre,
      description: description ?? this.description,
      terminee: terminee ?? this.terminee,
      dateDebut: dateDebut ?? this.dateDebut,
      dateFin: dateFin ?? this.dateFin,
      piecesJointes: piecesJointes ?? this.piecesJointes,
      timeline: timeline ?? this.timeline,
    );
  }

  factory ChantierEtape.mock({
    String? id,
    String titre = 'Étape exemple',
    String? description,
    DateTime? dateDebut,
    DateTime? dateFin,
    bool terminee = false,
    String? chantierId,
    List<PieceJointe>? piecesJointes,
    List<String>? timeline,
  }) {
    return ChantierEtape(
      id: id ?? 'mock_etape_001',
      chantierId: chantierId ?? 'mock_chantier_001',
      titre: titre,
      description: description ?? 'Description de l\'étape pour test',
      dateDebut: dateDebut ?? DateTime.now(),
      dateFin: dateFin ?? DateTime.now().add(const Duration(days: 2)),
      terminee: terminee,
      piecesJointes:
          piecesJointes ??
          [
            PieceJointe.mock(
              id: 'pj_001',
              nom: 'plan.pdf',
              url: 'https://exemple.com/plan.pdf',
              type: 'pdf',
            ),
            PieceJointe.mock(
              id: 'pj_002',
              nom: 'photo_chantier.jpg',
              url: 'https://exemple.com/photo_chantier.jpg',
              type: 'image',
            ),
          ],
      timeline:
          timeline ??
          [
            'Début de l\'étape',
            'Installation matériel',
            'Contrôle qualité',
            'Fin de l\'étape',
          ],
    );
  }
}
