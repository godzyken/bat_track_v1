import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shared_models/shared_models.dart';

import '../extensions/budget_extentions.dart';

part 'main_oeuvre.freezed.dart';
part 'main_oeuvre.g.dart';

@freezed
sealed class MainOeuvre extends UnifiedModel with _$MainOeuvre {
  MainOeuvre._();

  factory MainOeuvre({
    required String id,
    required String chantierId,
    required String idTechnicien,
    required double heuresEstimees,
    @DateTimeIsoConverter() required DateTime dateDebut,
    @NullableDateTimeIsoConverter() DateTime? passedTime,
    @NullableDateTimeIsoConverter() DateTime? updatedAt,
    @Default(false) bool isActive,
    @Default(false) bool clientValide,
    @Default(false) bool chefDeProjetValide,
    @Default(false) bool techniciensValides,
    @Default(false) bool superUtilisateurValide,

    @Default(false) bool isCloudOnly,
  }) = _MainOeuvre;

  /// JSON local
  @override
  factory MainOeuvre.fromJson(Map<String, dynamic> json) =>
      _$MainOeuvreFromJson(json);

  factory MainOeuvre.mock() => MainOeuvre(
    id: 'moId_0012',
    chantierId: 'ch_023',
    idTechnicien: 'tec_0023',
    heuresEstimees: 35,
    dateDebut: DateTime.now(),
    isActive: true,
  );

  @override
  bool get isUpdated => updatedAt != null;

  /// 🔹 Correction 1 : Implémentation du getter requis par AccessControlMixin
  @override
  String get ownerId => idTechnicien;

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
