import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:uuid/uuid.dart';

import '../../../core/unified_model.dart';

part 'client.freezed.dart';
part 'client.g.dart';

@freezed
class Client
    with _$Client, AccessControlMixin, ValidationMixin
    implements UnifiedModel {
  const Client._();

  const factory Client({
    required String id,
    required String nom,
    required String email,
    required String telephone,
    required String adresse,
    required int interventionsCount,
    required DateTime lastInterventionDate,
    required String status,
    required String priority,
    String? contactName,
    double? budgetPrevu,
    DateTime? updatedAt,
  }) = _Client;

  /// JSON & Hive
  @override
  factory Client.fromJson(Map<String, dynamic> json) => _$ClientFromJson(json);

  factory Client.mock() => Client(
    id: const Uuid().v4(),
    nom: 'Jhoanna Marie',
    email: 'marie.j@mailTo.fr',
    telephone: '06.07.08.09.10',
    adresse: '2 rue Paulot fès, 69000 Lyon',
    interventionsCount: 4,
    lastInterventionDate: DateTime(2000, 03, 21),
    status: 'A Faire',
    priority: 'Urgent',
    updatedAt: DateTime.now(),
    contactName: 'howard Starks',
    budgetPrevu: 35000,
  );

  @override
  bool get isUpdated => updatedAt != null;

  @override
  @override
  UnifiedModel copyWithId(String newId) => copyWith(id: newId);
}
