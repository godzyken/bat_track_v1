import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../core/unified_model.dart';
import 'app_user.dart';

part 'user.freezed.dart';
part 'user.g.dart';

@freezed
class UserModel
    with _$UserModel, AccessControlMixin, ValidationMixin
    implements UnifiedModel {
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

  @override
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

  @override
  String get ownerId => id;

  String get roleName => role.asString;

  @override
  UnifiedModel copyWithId(String newId) => copyWith(id: newId);

  @override
  // TODO: implement company
  String? get company => throw UnimplementedError();

  @override
  // TODO: implement createAt
  DateTime get createAt => throw UnimplementedError();

  @override
  // TODO: implement email
  String get email => throw UnimplementedError();

  @override
  // TODO: implement id
  String get id => throw UnimplementedError();

  @override
  // TODO: implement instanceId
  String? get instanceId => throw UnimplementedError();

  @override
  // TODO: implement isCloudOnly
  bool get isCloudOnly => throw UnimplementedError();

  @override
  // TODO: implement isDolibarrValidated
  bool? get isDolibarrValidated => throw UnimplementedError();

  @override
  // TODO: implement lastTimeConnect
  DateTime? get lastTimeConnect => throw UnimplementedError();

  @override
  // TODO: implement name
  String get name => throw UnimplementedError();

  @override
  // TODO: implement role
  UserRole get role => throw UnimplementedError();

  @override
  Map<String, dynamic> toJson() {
    // TODO: implement toJson
    throw UnimplementedError();
  }

  @override
  // TODO: implement updatedAt
  DateTime? get updatedAt => throw UnimplementedError();
}

enum UserRole { client, chefDeProjet, technicien, superUtilisateur }

enum UserStatus {
  guest, // pas connecté
  authenticated, // connecté Firebase, mais profil non encore chargé
  loaded, // AppUser complet
}

extension UserAccess on UserModel {
  bool get isClient => role == UserRole.client;
  bool get isChefDeProjet => role == UserRole.chefDeProjet;
  bool get isTechnicien => role == UserRole.technicien;
  bool get isSuperUtilisateur => role == UserRole.superUtilisateur;

  bool get peutValiderDolibarr => isSuperUtilisateur;
  bool get estValideDolibarr => isDolibarrValidated == true;
  bool get estDisponiblePourSelection => isTechnicien && estValideDolibarr;
}

extension UserRoleX on UserRole {
  static UserRole fromString(String role) {
    switch (role) {
      case 'superUtilisateur':
        return UserRole.superUtilisateur;
      case 'technicien':
        return UserRole.technicien;
      case 'client':
        return UserRole.client;
      case 'chef_de_projet':
        return UserRole.chefDeProjet;
      default:
        throw Exception("Rôle inconnu: $role");
    }
  }

  String get displayName {
    switch (this) {
      case UserRole.superUtilisateur:
        return "Administrateur";
      case UserRole.technicien:
        return "Intervenant";
      case UserRole.client:
        return "Client";
      case UserRole.chefDeProjet:
        return "Chef de Projet"; // ✅ corrigé
    }
  }

  String get assetName => displayName.toLowerCase();

  String get asString {
    switch (this) {
      case UserRole.superUtilisateur:
        return 'administrateur';
      case UserRole.technicien:
        return 'intervenant';
      case UserRole.client:
        return 'client';
      case UserRole.chefDeProjet:
        return 'chef_de_projet';
    }
  }
}

extension UserModelX on UserModel {
  AppUser toAppUser() {
    return AppUser(
      uid: id,
      name: name,
      email: email,
      role: role.asString,
      company: company,
      instanceId: instanceId,
      createdAt: createAt,
      updatedAt: updatedAt,
      lastTimeConnect: lastTimeConnect,
    );
  }
}

extension AppUserX on AppUser {
  UserModel toUserModel() {
    return UserModel(
      id: uid,
      name: name!,
      email: email!,
      role: UserRoleX.fromString(role),
      company: company,
      instanceId: instanceId,
      createAt: createdAt,
      updatedAt: updatedAt,
      lastTimeConnect: lastTimeConnect,
    );
  }
}
