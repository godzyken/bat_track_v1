import 'package:bat_track_v1/data/local/models/index_model_extention.dart';
import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../../models/data/json_model.dart';

part 'chantier_etapes.g.dart';

@HiveType(typeId: 4)
@JsonSerializable()
class ChantierEtape extends JsonModel {
  @override
  @HiveField(0)
  final String? id;

  @HiveField(1)
  final String? chantierId;

  @HiveField(2)
  final List<PieceJointe>? piecesJointes;

  @HiveField(3)
  final List<String>? timeline;

  @HiveField(4)
  late final String titre;

  @HiveField(5)
  late final String description;

  @HiveField(6)
  final DateTime? dateDebut;

  @HiveField(7)
  final DateTime? dateFin;

  @HiveField(8)
  final bool terminee;

  @HiveField(9)
  double? budget;

  @HiveField(10)
  final List<Piece> pieces;

  @HiveField(11)
  final int ordre;

  ChantierEtape({
    this.id, // Ne pas oublier ici aussi
    required this.titre,
    required this.description,
    this.dateDebut,
    this.dateFin,
    this.terminee = false,
    this.chantierId,
    this.piecesJointes = const [],
    this.timeline,
    this.budget,
    this.pieces = const [],
    this.ordre = 0,
  });

  factory ChantierEtape.fromJson(Map<String, dynamic> json) =>
      _$ChantierEtapeFromJson(json);

  @override
  Map<String, dynamic> toJson() {
    final json = _$ChantierEtapeToJson(this);
    // s'assurer que piecesJointes est une liste de maps
    json['pieces'] = pieces.map((p) => p.toJson()).toList();
    json['piecesJointes'] = piecesJointes?.map((pj) => pj.toJson()).toList();
    return json;
  }

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
    budget: budget,
    pieces: pieces,
    ordre: ordre,
  );

  ChantierEtape copyWith({
    String? id,
    String? chantierId,
    String? titre,
    String? description,
    bool? terminee,
    DateTime? dateDebut,
    DateTime? dateFin,
    List<PieceJointe>? piecesJointes,
    List<String>? timeline,
    double? budget,
    List<Piece>? pieces,
    int? ordre,
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
      budget: budget ?? this.budget,
      pieces: pieces ?? this.pieces,
      ordre: ordre ?? this.ordre,
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
    double? budget,
    List<Piece>? pieces,
    int? ordre,
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
              nom: 'construction_4.O.pdf',
              url:
                  'https://thewiw.com/wp-content/uploads/2019/02/building-BIM.jpg',
              type: 'image',
            ),
            PieceJointe.mock(
              id: 'pj_003',
              nom: 'photo_chantier.jpg',
              url:
                  'https://media.istockphoto.com/id/1316314394/fr/photo/client-avec-architecte-%C3%A9valuant-les-travaux-%C3%A0-lint%C3%A9rieur-dun-chantier-en-construction.jpg?s=1024x1024&w=is&k=20&c=Htegmb0NTdY7gTVId84r1s0qW0iBEtDeZUgvk1Gn4ok=',
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
      budget: budget ?? 10200.0,
      pieces:
          pieces ??
          [
            Piece.mock(
              id: 'p_001',
              nom: 'Salle de bain',
              surfaceM2: 54.00,
              materiels: [Materiel.mock()],
              mainOeuvre: MainOeuvre.mock(),
              materiaux: [Materiau.mock()],
            ),
            Piece.mock(
              id: 'p_002',
              nom: 'Salle de réception',
              surfaceM2: 500.0,
              materiels: [Materiel.mock(), Materiel.mock()],
              mainOeuvre: MainOeuvre.mock(),
              materiaux: [Materiau.mock(), Materiau.mock(), Materiau.mock()],
            ),
            Piece.mock(
              id: 'p_003',
              nom: 'Salon',
              surfaceM2: 20.0,
              materiels: [Materiel.mock()],
              mainOeuvre: MainOeuvre.mock(),
              materiaux: [Materiau.mock()],
            ),
          ],
      ordre: ordre ?? 0,
    );
  }

  @override
  ChantierEtape fromDolibarrJson(Map<String, dynamic> json) {
    return ChantierEtape(
      id: json['id'] ?? '',
      chantierId: json['chantierId'] ?? '',
      titre: json['titre'] ?? '',
      description: json['description'] ?? '',
      dateDebut: DateTime.parse(json['dateDebut']),
      dateFin: DateTime.parse(json['dateFin']),
      terminee: json['terminee'] ?? false,
      piecesJointes: List<PieceJointe>.from(json['piecesJointes']),
      timeline: List<String>.from(json['timeline']),
      budget: json['budget'] ?? 0,
      pieces: List<Piece>.from(json['pieces']),
      ordre: json['ordre'] ?? 0,
    );
  }
}

extension ChantierEtapeBudget on ChantierEtape {
  double getBudgetTotal(List<Technicien> techniciens) {
    return pieces.fold(
      0.0,
      (total, piece) => total + piece.getBudgetTotal(techniciens),
    );
  }
}
