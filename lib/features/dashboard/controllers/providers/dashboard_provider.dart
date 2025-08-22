import 'package:bat_track_v1/data/local/services/service_type.dart';
import 'package:bat_track_v1/features/auth/data/providers/current_user_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/local/models/index_model_extention.dart';

class DashboardData {
  final List<Projet> projets;
  final List<Chantier> chantiers;
  final List<Intervention> interventions;

  DashboardData({
    required this.projets,
    required this.chantiers,
    required this.interventions,
  });
}

final dashboardProvider = FutureProvider<DashboardData>((ref) async {
  final user = ref.watch(currentUserProvider).value;

  final allProjets = await projetService.getAll();
  final allChantiers = await chantierService.getAll();
  final allInterventions = await interventionService.getAll();

  List<Projet> projetsFiltered = [];
  List<Chantier> chantiersFiltered = [];
  List<Intervention> interventionsFiltered = [];

  if (user != null) {
    final roles = UserRoleX.fromString(user.role);

    switch (roles) {
      case UserRole.superUtilisateur:
        // L'admin voit tout
        projetsFiltered = allProjets;
        chantiersFiltered = allChantiers;
        interventionsFiltered = allInterventions;
        break;

      case UserRole.technicien:
        // Le technicien voit uniquement les chantiers et interventions qui lui sont assignés
        chantiersFiltered =
            allChantiers
                .where((c) => c.technicienIds.contains(user.id))
                .toList();

        interventionsFiltered =
            allInterventions
                .where((i) => i.technicienId.contains(user.id))
                .toList();

        // Projets liés aux chantiers du technicien
        final projetIds =
            chantiersFiltered.map((c) => c.chefDeProjetId).toSet();
        projetsFiltered =
            allProjets.where((p) => projetIds.contains(p.id)).toList();
        break;

      case UserRole.client:
        // Le client voit ses projets et chantiers associés
        projetsFiltered =
            allProjets.where((p) => p.ownerId.contains(user.id)).toList();

        chantiersFiltered =
            allChantiers
                .where(
                  (c) => projetsFiltered.map((p) => p.id).contains(c.clientId),
                )
                .toList();

        interventionsFiltered =
            allInterventions
                .where(
                  (i) =>
                      chantiersFiltered.map((c) => c.id).contains(i.chantierId),
                )
                .toList();
        break;
      case null:
        // TODO: Handle this case.
        throw UnimplementedError();
      case UserRole.chefDeProjet:
        // Le client voit ses projets et chantiers associés
        projetsFiltered =
            allProjets.where((p) => p.ownerId.contains(user.id)).toList();

        chantiersFiltered =
            allChantiers
                .where(
                  (c) => projetsFiltered.map((p) => p.id).contains(c.clientId),
                )
                .toList();

        interventionsFiltered =
            allInterventions
                .where(
                  (i) =>
                      chantiersFiltered.map((c) => c.id).contains(i.chantierId),
                )
                .toList();
        break;
    }
  }
  return DashboardData(
    projets: projetsFiltered,
    chantiers: chantiersFiltered,
    interventions: interventionsFiltered,
  );
});
