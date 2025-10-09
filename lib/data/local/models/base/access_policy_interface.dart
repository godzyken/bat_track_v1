import '../../../../models/data/json_model.dart';
import '../index_model_extention.dart';

abstract class AccessPolicy<T> {
  bool canAccess(String role, {dynamic entity});
  bool canCreate(String role, {dynamic entity});
  bool canEdit(String role, {dynamic entity});
  bool canDelete(String role, {dynamic entity});
  bool canMerge(String role, JsonModelWithUser<dynamic> entity);
  bool canRead(String role, String userId, JsonModelWithUser<dynamic> entity);
}

class MultiRolePolicy implements AccessPolicy {
  @override
  bool canAccess(String role, {entity}) {
    return switch (role) {
      'admin' => true,
      'tech' => true,
      'client' => true,
      _ => false,
    };
  }

  @override
  bool canCreate(String role, {entity}) {
    return switch (role) {
      'admin' => true,
      'tech' => _canEditTech(entity),
      'client' => true,
      _ => false,
    };
  }

  @override
  bool canEdit(String role, {entity}) {
    return switch (role) {
      'admin' => true,
      'tech' => _canEditTech(entity),
      'client' => _canEditClient(entity),
      _ => false,
    };
  }

  @override
  bool canDelete(String role, {entity}) {
    return switch (role) {
      'admin' => true,
      'tech' => _canEditTech(entity), // pas de suppression
      'client' => _canEditClient(entity),
      _ => false,
    };
  }

  bool _canEditTech(dynamic entity) {
    // Exemples d’entités modifiables par tech
    if (entity == null) return false;
    return entity is Piece ||
        entity is ChantierEtape ||
        entity is Intervention ||
        entity is FactureDraft ||
        entity is Equipement ||
        entity is Materiel ||
        entity is MainOeuvre;
  }

  bool _canEditClient(dynamic entity) {
    if (entity == null) return false;
    return entity is Piece ||
        entity is Chantier ||
        entity is FactureDraft ||
        entity is Projet ||
        entity is Intervention ||
        entity is Materiau;
  }

  @override
  bool canMerge(String role, JsonModelWithUser<dynamic> entity) {
    return role == 'admin';
  }

  @override
  bool canRead(String role, String userId, JsonModelWithUser<dynamic> entity) {
    return switch (role) {
      'admin' => true,
      'client' => entity.ownerId == userId,
      'tech' => entity.assignedUserIds.contains(userId),
      _ => false,
    };
  }
}

mixin AccessPolicyX<T extends JsonModelWithUser> {
  bool canRead(T entity, String role, String userId) {
    if (role == 'admin') return true;
    if (role == 'client') return entity.ownerId == userId;
    if (role == 'tech') return entity.assignedUserIds.contains(userId);
    return false;
  }

  bool canEdit(T entity, String role, String userId) {
    if (role == 'admin') return true;
    if (role == 'client') return entity.ownerId == userId;
    if (role == 'tech') return entity.assignedUserIds.contains(userId);
    return false;
  }

  bool canMerge(T entity, String role) {
    return role == 'admin'; // Seul l'admin valide le merge
  }
}
