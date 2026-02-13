import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shared_models/shared_models.dart';
import 'package:uuid/uuid.dart';

import '../extensions/budget_extentions.dart';
import '../index_model_extention.dart';

part 'intervention.freezed.dart';
part 'intervention.g.dart';

@freezed
sealed class Intervention extends UnifiedModel with _$Intervention {
  Intervention._();

  factory Intervention({
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

  /// 🔹 Correction 1 : Implémentation du getter requis par AccessControlMixin
  @override
  String get ownerId => chantierId;

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
