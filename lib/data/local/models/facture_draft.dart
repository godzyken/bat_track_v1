import 'dart:convert';
import 'dart:typed_data';

import 'package:hive/hive.dart';

import '../../../models/data/json_model.dart';

part 'facture_draft.g.dart';

@HiveType(typeId: 99)
class FactureDraft extends HiveObject implements JsonModel<FactureDraft> {
  @HiveField(0)
  final String chantierId;

  @HiveField(1)
  final List<CustomLigneFacture> lignesManuelles;

  @HiveField(2)
  final Uint8List? signature;

  @HiveField(3)
  final bool isFinalized;

  @HiveField(4)
  final String? factureId;

  @HiveField(5)
  DateTime dateDerniereModification;

  @HiveField(6)
  final double? remise; // en euros

  @HiveField(7)
  final double? tauxTVA; // en pourcentage (ex: 20.0)

  FactureDraft({
    required this.chantierId,
    this.lignesManuelles = const [],
    this.signature,
    this.isFinalized = false,
    this.factureId,
    DateTime? dateDerniereModification,
    this.remise,
    this.tauxTVA,
  }) : dateDerniereModification = dateDerniereModification ?? DateTime.now();

  // --- Getters utiles ---
  double get totalHT =>
      lignesManuelles.fold(0.0, (sum, ligne) => sum + ligne.montant);

  double get remiseAmount => remise ?? 0;

  double get totalApresRemise => totalHT - remiseAmount;

  double get tvaAmount =>
      tauxTVA != null ? totalApresRemise * (tauxTVA! / 100.0) : 0;

  double get totalTTC => totalApresRemise + tvaAmount;

  // --- JsonModel ---
  @override
  String? get id => chantierId;

  @override
  set updatedAt(DateTime? date) {
    if (date != null) {
      dateDerniereModification = date;
    }
  }

  @override
  DateTime? get updatedAt => dateDerniereModification;

  @override
  FactureDraft copyWithId(String? id) => copyWith(chantierId: id ?? chantierId);

  FactureDraft copyWith({
    String? chantierId,
    List<CustomLigneFacture>? lignesManuelles,
    Uint8List? signature,
    bool? isFinalized,
    String? factureId,
    DateTime? dateDerniereModification,
    double? remise,
    double? tauxTVA,
  }) {
    return FactureDraft(
      chantierId: chantierId ?? this.chantierId,
      lignesManuelles: lignesManuelles ?? this.lignesManuelles,
      signature: signature ?? this.signature,
      isFinalized: isFinalized ?? this.isFinalized,
      factureId: factureId ?? this.factureId,
      dateDerniereModification:
          dateDerniereModification ?? this.dateDerniereModification,
      remise: remise ?? this.remise,
      tauxTVA: tauxTVA ?? this.tauxTVA,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'chantierId': chantierId,
    'lignesManuelles': lignesManuelles.map((e) => e.toJson()).toList(),
    'signature': signature != null ? base64Encode(signature!) : null,
    'isFinalized': isFinalized,
    'factureId': factureId,
    'dateDerniereModification': dateDerniereModification.toIso8601String(),
    'remise': remise,
    'tauxTVA': tauxTVA,
  };

  factory FactureDraft.fromJson(Map<String, dynamic> json) => FactureDraft(
    chantierId: json['chantierId'],
    lignesManuelles:
        (json['lignesManuelles'] as List<dynamic>)
            .map((e) => CustomLigneFacture.fromJson(e))
            .toList(),
    signature:
        json['signature'] != null ? base64Decode(json['signature']) : null,
    isFinalized: json['isFinalized'] ?? false,
    factureId: json['factureId'],
    dateDerniereModification:
        DateTime.tryParse(json['dateDerniereModification'] ?? '') ??
        DateTime.now(),
    remise: (json['remise'] ?? 0).toDouble(),
    tauxTVA: (json['tauxTVA'] ?? 0).toDouble(),
  );

  @override
  FactureDraft? fromDolibarrJson(Map<String, dynamic> json) {
    throw UnimplementedError();
  }

  @override
  FactureDraft? fromJson(Map<String, dynamic> json) =>
      FactureDraft.fromJson(json);
}

@HiveType(typeId: 100)
class CustomLigneFacture extends HiveObject
    implements JsonModel<CustomLigneFacture> {
  @HiveField(0)
  final String description;

  @HiveField(1)
  final double montant;

  @HiveField(2)
  int quantite;

  @HiveField(3)
  double total;

  CustomLigneFacture({
    required this.description,
    required this.montant,
    required this.quantite,
    required this.total,
  });

  @override
  Map<String, dynamic> toJson() => {
    'description': description,
    'montant': montant,
    'quantite': quantite,
    'total': total,
  };

  factory CustomLigneFacture.fromJson(Map<String, dynamic> json) =>
      CustomLigneFacture(
        description: json['description'],
        montant: (json['montant'] ?? 0).toDouble(),
        quantite: json['quantite'],
        total: (json['total'] as num).toDouble(),
      );

  @override
  DateTime? updatedAt;

  @override
  CustomLigneFacture? copyWithId(String? id) => this;

  @override
  CustomLigneFacture? fromDolibarrJson(Map<String, dynamic> json) =>
      CustomLigneFacture.fromJson(json);

  @override
  CustomLigneFacture? fromJson(Map<String, dynamic> json) =>
      CustomLigneFacture.fromJson(json);

  @override
  // TODO: implement id
  String? get id => throw UnimplementedError();
}
