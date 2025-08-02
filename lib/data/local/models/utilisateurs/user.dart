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
    @DateTimeIsoConverter() required DateTime createAt,
    @NullableDateTimeIsoConverter() DateTime? lastTimeConnect,
    @NullableDateTimeIsoConverter() DateTime? updatedAt,
    @Default(false) bool isCloudOnly,
    String? instanceId,
    String? company,
  }) = _UserModel;

  const UserModel._();

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  factory UserModel.mock() => UserModel(
    id: 'mock-user-id',
    name: 'Jean Dupont',
    email: 'jean.dupont@example.com',
    role: UserRole.technicien,
    isDolibarrValidated: true,
    createAt: DateTime(2024, 1, 1),
    lastTimeConnect: DateTime(2025, 7, 31),
    updatedAt: DateTime.now(),
    isCloudOnly: false,
    instanceId: 'instance-1234',
    company: 'Egote + RMC service',
  );

  @override
  bool get isUpdated => updatedAt != null;
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
