import '../../../../data/local/models/index_model_extention.dart';

class BudgetGen {
  static double calculerTotal({
    required double surface,
    required List<Materiau> materiaux,
    required List<Materiel> materiels,
    required MainOeuvre mainOeuvre,
    required List<Technicien> techniciens,
  }) {
    final totalMateriaux = calculerCoutMateriaux(materiaux, surface: surface);
    final totalMateriels = calculerCoutMateriels(materiels);
    final totalMainOeuvre = calculerCoutMainOeuvre(mainOeuvre, techniciens);

    return totalMateriaux + totalMateriels + totalMainOeuvre;
  }

  static Map<String, double> calculerDetails({
    required double surface,
    required List<Materiau> materiaux,
    required List<Materiel> materiels,
    required MainOeuvre? mainOeuvre,
    required List<Technicien> techniciens,
  }) {
    final totalMateriaux = calculerCoutMateriaux(materiaux, surface: surface);
    final totalMateriels = calculerCoutMateriels(materiels);
    final totalMainOeuvre =
        mainOeuvre != null
            ? calculerCoutMainOeuvre(mainOeuvre, techniciens)
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
    return materiels.fold(
      0.0,
      (sum, m) => sum + (m.prixLocation! * m.joursLocation!),
    );
  }

  static double calculerCoutMainOeuvre(
    MainOeuvre mainOeuvre,
    List<Technicien> techniciens,
  ) {
    final tech = techniciens.firstWhere(
      (t) => t.id == mainOeuvre.idTechnicien,
      orElse: () => throw Exception('Technicien introuvable'),
    );
    return tech.tauxHoraire * mainOeuvre.heuresEstimees;
  }
}
