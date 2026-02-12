import 'package:shared_models/shared_models.dart';

import '../index_model_extention.dart';

/// Extensions utiles
extension ChantierValidation on Chantier {
  bool get toutesPartiesOntValide =>
      clientValide &&
      chefDeProjetValide &&
      techniciensValides &&
      superUtilisateurValide;

  bool get estValide => toutesPartiesOntValide && !isCloudOnly;
  bool get estEnCoursDeValidation => !toutesPartiesOntValide && !isCloudOnly;
  bool get peutEtreEnvoyeDolibarr => estValide;
}

/// Extension budget
extension ChantierEtapeBudget on ChantierEtape {
  double getBudgetTotalReel(
    List<Technicien> techniciens,
    MainOeuvre mainOeuvre,
  ) {
    final double budgetMateriaux = pieces.fold(
      0,
      (sum, p) => sum + p.getBudgetTotalSansMainOeuvre(),
    );

    final double budgetMainOeuvre = techniciens.fold(0, (sum, tech) {
      if (tech.id.isEmpty) return sum;

      final heures = mainOeuvre.heuresEstimees;

      double salaire = 0;

      if (heures <= 8) {
        salaire = heures * tech.tauxHoraire;
      } else if (heures <= 10) {
        salaire =
            (8 * tech.tauxHoraire) + ((heures - 8) * tech.tauxHoraire * 1.25);
      } else {
        salaire =
            (8 * tech.tauxHoraire) +
            (2 * tech.tauxHoraire * 1.25) +
            ((heures - 10) * tech.tauxHoraire * 1.5);
      }

      return sum + salaire;
    });

    return budgetMateriaux + budgetMainOeuvre;
  }

  double getBudgetTotalPrev(
    List<Technicien> techniciens,
    MainOeuvre mainOeuvre,
  ) {
    final double budgetMateriaux = pieces.fold(
      0,
      (sum, p) => sum + p.getBudgetTotalSansMainOeuvre(),
    );

    final double budgetMainOeuvre = techniciens.fold(0, (sum, tech) {
      if (tech.id.isEmpty) return sum;

      final heures = mainOeuvre.heuresEstimees;

      double salaire = 0;

      if (heures == 8) {
        salaire = heures * tech.tauxHoraire;
      }

      return sum + salaire;
    });

    return budgetMateriaux + budgetMainOeuvre;
  }
}
