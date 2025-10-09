import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:uuid/uuid.dart';

import '../../../core/unified_model.dart';

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
  @override
  UnifiedModel copyWithId(String newId) => copyWith(id: newId);
}
