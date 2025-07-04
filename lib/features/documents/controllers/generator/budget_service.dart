import '../../../../data/local/models/index_model_extention.dart';

class BudgetService {
  static double calculerBudgetTotal(
    List<Piece> pieces,
    List<Technicien> techniciens,
  ) {
    return pieces.fold(
      0.0,
      (total, piece) => total + piece.getBudgetTotal(techniciens),
    );
  }

  static double calculerBudgetEtape(
    ChantierEtape etape,
    List<Technicien> techniciens,
  ) {
    return etape.getBudgetTotal(techniciens);
  }

  static double budgetRestant(
    Client client,
    List<ChantierEtape> etapes,
    List<Technicien> techniciens,
  ) {
    final totalConsomme = etapes.fold(
      0.0,
      (total, e) => total + e.getBudgetTotal(techniciens),
    );
    return client.budgetPrevu! - totalConsomme;
  }

  static bool estEtapeDansBudget(
    Client client,
    ChantierEtape nouvelleEtape,
    List<ChantierEtape>? autresEtapes,
    List<Technicien> techniciens,
  ) {
    final totalAvecNouvelle =
        autresEtapes!.fold(
          0.0,
          (total, e) => total + e.getBudgetTotal(techniciens),
        ) +
        nouvelleEtape.getBudgetTotal(techniciens);

    return totalAvecNouvelle <= client.budgetPrevu!;
  }
}
