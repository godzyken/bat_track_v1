import 'package:bat_track_v1/models/data/hive_model.dart';
import 'package:hive/hive.dart';

import '../chantiers/main_oeuvre.dart';

part 'main_oeuvre_entity.g.dart';

@HiveType(typeId: 5)
class MainOeuvreEntity extends HiveObject implements HiveModel<MainOeuvre> {
  @HiveField(0)
  final String moId;

  @HiveField(1)
  final String idTechnicien;

  @HiveField(2)
  final double heuresEstimees;

  @HiveField(3)
  final DateTime? moUpdatedAt;

  MainOeuvreEntity({
    required this.moId,
    required this.idTechnicien,
    required this.heuresEstimees,
    this.moUpdatedAt,
  });

  factory MainOeuvreEntity.fromModel(MainOeuvre model) {
    return MainOeuvreEntity(
      moId: model.id,
      idTechnicien: model.idTechnicien!,
      heuresEstimees: model.heuresEstimees,
      moUpdatedAt: model.updatedAt,
    );
  }

  @override
  MainOeuvreEntity fromModel(MainOeuvre model) =>
      MainOeuvreEntity.fromModel(model);

  @override
  MainOeuvre toModel() => MainOeuvre(
    id: id,
    idTechnicien: idTechnicien,
    heuresEstimees: heuresEstimees,
    updatedAt: updatedAt,
  );

  @override
  String get id => moId;

  @override
  DateTime? get updatedAt => moUpdatedAt;
}
