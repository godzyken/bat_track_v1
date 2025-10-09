import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:uuid/uuid.dart';

import '../../../core/unified_model.dart';
import '../index_model_extention.dart';

part 'chantier_etapes.freezed.dart';
part 'chantier_etapes.g.dart';

@freezed
class ChantierEtape
    with _$ChantierEtape, AccessControlMixin, ValidationMixin
    implements UnifiedModel {
  const ChantierEtape._();

  const factory ChantierEtape({
    required String id,
    required String chantierId,
    required List<PieceJointe> piecesJointes,
    List<String>? timeline,
    required String titre,
    required String description,
    @DateTimeIsoConverter() required DateTime dateDebut,
    @DateTimeIsoConverter() required DateTime dateFin,
    required bool terminee,
    double? budget,
    required List<Piece> pieces,
    required int ordre,
    @NullableDateTimeIsoConverter() DateTime? updatedAt,
    required String statut,
    List<String>? techniciens,
  }) = _ChantierEtape;

  @override
  factory ChantierEtape.fromJson(Map<String, dynamic> json) =>
      _$ChantierEtapeFromJson(json);

  factory ChantierEtape.mock() => ChantierEtape(
    id: const Uuid().v4(),
    chantierId: 'chId_006',
    piecesJointes: [PieceJointe.mock(), PieceJointe.mock()],
    titre: 'Parvis',
    description: 'Aggrandissement de la piece principale',
    dateDebut: DateTime.now(),
    dateFin: DateTime.now().add(Duration(days: 19)),
    terminee: false,
    pieces: [Piece.mock(), Piece.mock()],
    ordre: 2,
    statut: 'A Faire',
  );

  @override
  bool get isUpdated => updatedAt != null;

  @override
  UnifiedModel copyWithId(String newId) => copyWith(id: newId);
}
