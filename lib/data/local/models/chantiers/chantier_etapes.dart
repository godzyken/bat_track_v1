import 'package:bat_track_v1/data/local/models/extensions/budget_extentions.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:uuid/uuid.dart';

import '../../../core/unified_model.dart';
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

  @override
  // TODO: implement budget
  double? get budget => throw UnimplementedError();

  @override
  bool canDelete(AppUser user) {
    // TODO: implement canDelete
    throw UnimplementedError();
  }

  @override
  bool canEdit(AppUser user) {
    // TODO: implement canEdit
    throw UnimplementedError();
  }

  @override
  bool canMerge(AppUser user) {
    // TODO: implement canMerge
    throw UnimplementedError();
  }

  @override
  bool canRead(AppUser user) {
    // TODO: implement canRead
    throw UnimplementedError();
  }

  @override
  // TODO: implement chantierId
  String get chantierId => throw UnimplementedError();

  @override
  // TODO: implement chefDeProjetValide
  bool get chefDeProjetValide => throw UnimplementedError();

  @override
  // TODO: implement clientValide
  bool get clientValide => throw UnimplementedError();

  @override
  // TODO: implement dateDebut
  DateTime get dateDebut => throw UnimplementedError();

  @override
  // TODO: implement dateFin
  DateTime get dateFin => throw UnimplementedError();

  @override
  // TODO: implement description
  String get description => throw UnimplementedError();

  @override
  // TODO: implement id
  String get id => throw UnimplementedError();

  @override
  // TODO: implement isCloudOnly
  bool get isCloudOnly => throw UnimplementedError();

  @override
  // TODO: implement ordre
  int get ordre => throw UnimplementedError();

  @override
  // TODO: implement pieces
  List<Piece> get pieces => throw UnimplementedError();

  @override
  // TODO: implement piecesJointes
  List<PieceJointe> get piecesJointes => throw UnimplementedError();

  @override
  // TODO: implement statut
  String get statut => throw UnimplementedError();

  @override
  // TODO: implement superUtilisateurValide
  bool get superUtilisateurValide => throw UnimplementedError();

  @override
  // TODO: implement techniciens
  List<String>? get techniciens => throw UnimplementedError();

  @override
  // TODO: implement techniciensValides
  bool get techniciensValides => throw UnimplementedError();

  @override
  // TODO: implement terminee
  bool get terminee => throw UnimplementedError();

  @override
  // TODO: implement timeline
  List<String>? get timeline => throw UnimplementedError();

  @override
  // TODO: implement titre
  String get titre => throw UnimplementedError();

  @override
  Map<String, dynamic> toJson() {
    // TODO: implement toJson
    throw UnimplementedError();
  }

  @override
  // TODO: implement updatedAt
  DateTime? get updatedAt => throw UnimplementedError();
}
