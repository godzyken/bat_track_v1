import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

import '../../../models/data/interface/doli_barr_adaptable.dart';
import '../../../models/data/json_model.dart';
import 'facture_draft.dart';

part 'facture.g.dart';

@HiveType(typeId: 20)
class Facture extends JsonModel<Facture> implements DolibarrAdaptable<Facture> {
  @override
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String reference;
  @HiveField(2)
  final double montant;
  @HiveField(3)
  final String clientId;
  @HiveField(4)
  final DateTime date;
  @HiveField(5)
  DateTime? _updatedAt;

  Facture({
    required this.id,
    required this.reference,
    required this.montant,
    required this.clientId,
    required this.date,
    DateTime? updatedAt,
  }) : _updatedAt = updatedAt;

  @override
  DateTime? get updatedAt => _updatedAt;

  @override
  set updatedAt(DateTime? value) => _updatedAt = value;

  factory Facture.fromJson(Map<String, dynamic> json) => Facture(
    id: json['id'] ?? const Uuid().v4(),
    reference: json['reference'] ?? '',
    montant: (json['montant'] as num?)?.toDouble() ?? 0.0,
    clientId: json['clientId'] ?? '',
    date: DateTime.tryParse(json['date'] ?? '') ?? DateTime.now(),
    updatedAt: DateTime.tryParse(json['date'] ?? '') ?? DateTime.now(),
  );

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'reference': reference,
    'montant': montant,
    'clientId': clientId,
    'date': date.toIso8601String(),
    'updateAt': updatedAt!.toIso8601String(),
  };

  @override
  Facture fromJson(Map<String, dynamic> json) => Facture.fromJson(json);

  @override
  Facture copyWithId(String? newId) => copyWith(id: newId);

  Facture copyWith({
    String? id,
    String? reference,
    double? montant,
    String? clientId,
    DateTime? date,
    DateTime? updatedAt,
  }) {
    return Facture(
      id: id ?? this.id,
      reference: reference ?? this.reference,
      montant: montant ?? this.montant,
      clientId: clientId ?? this.clientId,
      date: date ?? this.date,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Facture fromDolibarrJson(Map<String, dynamic> json) => Facture(
    id: const Uuid().v4(),
    reference: json['ref'] ?? '',
    montant: (json['total_ht'] as num?)?.toDouble() ?? 0.0,
    clientId: json['socid']?.toString() ?? '',
    date: DateTime.tryParse(json['date'] ?? '') ?? DateTime.now(),
    updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
  );

  @override
  Map<String, dynamic> toDolibarrJson() => {
    'ref': reference,
    'total_ht': montant,
    'socid': clientId,
    'date': date.toIso8601String(),
    'updatedAt': updatedAt!.toIso8601String(),
  };

  factory Facture.mock() => Facture(
    id: const Uuid().v4(),
    reference: 'FAC-2025-001',
    montant: 1234.56,
    clientId: 'client_001',
    date: DateTime.now(),
    updatedAt: DateTime.now(),
  );

  factory Facture.fromDraft(
    FactureDraft draft,
    String reference,
    String clientId,
    DateTime? updatedAt,
  ) {
    final montantTotal = draft.lignesManuelles.fold<double>(
      0,
      (prev, ligne) => prev + ligne.montant,
    );

    return Facture(
      id: const Uuid().v4(),
      reference: reference,
      montant: montantTotal,
      clientId: clientId,
      date: DateTime.now(),
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
}
