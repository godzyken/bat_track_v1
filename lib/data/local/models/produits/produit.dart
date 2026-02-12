import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shared_models/shared_models.dart';
import 'package:uuid/uuid.dart';

import '../extensions/budget_extentions.dart';

part 'produit.freezed.dart';
part 'produit.g.dart';

@freezed
class Produit
    with _$Produit, AccessControlMixin, ValidationMixin
    implements UnifiedModel {
  const Produit._();

  const factory Produit({
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

  @override
  // TODO: implement caracteristiques
  Map<String, dynamic>? get caracteristiques =>
      (this as _Produit).caracteristiques;

  @override
  // TODO: implement categorie
  String get categorie => (this as _Produit).categorie;

  @override
  // TODO: implement certifications
  List<String>? get certifications => (this as _Produit).certifications;

  @override
  // TODO: implement consommationEnergetique
  double? get consommationEnergetique =>
      (this as _Produit).consommationEnergetique;

  @override
  // TODO: implement coutMaintenanceAnnuel
  double? get coutMaintenanceAnnuel => (this as _Produit).coutMaintenanceAnnuel;

  @override
  // TODO: implement createdAt
  DateTime? get createdAt => (this as _Produit).createdAt;

  @override
  // TODO: implement createdBy
  String? get createdBy => (this as _Produit).createdBy;

  @override
  // TODO: implement description
  String? get description => (this as _Produit).description;

  @override
  // TODO: implement dureeVieEstimee
  double? get dureeVieEstimee => (this as _Produit).dureeVieEstimee;

  @override
  // TODO: implement fabricant
  String? get fabricant => (this as _Produit).fabricant;

  @override
  // TODO: implement fournisseur
  String? get fournisseur => (this as _Produit).fournisseur;

  @override
  // TODO: implement googleSheetsId
  String? get googleSheetsId => (this as _Produit).googleSheetsId;

  @override
  // TODO: implement googleSheetsRow
  int? get googleSheetsRow => (this as _Produit).googleSheetsRow;

  @override
  // TODO: implement id
  String get id => (this as _Produit).id;

  @override
  // TODO: implement impactCarbone
  double? get impactCarbone => (this as _Produit).impactCarbone;

  @override
  // TODO: implement isCloudOnly
  bool get isCloudOnly => (this as _Produit).isCloudOnly;

  @override
  // TODO: implement nom
  String get nom => (this as _Produit).nom;

  @override
  // TODO: implement normes
  List<String>? get normes => (this as _Produit).normes;

  @override
  // TODO: implement prixUnitaire
  double get prixUnitaire => (this as _Produit).prixUnitaire;

  @override
  // TODO: implement quantiteStock
  int? get quantiteStock => (this as _Produit).quantiteStock;

  @override
  // TODO: implement reference
  String? get reference => (this as _Produit).reference;

  @override
  // TODO: implement seuilAlerte
  int? get seuilAlerte => (this as _Produit).seuilAlerte;

  @override
  // TODO: implement tauxTVA
  double? get tauxTVA => (this as _Produit).tauxTVA;

  @override
  bool get techValide => (this as _Produit).techValide;

  @override
  String? get unite => (this as _Produit).unite;

  @override
  DateTime? get updatedAt => (this as _Produit).updatedAt;
}
