import 'package:shared_models/shared_models.dart';

import '../../../../data/local/models/index_model_extention.dart';

class BudgetGen {
  static double calculerTotal({
    required double surface,
    required List<Materiau> materiaux,
    required List<Materiel> materiels,
    required List<MainOeuvre> mainOeuvre,
    required List<Technicien> techniciens,
  }) {
    final totalMateriaux = calculerCoutMateriaux(materiaux, surface: surface);
    final totalMateriels = calculerCoutMateriels(materiels);
    final totalMainOeuvre = estimationCoutTotalMainOeuvre(
      mainOeuvre,
      techniciens,
    );

    return totalMateriaux + totalMateriels + totalMainOeuvre;
  }

  static Map<String, double> calculerDetails({
    required double surface,
    required List<Materiau> materiaux,
    required List<Materiel> materiels,
    required List<MainOeuvre>? mainOeuvre,
    required List<Technicien> techniciens,
  }) {
    final totalMateriaux = calculerCoutMateriaux(materiaux, surface: surface);
    final totalMateriels = calculerCoutMateriels(materiels);
    final totalMainOeuvre = mainOeuvre != null
        ? estimationCoutTotalMainOeuvre(mainOeuvre, techniciens)
        : 0.0;

    return {
      'Matériaux': totalMateriaux,
      'Matériel': totalMateriels,
      'Main-d’œuvre': totalMainOeuvre,
    };
  }

  static double calculerTotalPartielSansMainOeuvre({
    required double surface,
    required List<Materiau> materiaux,
    required List<Materiel> materiels,
  }) {
    final totalMateriaux = calculerCoutMateriaux(materiaux, surface: surface);
    final totalMateriels = calculerCoutMateriels(materiels);

    return totalMateriaux + totalMateriels;
  }

  static Map<String, double> calculerTotalDetailPartielSansMainOeuvre({
    required double surface,
    required List<Materiau> materiaux,
    required List<Materiel> materiels,
  }) {
    final totalMateriaux = calculerCoutMateriaux(materiaux, surface: surface);
    final totalMateriels = calculerCoutMateriels(materiels);

    return {'materiaux': totalMateriaux, 'materiels': totalMateriels};
  }

  static double calculerCoutMateriaux(
    List<Materiau> materiaux, {
    required double surface,
  }) {
    return materiaux.fold(0.0, (sum, m) {
      final quantite = m.quantiteFixe ?? (m.coefficientSurface ?? 0) * surface;
      return sum + (quantite * m.prixUnitaire);
    });
  }

  static double calculerCoutMateriels(List<Materiel> materiels) {
    return materiels.fold(0.0, (sum, m) {
      if (m.joursLocation == 0) {
        return sum + (m.prixUnitaire * m.quantiteFixe);
      }
      return calculerCoutLocationMateriels(materiels);
    });
  }

  static double calculerCoutLocationMateriels(List<Materiel> materiels) {
    return materiels.fold(
      0.0,
      (sum, m) => sum + (m.prixLocation! * m.joursLocation!),
    );
  }

  static double estimationCoutTotalMainOeuvre(
    List<MainOeuvre> mainOeuvres,
    List<Technicien> techniciens,
  ) {
    return mainOeuvres.fold(0.0, (total, mo) {
      final tech = techniciens.firstWhere(
        (t) => t.id == mo.idTechnicien,
        orElse: () =>
            throw Exception('Technicien introuvable pour ${mo.idTechnicien}'),
      );
      return total + (tech.tauxHoraire * mo.heuresEstimees);
    });
  }

  static double calculerTotalMulti({
    required double surface,
    required List<Materiau> materiaux,
    required List<Materiel> materiels,
    required List<MainOeuvre> mainOeuvre,
    required List<Technicien> techniciens,
  }) {
    final totalMateriaux = calculerCoutMateriaux(materiaux, surface: surface);
    final totalMateriels = calculerCoutMateriels(materiels);

    final totalMainOeuvre = mainOeuvre.fold(0.0, (sum, m) {
      final tech = techniciens.firstWhere(
        (t) => t.id == m.idTechnicien,
        orElse: () => Technicien.mock(),
      );
      return sum + (m.heuresEstimees * tech.tauxHoraire);
    });

    return totalMateriaux + totalMateriels + totalMainOeuvre;
  }
}
