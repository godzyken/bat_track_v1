import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shared_models/shared_models.dart';
import 'package:uuid/uuid.dart';

import '../extensions/budget_extentions.dart';

part 'materiel.freezed.dart';
part 'materiel.g.dart';

@freezed
sealed class Materiel extends UnifiedModel with _$Materiel {
  Materiel._();

  factory Materiel({
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
  String? get ownerId => id;

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
