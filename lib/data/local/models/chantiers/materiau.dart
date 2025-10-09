import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../core/unified_model.dart';

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
  @override
  UnifiedModel copyWithId(String newId) => copyWith(id: newId);
}
