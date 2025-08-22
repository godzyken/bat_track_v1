import 'package:bat_track_v1/data/local/adapters/signture_converter.dart';
import 'package:bat_track_v1/data/local/models/base/has_acces_control.dart';
import 'package:bat_track_v1/models/data/json_model.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:uuid/uuid.dart';

import '../utilisateurs/app_user.dart';

part 'projet.freezed.dart';
part 'projet.g.dart';

enum ProjetStatus { draft, pendingValidation, validated, rejected }

@freezed
class Projet with _$Projet implements JsonModel<Projet>, HasAccessControl {
  const Projet._();

  const factory Projet({
    required String id,
    required String nom,
    required String description,

    @DateTimeIsoConverter() required DateTime dateDebut,
    @DateTimeIsoConverter() required DateTime dateFin,
    @NullableDateTimeIsoConverter() DateTime? deadLine,

    @NullableDateTimeIsoConverter() DateTime? updatedAt,

    /// Entreprise associée
    required String company,

    /// UID du créateur (client propriétaire)
    required String createdBy,

    /// Membres liés (techs assignés, collaborateurs)
    required List<String> members,

    /// Techniciens affectés explicitement
    @Default([]) List<String> assignedUserIds,

    /// État du projet (workflow)
    @Default(ProjetStatus.draft) ProjetStatus status,

    /// Validations explicites (optionnelles si tu gardes ton système booléen)
    required bool clientValide,
    required bool chefDeProjetValide,
    required bool techniciensValides,
    required bool superUtilisateurValide,

    /// Gestion des versions
    required Map<String, dynamic> cloudVersion,
    required Map<String, dynamic>? localDraft,
    String? specialite, // 🔹 métier principal demandé
    String? localisation, // 🔹 zone géographique du projet
    double? budgetEstime,
    String? currentUserId,
  }) = _Projet;

  factory Projet.fromJson(Map<String, dynamic> json) => _$ProjetFromJson(json);

  factory Projet.mock() => Projet(
    id: const Uuid().v4(),
    nom: 'Categate',
    description:
        'Renovation de la Structure et aggrandissement de la piece principale',
    dateDebut: DateTime.now(),
    dateFin: DateTime.now().add(Duration(days: 26)),
    clientValide: true,
    chefDeProjetValide: true,
    techniciensValides: true,
    superUtilisateurValide: false,
    updatedAt: DateTime.now(),
    createdBy: 'Penelope',
    members: [],
    assignedUserIds: [],
    status: ProjetStatus.draft,
    deadLine: DateTime.now().add(Duration(days: 365)),
    company: 'Bouygues',
    cloudVersion: {
      'nom': 'Categate',
      'description': 'Rénovation validée par admin',
    },
    localDraft: {
      'nom': 'Categate v2',
      'description': 'Rénovation avec nouvelles fenêtres',
    },
  );

  String get ownerId => createdBy;

  @override
  bool get isUpdated => updatedAt != null;

  @override
  bool canAccess(AppUser user) {
    if (user.isAdmin) return true;

    // Le propriétaire ou ses membres
    if (user.uid == ownerId) return true;
    if (members.contains(user.uid)) return true;

    return false;
  }

  /// Détermine si l'utilisateur peut éditer ce projet
  bool canEdit(AppUser user) {
    if (user.isAdmin || user.isChefDeProjet) return true;

    // Le client propriétaire peut éditer tant que c’est un draft/pending
    if (user.isClient && ownerId == user.uid) {
      return status == ProjetStatus.draft ||
          status == ProjetStatus.pendingValidation;
    }

    // Technicien assigné peut intervenir (ex: interventions)
    if (user.isTechnicien && assignedUserIds.contains(user.uid)) {
      return status == ProjetStatus.validated;
    }

    return false;
  }

  /// Droits de validation
  bool canValidate(AppUser user) {
    return user.isAdmin; // seul admin valide officiellement
  }

  /// Droits d’assignation des techniciens
  bool canAssignTech(AppUser user) {
    return user.isAdmin || user.isChefDeProjet;
  }

  /// Détermine si l'utilisateur peut valider/merge vers le cloud
  bool canMergeToCloud(AppUser user) {
    // Seul admin ou chef de projet valide
    return user.isAdmin || user.isChefDeProjet;
  }

  bool canEditUser(AppUser user, Projet projet) {
    if (user.isAdmin) return true;
    if (user.isClient &&
        projet.createdBy == user.uid &&
        projet.status == ProjetStatus.draft)
      return true;
    if (user.isTechnicien && projet.members.contains(user.uid)) return true;
    return false;
  }
}

extension ProjetWorkflow on Projet {
  /// 🔹 Vérifie si l'utilisateur peut modifier le projet
  bool canEditProject(AppUser user) {
    if (user.isAdmin || user.isChefDeProjet) return true;
    if (user.isClient && ownerId == user.uid && !chefDeProjetValide)
      return true;
    if (user.isTechnicien && members.contains(user.uid) && clientValide)
      return true;
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
    if (!canBeAssigned(tech))
      throw Exception("Technicien non valide ou déjà assigné.");
    final updatedMembers = List<String>.from(members)..add(tech.uid);
    return copyWith(members: updatedMembers);
  }

  /// 🔹 Statut global du projet
  String get status {
    if (!clientValide) return 'draft';
    if (clientValide && !chefDeProjetValide) return 'pendingValidation';
    if (clientValide && chefDeProjetValide && !techniciensValides)
      return 'validatedWithoutTechnicians';
    if (clientValide && chefDeProjetValide && techniciensValides)
      return 'fullyValidated';
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
