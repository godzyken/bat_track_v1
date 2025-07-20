import 'dart:convert';
import 'dart:typed_data';

import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

import '../../../models/data/interface/doli_barr_adaptable.dart';
import '../../../models/data/json_model.dart';
import 'facture_draft.dart';

part 'facture_model.g.dart';

@HiveType(typeId: 21)
class FactureModel extends JsonModel<FactureModel>
    implements DolibarrAdaptable<FactureModel> {
  @override
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String chantierId;

  @HiveField(2)
  final String reference;

  @HiveField(3)
  final List<CustomLigneFacture> lignes;

  @HiveField(4)
  final double montant;

  @HiveField(5)
  final String clientId;

  @HiveField(6)
  final DateTime date;

  @HiveField(7)
  final Uint8List? signature;

  @HiveField(8)
  final FactureStatus status;

  @HiveField(9)
  @override
  DateTime? updatedAt;

  FactureModel({
    required this.id,
    required this.chantierId,
    required this.reference,
    required this.lignes,
    required this.montant,
    required this.clientId,
    required this.date,
    this.signature,
    this.status = FactureStatus.brouillon,
    this.updatedAt,
  });

  factory FactureModel.fromJson(Map<String, dynamic> json) => FactureModel(
    id: json['id'],
    chantierId: json['chantierId'],
    reference: json['reference'],
    lignes:
        (json['lignes'] as List)
            .map((e) => CustomLigneFacture.fromJson(e))
            .toList(),
    montant: (json['montant'] ?? 0).toDouble(),
    clientId: json['clientId'],
    date: DateTime.tryParse(json['date']) ?? DateTime.now(),
    signature:
        json['signature'] != null ? base64Decode(json['signature']) : null,
    status: FactureStatus.values.firstWhere(
      (s) => s.name == json['status'],
      orElse: () => FactureStatus.brouillon,
    ),
    updatedAt: DateTime.tryParse(json['updatedAt'] ?? ''),
  );

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'chantierId': chantierId,
    'reference': reference,
    'lignes': lignes.map((e) => e.toJson()).toList(),
    'montant': montant,
    'clientId': clientId,
    'date': date.toIso8601String(),
    'signature': signature != null ? base64Encode(signature!) : null,
    'status': status.name,
    'updatedAt': updatedAt?.toIso8601String(),
  };

  @override
  FactureModel copyWithId(String? newId) => copyWith(id: newId);

  FactureModel copyWith({
    String? id,
    String? chantierId,
    String? reference,
    List<CustomLigneFacture>? lignes,
    double? montant,
    String? clientId,
    DateTime? date,
    Uint8List? signature,
    FactureStatus? status,
    DateTime? updatedAt,
  }) {
    return FactureModel(
      id: id ?? this.id,
      chantierId: chantierId ?? this.chantierId,
      reference: reference ?? this.reference,
      lignes: lignes ?? this.lignes,
      montant: montant ?? this.montant,
      clientId: clientId ?? this.clientId,
      date: date ?? this.date,
      signature: signature ?? this.signature,
      status: status ?? this.status,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  FactureModel fromJson(Map<String, dynamic> json) =>
      FactureModel.fromJson(json);

  @override
  FactureModel fromDolibarrJson(Map<String, dynamic> json) => FactureModel(
    id: const Uuid().v4(),
    chantierId: json['chantier_id'] ?? '',
    reference: json['ref'] ?? '',
    lignes: [],
    montant: (json['total_ht'] ?? 0).toDouble(),
    clientId: json['socid']?.toString() ?? '',
    date: DateTime.tryParse(json['date']) ?? DateTime.now(),
  );

  @override
  Map<String, dynamic> toDolibarrJson() => {
    'ref': reference,
    'total_ht': montant,
    'socid': clientId,
    'date': date.toIso8601String(),
    'chantier_id': chantierId,
  };

  factory FactureModel.mock() => FactureModel(
    id: const Uuid().v4(),
    chantierId: 'chantier_123',
    reference: 'FAC-2025-001',
    lignes: [
      CustomLigneFacture(
        description: 'Maçonnerie',
        montant: 1200,
        quantite: 1200,
        total: 12,
      ),
      CustomLigneFacture(
        description: 'Peinture',
        montant: 340,
        quantite: 340,
        total: 1,
      ),
    ],
    montant: 1540,
    clientId: 'client_001',
    date: DateTime.now(),
  );
}

@HiveType(typeId: 22)
enum FactureStatus {
  @HiveField(0)
  brouillon,
  @HiveField(1)
  validee,
  @HiveField(2)
  envoyee,
  @HiveField(3)
  payee,
}
