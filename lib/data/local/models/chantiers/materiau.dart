import 'package:bat_track_v1/data/local/models/base/has_acces_control.dart';
import 'package:bat_track_v1/models/data/json_model.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../utilisateurs/app_user.dart';

part 'materiau.freezed.dart';
part 'materiau.g.dart';

@freezed
class Materiau
    with _$Materiau, JsonModel<Materiau>
    implements HasAccessControl, JsonSerializableModel<Materiau> {
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
  bool canAccess(AppUser user) {
    return true;
  }

  @override
  bool get isUpdated => updatedAt != null;
}
