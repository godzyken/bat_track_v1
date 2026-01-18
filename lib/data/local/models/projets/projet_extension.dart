import 'package:bat_track_v1/data/local/models/base/has_acces_control.dart';
import 'package:bat_track_v1/data/local/models/projets/projet.dart';
import 'package:uuid/uuid.dart';

import '../utilisateurs/app_user.dart';

extension ProjetUtils on Projet {
  bool get toutesPartiesOntValide =>
      clientValide && chefDeProjetValide && techniciensValides;

  bool get estPretPourDolibarr =>
      toutesPartiesOntValide && !superUtilisateurValide;

  Projet copyWithId(String? newId) => copyWith(id: newId ?? id);

  static Projet mock() => Projet(
    id: const Uuid().v4(),
    nom: 'Construction École',
    company: 'Léon Bross',
    description: 'Projet de construction modulaire pour école primaire.',
    dateDebut: DateTime.now(),
    dateFin: DateTime.now().add(const Duration(days: 120)),
    updatedAt: DateTime.now(),
    clientValide: true,
    chefDeProjetValide: true,
    techniciensValides: true,
    superUtilisateurValide: false,
    members: [],
    createdBy: 'Nickholos',
    deadLine: DateTime(1),
    cloudVersion: {
      'nom': 'Categate',
      'description': 'Rénovation validée par admin',
    },
    localDraft: {
      'nom': 'Categate v2',
      'description': 'Rénovation avec nouvelles fenêtres',
    },
  );
}

extension ProjetWorkflow on Projet {
  /// 🔹 Vérifie si l'utilisateur peut modifier le projet
  bool canEditProject(AppUser user) {
    if (user.isAdmin || user.isChefDeProjet) return true;
    if (user.isClient && ownerId == user.uid && !chefDeProjetValide) {
      return true;
    }
    if (user.isTechnicien && members.contains(user.uid) && clientValide) {
      return true;
    }
    return false;
  }

  /// 🔹 Vérifie si l'utilisateur peut valider le projet
  bool canValidateProject(AppUser user) {
    return user.isAdmin || user.isChefDeProjet;
  }

  /// 🔹 Vérifie si l'utilisateur peut être assigné comme technicien
  bool canBeAssigned(AppUser user) {
    return user.isTechnicien && clientValide && !members.contains(user.uid);
  }

  /// 🔹 Marque le projet comme validé par le client
  Projet validateByClient(String clientId) {
    if (ownerId != clientId) throw Exception("Seul le créateur peut valider.");
    return copyWith(clientValide: true);
  }

  /// 🔹 Marque le projet comme validé par le chef de projet / admin
  Projet validateByAdminOrChef(AppUser user) {
    if (!canValidateProject(user)) throw Exception("Utilisateur non autorisé.");
    return copyWith(chefDeProjetValide: true);
  }

  /// 🔹 Assignation d'un technicien
  Projet assignTechnician(AppUser tech) {
    if (!canBeAssigned(tech)) {
      throw Exception("Technicien non valide ou déjà assigné.");
    }
    final updatedMembers = List<String>.from(members)..add(tech.uid);
    return copyWith(members: updatedMembers);
  }

  /// 🔹 Statut global du projet
  String get status {
    if (!clientValide) return 'draft';
    if (clientValide && !chefDeProjetValide) return 'pendingValidation';
    if (clientValide && chefDeProjetValide && !techniciensValides) {
      return 'validatedWithoutTechnicians';
    }
    if (clientValide && chefDeProjetValide && techniciensValides) {
      return 'fullyValidated';
    }
    return 'unknown';
  }
}

extension ProjetCopy on Projet {
  Projet copyWithField(String key, dynamic value) {
    switch (key) {
      case 'specialite':
        return copyWith(specialite: value as String);
      case 'localisation':
        return copyWith(localisation: value as String);
      case 'technicienIds':
        return copyWith(assignedUserIds: List<String>.from(value));
      default:
        return this;
    }
  }
}
