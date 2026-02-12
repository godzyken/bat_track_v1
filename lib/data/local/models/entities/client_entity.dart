import 'package:hive_ce/hive.dart';
import 'package:shared_models/shared_models.dart';

import '../../../../models/data/hive_model.dart';

part 'client_entity.g.dart';

@HiveType(typeId: 4)
class ClientEntity extends HiveObject implements HiveModel<Client> {
  @HiveField(0)
  final String clId;
  @HiveField(1)
  final String nom;
  @HiveField(2)
  final String email;
  @HiveField(3)
  final String telephone;
  @HiveField(4)
  final String adresse;
  @HiveField(5)
  final int interventionsCount;
  @HiveField(6)
  final DateTime lastInterventionDate;
  @HiveField(7)
  final String status;
  @HiveField(8)
  final String priority;
  @HiveField(9)
  final String? contactName;
  @HiveField(10)
  final double? budgetPrevu;
  @HiveField(11)
  final DateTime? clUpdatedAt;

  ClientEntity({
    required this.clId,
    required this.nom,
    required this.email,
    required this.telephone,
    required this.adresse,
    required this.interventionsCount,
    required this.lastInterventionDate,
    required this.status,
    required this.priority,
    required this.contactName,
    required this.budgetPrevu,
    this.clUpdatedAt,
  });

  @override
  factory ClientEntity.fromModel(Client model) {
    return ClientEntity(
      clId: model.id,
      nom: model.nom,
      email: model.email,
      telephone: model.telephone,
      adresse: model.adresse,
      interventionsCount: model.interventionsCount,
      lastInterventionDate: model.lastInterventionDate,
      status: model.status,
      priority: model.priority,
      contactName: model.contactName,
      budgetPrevu: model.budgetPrevu,
      clUpdatedAt: model.updatedAt,
    );
  }

  @override
  ClientEntity fromModel(Client model) => ClientEntity.fromModel(model);

  @override
  Client toModel() => Client(
    id: id,
    nom: nom,
    email: email,
    telephone: telephone,
    adresse: adresse,
    interventionsCount: interventionsCount,
    lastInterventionDate: lastInterventionDate,
    status: status,
    priority: priority,
    budgetPrevu: budgetPrevu,
    contactName: contactName,
    updatedAt: updatedAt,
  );

  @override
  String get id => clId;

  @override
  DateTime? get updatedAt => clUpdatedAt;
}
