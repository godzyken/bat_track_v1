import 'package:hive_ce/hive.dart';
import 'package:shared_models/shared_models.dart';

import '../../../../models/data/hive_model.dart';

part 'user_entity.g.dart';

@HiveType(typeId: 18)
class UserEntity extends HiveObject implements HiveModel<UserModel> {
  @HiveField(0)
  final String uid;
  @HiveField(1)
  final String name;
  @HiveField(2)
  final String email;
  @HiveField(3)
  final UserRoleEntity role;
  @HiveField(4)
  bool? isDolibarrValidated;
  @HiveField(5)
  final DateTime createdAt;
  @HiveField(6)
  bool isCloudOnly;
  @HiveField(7)
  String? instanceId;
  @HiveField(8)
  DateTime? userUpdatedAt;

  UserEntity({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    required this.createdAt,
    this.isDolibarrValidated,
    this.isCloudOnly = false,
    this.userUpdatedAt,
    this.instanceId,
  });

  factory UserEntity.fromModel(UserModel model) {
    return UserEntity(
      uid: model.id,
      name: model.name,
      email: model.email,
      role: UserRoleEntity.values[model.role.index],
      createdAt: model.createAt,
      isDolibarrValidated: model.isDolibarrValidated,
      isCloudOnly: model.isCloudOnly,
      userUpdatedAt: model.updatedAt,
      instanceId: model.instanceId,
    );
  }

  @override
  UserEntity fromModel(UserModel model) => UserEntity.fromModel(model);

  @override
  UserModel toModel() => UserModel(
    id: id,
    name: name,
    email: email,
    role: role.toModel(),
    isDolibarrValidated: isDolibarrValidated,
    isCloudOnly: isCloudOnly,
    instanceId: instanceId,
    updatedAt: updatedAt,
    createAt: createdAt,
  );

  @override
  String get id => uid;

  @override
  DateTime? get updatedAt => userUpdatedAt;
}

@HiveType(typeId: 11)
enum UserRoleEntity {
  @HiveField(0)
  client,
  @HiveField(1)
  chefDeProjet,
  @HiveField(2)
  technicien,
  @HiveField(3)
  superUtilisateur,
}

extension UserRoleEntityX on UserRoleEntity {
  UserRole toModel() => UserRole.values[index];
}
