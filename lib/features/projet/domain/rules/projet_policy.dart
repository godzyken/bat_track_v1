import 'package:shared_models/shared_models.dart';

import '../../../../data/local/models/index_model_extention.dart';

class ProjetPolicy {
  bool canCreate(AppUser user) => AppUserAccess(user).isClient;

  bool canEdit(AppUser user, Projet projet) {
    if (AppUserAccess(user).isAdmin) return true;
    if (AppUserAccess(user).isClient &&
        projet.createdBy == user.uid &&
        projet.status == ProjetStatus.draft) {
      return true;
    }
    if (AppUserAccess(user).isTechnicien && projet.members.contains(user.uid))
      return true;
    return false;
  }

  bool canValidate(AppUser user, Projet projet) => AppUserAccess(user).isAdmin;

  bool canAssignTech(AppUser user, Projet projet) =>
      AppUserAccess(user).isAdmin;

  bool canDelete(AppUser user, Projet projet) {
    if (AppUserAccess(user).isAdmin) return true;
    if (AppUserAccess(user).isClient &&
        projet.createdBy == user.uid &&
        projet.status == ProjetStatus.draft) {
      return true;
    }
    return false;
  }

  bool canRead(AppUser user, Projet projet) {
    if (AppUserAccess(user).isAdmin) return true;
    if (AppUserAccess(user).isClient && projet.createdBy == user.uid)
      return true;
    if (AppUserAccess(user).isTechnicien && projet.members.contains(user.uid))
      return true;
    return false;
  }
}
