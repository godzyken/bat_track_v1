import 'package:bat_track_v1/models/data/json_model.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'materiau.freezed.dart';
part 'materiau.g.dart';

@freezed
class Materiau
    with _$Materiau, JsonModel<Materiau>, JsonSerializableModel<Materiau> {
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

  /*  @override
  Materiau fromJson(Map<String, dynamic> json) => Materiau.fromJson(json);

  @override
  Map<String, dynamic> toJson() => _$MateriauToJson(this);

  @override
  Materiau copyWithId(String? id) => copyWith(id: id ?? this.id);*/

  factory Materiau.mock() => Materiau(
    id: 'matId_003',
    nom: 'Poutre IPN 100: 3 metres',
    prixUnitaire: 134.14,
    unite: 'm',
    quantiteFixe: 5,
  );
}
