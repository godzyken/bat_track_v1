import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:uuid/uuid.dart';

import '../../../core/unified_model.dart';
import '../extensions/budget_extentions.dart';
import '../index_model_extention.dart';

part 'intervention.freezed.dart';
part 'intervention.g.dart';

@freezed
class Intervention
    with _$Intervention, AccessControlMixin, ValidationMixin
    implements UnifiedModel {
  const Intervention._();

  const factory Intervention({
    required String id,
    required String chantierId,
    required String technicienId,
    required String company,
    required String description,
    @DateTimeIsoConverter() required DateTime create,
    @NullableDateTimeIsoConverter() DateTime? datePassed,
    required String statut,
    required List<PieceJointe> document,
    String? titre,
    String? commentaire,
    FactureDraft? facture,
    @NullableDateTimeIsoConverter() DateTime? updatedAt,
    int? count,
    @Default(false) bool clientValide,
    @Default(false) bool chefDeProjetValide,
    @Default(false) bool techniciensValides,
    @Default(false) bool superUtilisateurValide,

    @Default(false) bool isCloudOnly,
  }) = _Intervention;

  @override
  factory Intervention.fromJson(Map<String, dynamic> json) =>
      _$InterventionFromJson(json);

  factory Intervention.mock() => Intervention(
    id: const Uuid().v4(),
    chantierId: 'chId_006',
    technicienId: 'tId_0056',
    company: 'Kréol',
    description: 'Depose du murre coté baie',
    create: DateTime.now(),
    statut: 'En Cours',
    document: [PieceJointe.mock(), PieceJointe.mock()],
  );

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
  // TODO: implement chantierId
  String get chantierId => throw UnimplementedError();

  @override
  // TODO: implement chefDeProjetValide
  bool get chefDeProjetValide => throw UnimplementedError();

  @override
  // TODO: implement clientValide
  bool get clientValide => throw UnimplementedError();

  @override
  // TODO: implement commentaire
  String? get commentaire => throw UnimplementedError();

  @override
  // TODO: implement company
  String get company => throw UnimplementedError();

  @override
  // TODO: implement count
  int? get count => throw UnimplementedError();

  @override
  // TODO: implement create
  DateTime get create => throw UnimplementedError();

  @override
  // TODO: implement datePassed
  DateTime? get datePassed => throw UnimplementedError();

  @override
  // TODO: implement description
  String get description => throw UnimplementedError();

  @override
  // TODO: implement document
  List<PieceJointe> get document => throw UnimplementedError();

  @override
  // TODO: implement facture
  FactureDraft? get facture => throw UnimplementedError();

  @override
  // TODO: implement id
  String get id => throw UnimplementedError();

  @override
  // TODO: implement isCloudOnly
  bool get isCloudOnly => throw UnimplementedError();

  @override
  // TODO: implement statut
  String get statut => throw UnimplementedError();

  @override
  // TODO: implement superUtilisateurValide
  bool get superUtilisateurValide => throw UnimplementedError();

  @override
  // TODO: implement technicienId
  String get technicienId => throw UnimplementedError();

  @override
  // TODO: implement techniciensValides
  bool get techniciensValides => throw UnimplementedError();

  @override
  // TODO: implement titre
  String? get titre => throw UnimplementedError();

  @override
  Map<String, dynamic> toJson() {
    // TODO: implement toJson
    throw UnimplementedError();
  }

  @override
  // TODO: implement updatedAt
  DateTime? get updatedAt => throw UnimplementedError();

  @override
  // TODO: implement ownerId
  String? get ownerId => throw UnimplementedError();
}
