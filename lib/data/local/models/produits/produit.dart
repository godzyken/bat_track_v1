import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shared_models/shared_models.dart';
import 'package:uuid/uuid.dart';

import '../extensions/budget_extentions.dart';

part 'produit.freezed.dart';
part 'produit.g.dart';

@freezed
sealed class Produit extends UnifiedModel with _$Produit {
  Produit._();

  factory Produit({
    required String id,
    required String nom,
    required String categorie,
    String? reference,
    String? fabricant,
    String? description,
    // Donnees techniques
    Map<String, dynamic>? caracteristiques,
    // Donnees financieres
    required double prixUnitaire,
    String? unite,
    // Piece m2
    double? tauxTVA,
    // KPIs depuis Google Sheets
    double? dureeVieEstimee,
    double? coutMaintenanceAnnuel,
    double? consommationEnergetique,
    double? impactCarbone,
    // Certification et normes
    List<String>? certifications,
    List<String>? normes,
    // Gestion stock (optionnel)
    int? quantiteStock,
    int? seuilAlerte,
    String? fournisseur,
    // Metadonnees
    @NullableDateTimeIsoConverter() DateTime? updatedAt,
    @NullableDateTimeIsoConverter() DateTime? createdAt,
    String? createdBy,
    // Validation
    @Default(false) bool clientValide,
    @Default(false) bool chefDeProjetValide,
    @Default(false) bool techValide,
    @Default(false) bool superUtilisateurValide,
    @Default(false) bool isCloudOnly,
    // Source des donnees
    String? googleSheetsId,
    int? googleSheetsRow,
  }) = _Produit;

  factory Produit.fromJson(Map<String, dynamic> json) =>
      _$ProduitFromJson(json);

  factory Produit.mock() => Produit(
    id: const Uuid().v4(),
    nom: 'Detecteur de fumee',
    categorie: 'S\u00e9curit\u00e9 incendie',
    reference: 'DF-2024-001',
    fabricant: 'SafetyTech',
    prixUnitaire: 45.90,
    unite: 'pi\u00e8ce',
    tauxTVA: 20.0,
    dureeVieEstimee: 10.0,
    coutMaintenanceAnnuel: 5.0,
    certifications: ['NF', 'CE'],
    normes: ['EN 14604'],
    createdAt: DateTime.now(),
  );

  /// Calcul du coût total sur la durée de vie
  double get coutTotalVie {
    if (dureeVieEstimee == null) return prixUnitaire;
    final maintenance = (coutMaintenanceAnnuel ?? 0) * dureeVieEstimee!;
    return prixUnitaire + maintenance;
  }

  /// Calcul du co\u00fbt annualis\u00e9\n
  double get coutAnnualise {
    if (dureeVieEstimee == null || dureeVieEstimee == 0) return prixUnitaire;

    return coutTotalVie / dureeVieEstimee!;
  }

  @override
  String? get ownerId => createdBy;

  @override
  bool get techniciensValides => techValide;

  @override
  bool get isUpdated => updatedAt != null;

  @override
  UnifiedModel copyWithId(String newId) => copyWith(id: newId);

  @override
  bool get toutesPartiesOntValide => ValidationHelper.computeValidationStatus(
    clientValide: clientValide,
    chefDeProjetValide: chefDeProjetValide,
    techniciensValides: techValide,
    superUtilisateurValide: superUtilisateurValide,
  );
}
