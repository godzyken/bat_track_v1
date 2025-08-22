import 'package:bat_track_v1/data/local/models/base/has_acces_control.dart';

import '../../../../data/local/models/index_model_extention.dart';

class ProjetPolicy {
  bool canCreate(AppUser user) => user.isClient;

  bool canEdit(AppUser user, Projet projet) {
    if (user.isAdmin) return true;
    if (user.isClient &&
        projet.createdBy == user.uid &&
        projet.status == ProjetStatus.draft)
      return true;
    if (user.isTechnicien && projet.members.contains(user.uid)) return true;
    return false;
  }

  bool canValidate(AppUser user, Projet projet) => user.isAdmin;

  bool canAssignTech(AppUser user, Projet projet) => user.isAdmin;

  bool canDelete(AppUser user, Projet projet) {
    if (user.isAdmin) return true;
    if (user.isClient &&
        projet.createdBy == user.uid &&
        projet.status == ProjetStatus.draft)
      return true;
    return false;
  }

  bool canRead(AppUser user, Projet projet) {
    if (user.isAdmin) return true;
    if (user.isClient && projet.createdBy == user.uid) return true;
    if (user.isTechnicien && projet.members.contains(user.uid)) return true;
    return false;
  }
}
