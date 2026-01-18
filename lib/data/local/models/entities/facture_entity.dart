import 'package:bat_track_v1/data/local/models/index_model_extention.dart';
import 'package:hive_ce/hive.dart';

import '../../../../models/data/hive_model.dart';

part 'facture_entity.g.dart';

@HiveType(typeId: 12)
class FactureEntity extends HiveObject implements HiveModel<Facture> {
  @HiveField(0)
  final String fId;
  @HiveField(1)
  final String reference;
  @HiveField(2)
  final double montant;
  @HiveField(3)
  final String clientId;
  @HiveField(4)
  final DateTime date;
  @HiveField(5)
  final DateTime? fUpdatedAt;

  FactureEntity({
    required this.fId,
    required this.reference,
    required this.montant,
    required this.clientId,
    required this.date,
    this.fUpdatedAt,
  });

  factory FactureEntity.fromModel(Facture model) {
    return FactureEntity(
      fId: model.id,
      reference: model.reference,
      montant: model.montant,
      clientId: model.clientId,
      date: model.date,
      fUpdatedAt: model.updatedAt,
    );
  }

  @override
  FactureEntity fromModel(Facture model) => FactureEntity.fromModel(model);

  @override
  Facture toModel() => Facture(
    id: id,
    reference: reference,
    montant: montant,
    clientId: clientId,
    date: date,
    updatedAt: updatedAt,
  );

  @override
  String get id => fId;

  @override
  DateTime? get updatedAt => fUpdatedAt;
}
