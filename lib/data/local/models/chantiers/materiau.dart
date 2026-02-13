import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shared_models/shared_models.dart';

import '../extensions/budget_extentions.dart';

part 'materiau.freezed.dart';
part 'materiau.g.dart';

@freezed
sealed class Materiau extends UnifiedModel with _$Materiau {
  factory Materiau({
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

  Materiau._();

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

  /// 🔹 Correction 1 : Implémentation du getter requis par AccessControlMixin
  @override
  String get ownerId => id;

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
