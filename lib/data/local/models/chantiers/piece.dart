import 'package:bat_track_v1/data/local/models/base/has_acces_control.dart';
import 'package:bat_track_v1/models/data/json_model.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:uuid/uuid.dart';

import '../../../../features/documents/controllers/generator/calculator.dart';
import '../index_model_extention.dart';

part 'piece.freezed.dart';
part 'piece.g.dart';

@freezed
class Piece
    with _$Piece, JsonModel<Piece>
    implements JsonSerializableModel, HasAccessControl {
  const Piece._();

  const factory Piece({
    required String id,
    required String nom,
    required double surface,
    required String addedBy,
    List<Materiau>? materiaux,
    List<Materiel>? materiels,
    List<MainOeuvre>? mainOeuvre,
    DateTime? updatedAt,
    bool? validatedByTech,
  }) = _Piece;

  /// Factory JSON corrigée pour forcer la présence de 'id'
  factory Piece.fromJson(Map<String, dynamic> json) => _$PieceFromJson(json);

  factory Piece.mock() => Piece(
    id: const Uuid().v4(),
    nom: 'Cuisine',
    surface: 32.60,
    addedBy: 'Sarl Company Dugazon',
  );

  @override
  bool canAccess(AppUser user) {
    if (user.isAdmin) return true;
    if (user.isClient) return addedBy == user.uid;
    if (user.isTechnicien) return mainOeuvre!.contains(user.uid);
    return false;
  }

  double getBudgetTotal(List<Technicien> techniciens) {
    return BudgetGen.calculerTotalMulti(
      surface: surface,
      materiaux: materiaux ?? [],
      materiels: materiels ?? [],
      mainOeuvre: mainOeuvre ?? [],
      techniciens: techniciens,
    );
  }

  double getBudgetTotalSansMainOeuvre() {
    return BudgetGen.calculerTotalPartielSansMainOeuvre(
      surface: surface,
      materiaux: materiaux!,
      materiels: materiels!,
    );
  }

  Map<String, double> getBudgetRepartition(List<Technicien> techniciens) {
    const labelMateriaux = 'Matériaux';
    const labelMateriel = 'Matériel';
    const labelMainOeuvre = 'Main d’œuvre';

    final mat = materiaux?.fold(0.0, (s, m) => s + m.prixTotal) ?? 0;
    final matl = materiels?.fold(0.0, (s, m) => s + m.prixTotal) ?? 0;
    final mo =
        mainOeuvre?.fold(
          0.0,
          (s, m) =>
              s +
              m.heuresEstimees *
                  (techniciens
                      .firstWhere(
                        (t) => t.id == m.idTechnicien,
                        orElse: () => Technicien.mock(),
                      )
                      .tauxHoraire),
        ) ??
        0;

    final total = mat + matl + mo;
    if (total == 0) return {};

    return {labelMateriaux: mat, labelMateriel: matl, labelMainOeuvre: mo};
  }

  Map<String, double> getBudgetRatio(List<Technicien> techniciens) {
    final repartition = getBudgetRepartition(techniciens);
    final total = repartition.values.fold(0.0, (a, b) => a + b);
    if (total == 0) return {};

    return repartition.map((k, v) => MapEntry(k, v / total));
  }
}
