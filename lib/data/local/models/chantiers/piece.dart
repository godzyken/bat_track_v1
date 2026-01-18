import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:uuid/uuid.dart';

import '../../../../features/documents/controllers/generator/calculator.dart';
import '../../../core/unified_model.dart';
import '../extensions/budget_extentions.dart';
import '../index_model_extention.dart';

part 'piece.freezed.dart';
part 'piece.g.dart';

@freezed
class Piece
    with _$Piece, AccessControlMixin, ValidationMixin
    implements UnifiedModel {
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
    @Default(false) bool clientValide,
    @Default(false) bool chefDeProjetValide,
    @Default(false) bool techniciensValides,
    @Default(false) bool superUtilisateurValide,

    @Default(false) bool isCloudOnly,
  }) = _Piece;

  /// Factory JSON corrigée pour forcer la présence de 'id'
  @override
  factory Piece.fromJson(Map<String, dynamic> json) => _$PieceFromJson(json);

  factory Piece.mock() => Piece(
    id: const Uuid().v4(),
    nom: 'Cuisine',
    surface: 32.60,
    addedBy: 'Sarl Company Dugazon',
  );

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
  // TODO: implement addedBy
  String get addedBy => throw UnimplementedError();

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
  // TODO: implement mainOeuvre
  List<MainOeuvre>? get mainOeuvre => throw UnimplementedError();

  @override
  // TODO: implement materiaux
  List<Materiau>? get materiaux => throw UnimplementedError();

  @override
  // TODO: implement materiels
  List<Materiel>? get materiels => throw UnimplementedError();

  @override
  // TODO: implement nom
  String get nom => throw UnimplementedError();

  @override
  // TODO: implement ownerId
  String? get ownerId => throw UnimplementedError();

  @override
  // TODO: implement superUtilisateurValide
  bool get superUtilisateurValide => throw UnimplementedError();

  @override
  // TODO: implement surface
  double get surface => throw UnimplementedError();

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
  // TODO: implement validatedByTech
  bool? get validatedByTech => throw UnimplementedError();
}
