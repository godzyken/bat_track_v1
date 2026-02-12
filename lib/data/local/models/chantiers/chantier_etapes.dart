import 'package:bat_track_v1/data/local/models/extensions/budget_extentions.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shared_models/core/models/public_model.dart';
import 'package:shared_models/core/models/unified_model.dart';
import 'package:uuid/uuid.dart';

import '../index_model_extention.dart';

part 'chantier_etapes.freezed.dart';
part 'chantier_etapes.g.dart';

@freezed
class ChantierEtape
    with _$ChantierEtape
    implements UnifiedModel, AccessControlMixin, ValidationMixin {
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
    @Default(false) bool clientValide,
    @Default(false) bool chefDeProjetValide,
    @Default(false) bool techniciensValides,
    @Default(false) bool superUtilisateurValide,

    @Default(false) bool isCloudOnly,
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
    clientValide: true,
    chefDeProjetValide: true,
  );

  // 🔹 Getters concrets pour les mixins
  @override
  String? get ownerId => chantierId; // ou autre propriétaire logique
  @override
  List<String> get assignedUserIds => techniciens ?? [];

  @override
  bool get isUpdated => updatedAt != null;

  @override
  UnifiedModel copyWithId(String newId) => copyWith(id: newId);

  @override
  bool get toutesPartiesOntValide => ValidationHelper.computeValidationStatus(
    clientValide: clientValide,
    chefDeProjetValide: chefDeProjetValide,
    techniciensValides: techniciensValides,
    superUtilisateurValide: superUtilisateurValide,
  );
}
