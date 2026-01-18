import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../core/unified_model.dart';
import '../extensions/budget_extentions.dart';

part 'main_oeuvre.freezed.dart';
part 'main_oeuvre.g.dart';

@freezed
class MainOeuvre
    with _$MainOeuvre, AccessControlMixin, ValidationMixin
    implements UnifiedModel {
  const MainOeuvre._();

  const factory MainOeuvre({
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
  // TODO: implement dateDebut
  DateTime get dateDebut => throw UnimplementedError();

  @override
  // TODO: implement heuresEstimees
  double get heuresEstimees => throw UnimplementedError();

  @override
  // TODO: implement id
  String get id => throw UnimplementedError();

  @override
  // TODO: implement idTechnicien
  String get idTechnicien => throw UnimplementedError();

  @override
  // TODO: implement isActive
  bool get isActive => throw UnimplementedError();

  @override
  // TODO: implement isCloudOnly
  bool get isCloudOnly => throw UnimplementedError();

  @override
  // TODO: implement passedTime
  DateTime? get passedTime => throw UnimplementedError();

  @override
  // TODO: implement superUtilisateurValide
  bool get superUtilisateurValide => throw UnimplementedError();

  @override
  // TODO: implement techniciensValides
  bool get techniciensValides => throw UnimplementedError();

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
