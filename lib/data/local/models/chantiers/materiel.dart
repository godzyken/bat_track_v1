import 'package:bat_track_v1/models/data/json_model.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:uuid/uuid.dart';

part 'materiel.freezed.dart';
part 'materiel.g.dart';

@freezed
class Materiel
    with _$Materiel, JsonModel<Materiel>, JsonSerializableModel<Materiel> {
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

  double get prixTotal {
    final q = quantiteFixe;
    return prixUnitaire * q;
  }

  factory Materiel.fromJson(Map<String, dynamic> json) =>
      _$MaterielFromJson(json);

  factory Materiel.mock() => Materiel(
    id: const Uuid().v4(),
    nom: 'Mini-Pelle',
    prixUnitaire: 15000,
    quantiteFixe: 1,
  );
}
