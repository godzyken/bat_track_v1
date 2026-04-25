import 'package:shared_models/shared_models.dart';

import '../index_model_extention.dart';

/// Extension centralisée pour les calculs budgétaires
extension BudgetCalculations on Piece {
  /// Calcul du budget total avec main d'œuvre
  double calculerBudgetTotal(List<Technicien> techniciens) {
    final budgetMateriaux = _calculerBudgetMateriaux();
    final budgetMateriels = _calculerBudgetMateriels();
    final budgetMainOeuvre = _calculerBudgetMainOeuvre(techniciens);

    return budgetMateriaux + budgetMateriels + budgetMainOeuvre;
  }

  /// Calcul du budget sans main d'œuvre
  double calculerBudgetSansMainOeuvre() {
    return _calculerBudgetMateriaux() + _calculerBudgetMateriels();
  }

  /// Répartition du budget par catégorie
  Map<String, double> obtenirRepartitionBudget(List<Technicien> techniciens) {
    final mat = _calculerBudgetMateriaux();
    final matl = _calculerBudgetMateriels();
    final mo = _calculerBudgetMainOeuvre(techniciens);

    return {'Matériaux': mat, 'Matériel': matl, 'Main d\'œuvre': mo};
  }

  /// Ratio du budget par catégorie (pourcentages)
  Map<String, double> obtenirRatioBudget(List<Technicien> techniciens) {
    final repartition = obtenirRepartitionBudget(techniciens);
    final total = repartition.values.fold(0.0, (a, b) => a + b);

    if (total == 0) return {};

    return repartition.map((k, v) => MapEntry(k, v / total));
  }

  // Méthodes privées
  double _calculerBudgetMateriaux() {
    return materiaux?.fold(0.0, (sum, m) => sum! + m.prixTotal) ?? 0.0;
  }

  double _calculerBudgetMateriels() {
    return materiels?.fold(0.0, (sum, m) => sum! + m.prixTotal) ?? 0.0;
  }

  double _calculerBudgetMainOeuvre(List<Technicien> techniciens) {
    return mainOeuvre?.fold(0.0, (sum, mo) {
          final tech = techniciens.firstWhere(
            (t) => t.id == mo.idTechnicien,
            orElse: () => Technicien.mock(),
          );
          return sum! +
              _calculerCoutHeures(mo.heuresEstimees, tech.tauxHoraire);
        }) ??
        0.0;
  }

  double _calculerCoutHeures(double heures, double tauxHoraire) {
    if (heures <= 8) {
      return heures * tauxHoraire;
    } else if (heures <= 10) {
      return (8 * tauxHoraire) + ((heures - 8) * tauxHoraire * 1.25);
    } else {
      return (8 * tauxHoraire) +
          (2 * tauxHoraire * 1.25) +
          ((heures - 10) * tauxHoraire * 1.5);
    }
  }
}

/// Extension pour ChantierEtape
extension ChantierEtapeBudgetCalculations on ChantierEtape {
  double calculerBudgetTotalReel(
    List<Technicien> techniciens,
    MainOeuvre mainOeuvre,
  ) {
    final budgetMateriaux = pieces.fold(
      0.0,
      (sum, p) => sum + p.calculerBudgetSansMainOeuvre(),
    );

    final budgetMainOeuvre = techniciens.fold(0.0, (sum, tech) {
      if (tech.id.isEmpty) return sum;
      return sum +
          _calculerSalaire(mainOeuvre.heuresEstimees, tech.tauxHoraire);
    });

    return budgetMateriaux + budgetMainOeuvre;
  }

  double _calculerSalaire(double heures, double tauxHoraire) {
    if (heures <= 8) {
      return heures * tauxHoraire;
    } else if (heures <= 10) {
      return (8 * tauxHoraire) + ((heures - 8) * tauxHoraire * 1.25);
    } else {
      return (8 * tauxHoraire) +
          (2 * tauxHoraire * 1.25) +
          ((heures - 10) * tauxHoraire * 1.5);
    }
  }
}

/// Extension pour Chantier
extension ChantierBudgetCalculations on Chantier {
  double calculerBudgetTotalPieces(List<Technicien> techniciens) {
    return etapes.fold(0.0, (sum, etape) {
      return sum +
          etape.pieces.fold(0.0, (pieceSum, piece) {
            return pieceSum + piece.calculerBudgetTotal(techniciens);
          });
    });
  }

  List<Technicien> obtenirTechniciens(List<Technicien> tousLesTechniciens) {
    return tousLesTechniciens
        .where((t) => technicienIds.contains(t.id))
        .toList();
  }

  double calculerBudgetInterventions() {
    return interventions.fold(0.0, (sum, intervention) {
      return sum + (intervention.facture?.totalTTC ?? 0.0);
    });
  }

  double calculerBudgetTotal(List<Technicien> techniciens) {
    return calculerBudgetTotalPieces(techniciens) +
        calculerBudgetInterventions();
  }
}

/// Extension utilitaire pour le mixin ValidationMixin
extension ValidationHelper on ValidationMixin {
  /// Méthode statique réutilisable pour vérifier les statuts
  static bool computeValidationStatus({
    required bool clientValide,
    required bool chefDeProjetValide,
    required bool techniciensValides,
    required bool superUtilisateurValide,
  }) {
    return clientValide &&
        chefDeProjetValide &&
        techniciensValides &&
        superUtilisateurValide;
  }
}
