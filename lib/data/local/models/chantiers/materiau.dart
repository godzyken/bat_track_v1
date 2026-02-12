import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shared_models/shared_models.dart';

import '../extensions/budget_extentions.dart';

part 'materiau.freezed.dart';
part 'materiau.g.dart';

@freezed
class Materiau
    with _$Materiau, AccessControlMixin, ValidationMixin
    implements UnifiedModel {
  const factory Materiau({
    required String id,
    required String nom,
    required double prixUnitaire,
    required String unite,
    double? coefficientSurface,
    double? quantiteFixe,
    DateTime? updatedAt,
    @Default(false) bool clientValide,
    @Default(false) bool chefDeProjetValide,
    @Default(false) bool techniciensValides,
    @Default(false) bool superUtilisateurValide,

    @Default(false) bool isCloudOnly,
  }) = _Materiau;

  const Materiau._();

  double get prixTotal {
    final q = quantiteFixe ?? 0;
    return prixUnitaire * q;
  }

  @override
  factory Materiau.fromJson(Map<String, dynamic> json) =>
      _$MateriauFromJson(json);

  factory Materiau.mock() => Materiau(
    id: 'matId_003',
    nom: 'Poutre IPN 100: 3 metres',
    prixUnitaire: 134.14,
    unite: 'm',
    quantiteFixe: 5,
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
  // TODO: implement chefDeProjetValide
  bool get chefDeProjetValide => throw UnimplementedError();

  @override
  // TODO: implement clientValide
  bool get clientValide => throw UnimplementedError();

  @override
  // TODO: implement coefficientSurface
  double? get coefficientSurface => throw UnimplementedError();

  @override
  // TODO: implement id
  String get id => throw UnimplementedError();

  @override
  // TODO: implement isCloudOnly
  bool get isCloudOnly => throw UnimplementedError();

  @override
  // TODO: implement nom
  String get nom => throw UnimplementedError();

  @override
  // TODO: implement prixUnitaire
  double get prixUnitaire => throw UnimplementedError();

  @override
  // TODO: implement quantiteFixe
  double? get quantiteFixe => throw UnimplementedError();

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
  // TODO: implement unite
  String get unite => throw UnimplementedError();

  @override
  // TODO: implement updatedAt
  DateTime? get updatedAt => throw UnimplementedError();

  @override
  // TODO: implement ownerId
  String? get ownerId => throw UnimplementedError();
}
