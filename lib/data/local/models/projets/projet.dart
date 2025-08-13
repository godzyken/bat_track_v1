import 'package:bat_track_v1/data/local/adapters/signture_converter.dart';
import 'package:bat_track_v1/data/local/models/base/has_acces_control.dart';
import 'package:bat_track_v1/models/data/json_model.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:uuid/uuid.dart';

import '../utilisateurs/app_user.dart';

part 'projet.freezed.dart';
part 'projet.g.dart';

@freezed
class Projet with _$Projet implements JsonModel<Projet>, HasAccessControl {
  const Projet._();

  const factory Projet({
    required String id,
    required String nom,
    required String description,
    @DateTimeIsoConverter() required DateTime dateDebut,
    @DateTimeIsoConverter() required DateTime dateFin,
    required bool clientValide,
    required bool chefDeProjetValide,
    required bool techniciensValides,
    required bool superUtilisateurValide,
    @NullableDateTimeIsoConverter() DateTime? deadLine,
    @NullableDateTimeIsoConverter() DateTime? updatedAt,
    required String company,
    required String createdBy,
    required List<String> members,
    required Map<String, dynamic> cloudVersion,
    required Map<String, dynamic>? localDraft,
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

  @override
  bool get isUpdated => updatedAt != null;

  @override
  bool canAccess(AppUser user) {
    if (user.isAdmin) return true;
    return user.company == createdBy &&
        (user.isClient ? members.contains(user.uid) : true);
  }

  /// Détermine si l'utilisateur peut éditer ce projet
  bool canEdit(AppUser user) {
    // Admin ou Chef de projet : toujours OK
    if (user.isAdmin || user.isChefDeProjet) return true;

    // Client : peut modifier uniquement si il est le créateur
    if (user.isClient && createdBy == user.uid) return true;

    // Technicien : peut modifier si assigné au projet
    if (user.isTechnicien && members.contains(user.uid)) return true;

    return false;
  }

  /// Détermine si l'utilisateur peut valider/merge vers le cloud
  bool canMergeToCloud(AppUser user) {
    // Seul admin ou chef de projet valide
    return user.isAdmin || user.isChefDeProjet;
  }
}
