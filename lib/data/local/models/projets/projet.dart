import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shared_models/models/private/app_user.dart';
import 'package:shared_models/shared_models.dart';
import 'package:uuid/uuid.dart';

import '../chantiers/chantier.dart';

part 'projet.freezed.dart';
part 'projet.g.dart';

enum ProjetStatus {
  draft,
  pendingValidation,
  pendingMerge,
  validated,
  rejected,
}

@freezed
sealed class Projet extends UnifiedModel with _$Projet {
  Projet._();

  factory Projet({
    required String id,
    required String nom,
    required String description,
    @DateTimeIsoConverter() required DateTime dateDebut,
    @DateTimeIsoConverter() required DateTime dateFin,
    @NullableDateTimeIsoConverter() DateTime? deadLine,
    @NullableDateTimeIsoConverter() DateTime? updatedAt,
    @NullableDateTimeIsoConverter() DateTime? deletedAt,
    required String company,
    required String createdBy,
    required List<String> members,
    @Default([]) List<String> assignedUserIds,
    @Default(ProjetStatus.draft) ProjetStatus status,
    @Default(false) bool clientValide,
    @Default(false) bool chefDeProjetValide,
    @Default(false) bool techniciensValides,
    @Default(false) bool superUtilisateurValide,
    required Map<String, dynamic> cloudVersion,
    Map<String, dynamic>? localDraft,
    String? specialite,
    String? localisation,
    double? budgetEstime,
    String? currentUserId,
    List<Chantier>? chantiers,
  }) = _Projet;

  factory Projet.fromJson(Map<String, dynamic> json) => _$ProjetFromJson(json);

  @override
  String get ownerId => createdBy;

  @override
  Projet copyWithId(String newId) => copyWith(id: newId);

  @override
  Projet markDeleted(DateTime date) {
    return copyWith(updatedAt: date, deletedAt: date);
  }

  @override
  bool get toutesPartiesOntValide =>
      clientValide && chefDeProjetValide && techniciensValides;

  @override
  bool canRead(AppUser user) => true; // À affiner selon les besoins

  @override
  bool canEdit(AppUser user) {
    if (AppUserAccessControl(user).isAdmin) return true;
    if (AppUserAccessControl(user).isClient && ownerId == user.uid && !chefDeProjetValide) return true;
    return false;
  }

  @override
  bool canDelete(AppUser user) => AppUserAccessControl(user).isAdmin;

  @override
  bool canMerge(AppUser user) => AppUserAccessControl(user).isAdmin;

  @override
  bool canValidate(AppUser user) => AppUserAccessControl(user).isAdmin || (AppUserAccessControl(user).isClient && ownerId == user.uid);
}

/// 🔹 Extensions pour la logique métier
extension ProjetLogic on Projet {
  bool get toutesPartiesOntValide =>
      clientValide && chefDeProjetValide && techniciensValides;

  bool get estPretPourDolibarr =>
      toutesPartiesOntValide && !superUtilisateurValide;

  Projet copyWithId(String? newId) => copyWith(id: newId ?? id);

  // Correction : une seule version de copyWithField
  Projet copyWithField(String key, dynamic value) {
    switch (key) {
      case 'specialite':
        return copyWith(specialite: value as String?);
      case 'localisation':
        return copyWith(localisation: value as String?);
      case 'technicienIds':
        return copyWith(assignedUserIds: List<String>.from(value as List));
      default:
        return this;
    }
  }
}

/// 🔹 Extensions pour les droits et workflow
extension ProjetAccess on Projet {
  bool canEditProject(AppUser user) {
    if (AppUserAccessControl(user).isAdmin || user.isClient) return true;
    if (AppUserAccessControl(user).isClient &&
        ownerId == user.uid &&
        !chefDeProjetValide) {
      return true;
    }
    if (AppUserAccessControl(user).isTechnicien &&
        members.contains(user.uid) &&
        clientValide) {
      return true;
    }

    return false;
  }

  bool canValidateProject(AppUser user) {
    return AppUserAccessControl(user).isAdmin || user.isClient;
  }

  bool canBeAssigned(AppUser user) {
    return AppUserAccessControl(user).isTechnicien &&
        clientValide &&
        !members.contains(user.uid);
  }

  Projet validateByClient(String clientId) {
    if (ownerId != clientId) throw Exception('Seul le créateur peut valider.');
    return copyWith(clientValide: true);
  }

  Projet validateByAdminOrChef(AppUser user) {
    if (!canValidateProject(user)) throw Exception('Utilisateur non autorisé.');
    return copyWith(chefDeProjetValide: true);
  }

  Projet assignTechnician(AppUser tech) {
    if (!canBeAssigned(tech)) {
      throw Exception('Technicien non valide ou déjà assigné.');
    }
    final updatedMembers = List<String>.from(members)..add(tech.uid);
    return copyWith(members: updatedMembers);
  }

  String get currentStatus {
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

// 🔹 Mock / test / UI helper
extension ProjetMock on Projet {
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
