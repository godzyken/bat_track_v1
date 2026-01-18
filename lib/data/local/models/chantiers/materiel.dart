import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:uuid/uuid.dart';

import '../../../core/unified_model.dart';
import '../extensions/budget_extentions.dart';

part 'materiel.freezed.dart';
part 'materiel.g.dart';

@freezed
class Materiel
    with _$Materiel, AccessControlMixin, ValidationMixin
    implements UnifiedModel {
  const Materiel._();

  const factory Materiel({
    required String id,
    required String nom,
    required double prixUnitaire,
    required double quantiteFixe,
    double? joursLocation,
    double? prixLocation,
    DateTime? updatedAt,
    @Default(false) bool clientValide,
    @Default(false) bool chefDeProjetValide,
    @Default(false) bool techniciensValides,
    @Default(false) bool superUtilisateurValide,

    @Default(false) bool isCloudOnly,
  }) = _Materiel;

  @override
  factory Materiel.fromJson(Map<String, dynamic> json) =>
      _$MaterielFromJson(json);

  factory Materiel.mock() => Materiel(
    id: const Uuid().v4(),
    nom: 'Mini-Pelle',
    prixUnitaire: 15000,
    quantiteFixe: 1,
  );

  double get prixTotal => prixUnitaire * quantiteFixe;

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
  // TODO: implement id
  String get id => throw UnimplementedError();

  @override
  // TODO: implement isCloudOnly
  bool get isCloudOnly => throw UnimplementedError();

  @override
  // TODO: implement joursLocation
  double? get joursLocation => throw UnimplementedError();

  @override
  // TODO: implement nom
  String get nom => throw UnimplementedError();

  @override
  // TODO: implement prixLocation
  double? get prixLocation => throw UnimplementedError();

  @override
  // TODO: implement prixUnitaire
  double get prixUnitaire => throw UnimplementedError();

  @override
  // TODO: implement quantiteFixe
  double get quantiteFixe => throw UnimplementedError();

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
