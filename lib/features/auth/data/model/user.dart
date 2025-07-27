import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive/hive.dart';

import '../../../../models/data/json_model.dart';

part 'user.freezed.dart';
part 'user.g.dart';

@freezed
@HiveType(typeId: 10, adapterName: 'UserAdapter')
class User with _$User implements JsonModel<User> {
  const factory User({
    @HiveField(0) required String id,
    @HiveField(1) required String name,
    @HiveField(2) required String email,
    @HiveField(3) required UserRole role,
    @HiveField(4) bool? isDolibarrValidated,
    @HiveField(5) DateTime? updatedAt,
    @HiveField(6) @Default(false) bool isCloudOnly,
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}

@HiveType(typeId: 11)
enum UserRole {
  @HiveField(0)
  client,
  @HiveField(1)
  chefDeProjet,
  @HiveField(2)
  technicien,
  @HiveField(3)
  superUtilisateur,
}

extension UserAccess on User {
  bool get isClient => role == UserRole.client;
  bool get isChefDeProjet => role == UserRole.chefDeProjet;
  bool get isTechnicien => role == UserRole.technicien;
  bool get isSuperUtilisateur => role == UserRole.superUtilisateur;

  bool get peutValiderDolibarr => isSuperUtilisateur;
  bool get estValideDolibarr => isDolibarrValidated == true;

  bool get estDisponiblePourSelection => isTechnicien && estValideDolibarr;
}
