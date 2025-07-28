import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../models/data/json_model.dart';
import '../../adapters/signture_converter.dart';

part 'user.freezed.dart';
part 'user.g.dart';

@freezed
class UserModel
    with _$UserModel
    implements JsonModel<UserModel>, JsonSerializableModel<UserModel> {
  const factory UserModel({
    required String id,
    required String name,
    required String email,
    required UserRole role,
    bool? isDolibarrValidated,
    @NullableDateTimeIsoConverter() DateTime? updatedAt,
    @Default(false) bool isCloudOnly,
    String? instanceId,
  }) = _UserModel;

  const UserModel._();

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  @override
  String get id => id;

  @override
  // TODO: implement updatedAt
  DateTime? get updatedAt => updatedAt;
}

enum UserRole { client, chefDeProjet, technicien, superUtilisateur }

extension UserAccess on UserModel {
  bool get isClient => role == UserRole.client;

  bool get isChefDeProjet => role == UserRole.chefDeProjet;

  bool get isTechnicien => role == UserRole.technicien;

  bool get isSuperUtilisateur => role == UserRole.superUtilisateur;

  bool get peutValiderDolibarr => isSuperUtilisateur;

  bool get estValideDolibarr => isDolibarrValidated == true;

  bool get estDisponiblePourSelection => isTechnicien && estValideDolibarr;
}
