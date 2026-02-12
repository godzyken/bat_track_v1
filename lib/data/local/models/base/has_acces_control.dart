import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_models/shared_models.dart';

import '../../../../features/auth/data/providers/current_user_provider.dart';

/// Interface de base pour le contrôle d'accès
abstract class HasAccessControl {
  bool canAccess(AppUser user);
}

/// Extension utilitaire pour des règles prédéfinies
extension AccessControlRules on HasAccessControl {
  bool canAccessAll(AppUser user) =>
      AppUserAccess(user).isAdmin ||
      AppUserAccess(user).isTechnicien ||
      AppUserAccess(user).isClient;

  bool canModifyAdminTechOnly(AppUser user) =>
      AppUserAccess(user).isAdmin || AppUserAccess(user).isTechnicien;

  bool canModifyClientAndTechOnly(AppUser user) =>
      AppUserAccess(user).isClient || AppUserAccess(user).isTechnicien;

  bool canModifyClientOnly(AppUser user) => AppUserAccess(user).isClient;

  bool canModifyAdminOnly(AppUser user) => AppUserAccess(user).isAdmin;

  bool denyAll(AppUser user) => false;
}

/// Extension pratique sur AppUser
extension AppUserRoleExtension on AppUser {
  bool get isAdmin => role.toLowerCase() == 'admin';
  bool get isTechnicien =>
      role.toLowerCase() == 'technicien' || role.toLowerCase() == 'tech';
  bool get isClient => role.toLowerCase() == 'client';
  bool get isChefDeProjet => role.toLowerCase() == 'client';
}

/// Mixin permettant d'ajouter un contrôle d'accès basé sur le rôle et l'owner
mixin RoleBasedAccess on HasAccessControl {
  String get ownerId;

  bool canView(Ref ref) {
    final user = ref.read(currentUserProvider).value;
    if (user == null) return false;
    if (AppUserAccess(user).isAdmin) return true;
    if (user.uid == ownerId) return true;
    return false;
  }

  bool canCreate(Ref ref) {
    final user = ref.read(currentUserProvider).value;
    if (user == null) return false;
    return AppUserAccess(user).isAdmin || AppUserAccess(user).isClient;
  }

  bool canEdit(Ref ref) {
    final user = ref.read(currentUserProvider).value;
    if (user == null) return false;

    if (AppUserAccess(user).isAdmin) return true;

    if (AppUserAccess(user).isTechnicien && user.uid == ownerId) return true;

    if (AppUserAccess(user).isClient && user.uid == ownerId) return true;

    return false;
  }

  bool canDelete(Ref ref) {
    final user = ref.read(currentUserProvider).value;
    if (user == null) return false;
    return AppUserAccess(user).isAdmin;
  }

  bool canMerge(Ref ref) {
    final user = ref.read(currentUserProvider).value;
    if (user == null) return false;
    return AppUserAccess(user).isAdmin;
  }

  /// Merge local/cloud si autorisé
  Future<void> mergeCloudDataIfAllowed(
    Ref ref, {
    required Future<Map<String, dynamic>> Function() getLocalData,
    required Future<Map<String, dynamic>> Function() getCloudData,
    required Future<void> Function(Map<String, dynamic>) saveMergedData,
  }) async {
    if (!canMerge(ref)) {
      return; // Pas d'autorisation de merge
    }

    final local = await getLocalData();
    final cloud = await getCloudData();

    // Merge simple, cloud prioritaire puis local
    final merged = {...cloud, ...local};

    await saveMergedData(merged);
  }
}

/// Interface commune à tous les modèles JSON
abstract class JsonSerializableModel<T> {
  Map<String, dynamic> toJson();
}

/// Mixin combinant sérialisation JSON et contrôle d'accès
mixin JsonModelWithUser<T> on JsonSerializableModel<T>, HasAccessControl {
  String get ownerId;
}
