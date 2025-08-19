import 'package:bat_track_v1/data/local/services/service_type.dart';

import '../../data/local/models/index_model_extention.dart';
import 'logged_entity_service.dart';

class DashboardService {
  final AppUser user;
  final LoggedEntityService<Projet> projetService;
  final LoggedEntityService<Chantier> chantierService;
  final LoggedEntityService<Intervention> interventionService;

  DashboardService({
    required this.user,
    required this.projetService,
    required this.chantierService,
    required this.interventionService,
  });

  /// Retourne le flux des projets selon le rôle de l'utilisateur
  Stream<List<Projet>> watchProjects() {
    switch (UserRoleX.fromString(user.role)) {
      case UserRole.superUtilisateur:
        return projetService.watchAll();
      case UserRole.technicien:
        return projetService.watchByTechnicien(user.uid);
      case UserRole.client:
      case UserRole.chefDeProjet:
        return projetService.watchByOwner(user.uid);
    }
  }

  /// Retourne le flux des chantiers pour les projets accessibles
  Stream<List<Chantier>> watchChantiers() {
    return watchProjects().asyncExpand((projects) {
      if (projects.isEmpty) return Stream.value([]);
      final projectIds = projects.map((p) => p.id).toList();
      return chantierService.watchByProjects(projectIds.first);
    });
  }

  /// Retourne le flux des interventions selon le rôle de l'utilisateur
  Stream<List<Intervention>> watchInterventions() {
    switch (UserRoleX.fromString(user.role)) {
      case UserRole.superUtilisateur:
        return interventionService.watchAll();
      case UserRole.technicien:
        return interventionService.watchByTechnicien(user.uid);
      case UserRole.client:
      case UserRole.chefDeProjet:
        return interventionService.watchByOwnerProjects(user.uid, user.id);
    }
  }

  /// Méthode générique pour récupérer le flux d'entités selon le type
  Stream<List<T>> watchEntities<T>() {
    if (T == Projet) return watchProjects() as Stream<List<T>>;
    if (T == Chantier) return watchChantiers() as Stream<List<T>>;
    if (T == Intervention) return watchInterventions() as Stream<List<T>>;
    throw UnimplementedError('Type $T non géré dans watchEntities');
  }

  /// Exemple : flux combiné projet → chantier → intervention
  Stream<Map<String, dynamic>> watchDashboardData() {
    return watchProjects().asyncExpand((projects) {
      final projectIds = projects.map((p) => p.id).toList();
      return chantierService.watchByProjects(projectIds.first).asyncMap((
        chantiers,
      ) {
        return {'projects': projects, 'chantiers': chantiers};
      });
    });
  }
}
