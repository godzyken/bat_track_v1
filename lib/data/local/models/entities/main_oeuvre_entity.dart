import 'package:bat_track_v1/models/data/hive_model.dart';
import 'package:hive/hive.dart';

import '../chantiers/main_oeuvre.dart';

part 'main_oeuvre_entity.g.dart';

@HiveType(typeId: 10)
class MainOeuvreEntity extends HiveObject implements HiveModel<MainOeuvre> {
  @HiveField(0)
  final String moId;

  @HiveField(1)
  final String idTechnicien;

  @HiveField(2)
  final double heuresEstimees;

  @HiveField(3)
  final DateTime? moUpdatedAt;

  @HiveField(4)
  final DateTime dateCreate;

  @HiveField(5)
  final bool? isActive;

  @HiveField(6)
  final String chantierId;

  MainOeuvreEntity({
    required this.moId,
    required this.chantierId,
    required this.idTechnicien,
    required this.heuresEstimees,
    this.moUpdatedAt,
    required this.dateCreate,
    this.isActive = false,
  });

  factory MainOeuvreEntity.fromModel(MainOeuvre model) {
    return MainOeuvreEntity(
      moId: model.id,
      chantierId: model.chantierId,
      idTechnicien: model.idTechnicien,
      heuresEstimees: model.heuresEstimees,
      moUpdatedAt: model.updatedAt,
      dateCreate: model.dateDebut,
      isActive: model.isActive,
    );
  }

  @override
  MainOeuvreEntity fromModel(MainOeuvre model) =>
      MainOeuvreEntity.fromModel(model);

  @override
  MainOeuvre toModel() => MainOeuvre(
    id: id,
    chantierId: chantierId,
    idTechnicien: idTechnicien,
    heuresEstimees: heuresEstimees,
    dateDebut: dateCreate,
    passedTime: moUpdatedAt,
    updatedAt: updatedAt,
    isActive: true,
  );

  @override
  String get id => moId;

  @override
  DateTime? get updatedAt => moUpdatedAt;
}
