import 'package:bat_track_v1/data/local/models/index_model_extention.dart';
import 'package:hive_ce/hive.dart';

import '../../../../models/data/hive_model.dart';

part 'app_user_entity.g.dart';

@HiveType(typeId: 15)
class AppUserEntity extends HiveObject implements HiveModel<AppUser> {
  @HiveField(0)
  final String uid;
  @HiveField(1)
  final String role;
  @HiveField(2)
  final String? name;
  @HiveField(3)
  final String? email;
  @HiveField(4)
  final String? company;
  @HiveField(5)
  final String? motDePasse;
  @HiveField(6)
  final DateTime createdAt;
  @HiveField(7)
  final DateTime? appUpdatedAt;
  @HiveField(8)
  final bool? appIsUpdated;
  @HiveField(9)
  final String? instanceId;
  @override
  @HiveField(10)
  final DateTime? updatedAt;
  @HiveField(11)
  final DateTime? lastTimeConnect;

  AppUserEntity({
    required this.uid,
    required this.role,
    required this.name,
    required this.email,
    required this.company,
    required this.motDePasse,
    required this.createdAt,
    required this.appUpdatedAt,
    required this.appIsUpdated,
    required this.instanceId,
    required this.updatedAt,
    required this.lastTimeConnect,
  });
  factory AppUserEntity.fromModel(AppUser model) {
    return AppUserEntity(
      uid: model.id,
      role: model.role,
      name: model.name,
      email: model.email,
      company: model.company,
      motDePasse: model.motDePasse,
      createdAt: model.createdAt,
      appUpdatedAt: model.appUpdatedAt,
      appIsUpdated: model.appIsUpdated,
      instanceId: model.instanceId,
      updatedAt: model.updatedAt,
      lastTimeConnect: model.lastTimeConnect,
    );
  }
  @override
  HiveModel<AppUser> fromModel(AppUser model) => AppUserEntity.fromModel(model);

  @override
  String get id => uid;

  @override
  AppUser toModel() => AppUser(
    uid: id,
    role: role,
    name: name,
    email: email,
    company: company,
    motDePasse: motDePasse,
    createdAt: createdAt,
    appUpdatedAt: appUpdatedAt,
    appIsUpdated: appIsUpdated,
    instanceId: instanceId,
    updatedAt: updatedAt,
    lastTimeConnect: lastTimeConnect,
  );
}
