import 'package:bat_track_v1/data/local/models/utilisateurs/user.dart';
import 'package:hive/hive.dart';

import '../../../../models/data/hive_model.dart';

part 'user_entity.g.dart';

@HiveType(typeId: 15, adapterName: 'UserAdapter')
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
  DateTime? userUpdatedAt;
  @HiveField(6)
  bool isCloudOnly;
  @HiveField(7)
  String? instanceId;

  UserEntity({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
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
      role: model.role.toEntity(),
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

extension UserRoleX on UserRole {
  UserRoleEntity toEntity() => UserRoleEntity.values[index];
}

extension UserRoleEntityX on UserRoleEntity {
  UserRole toModel() => UserRole.values[index];
}
