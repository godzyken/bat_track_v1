import 'package:bat_track_v1/data/local/models/chantiers/extensions_chantier.dart';

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
    MainOeuvre mainOeuvre,
  ) {
    return etape.getBudgetTotalPrev(techniciens, mainOeuvre);
  }

  static double budgetRestant(
    Client client,
    List<ChantierEtape> etapes,
    List<Technicien> techniciens,
    MainOeuvre mainOeuvre,
  ) {
    final totalConsomme = etapes.fold(
      0.0,
      (total, e) => total + e.getBudgetTotalReel(techniciens, mainOeuvre),
    );
    return client.budgetPrevu! - totalConsomme;
  }

  static bool estEtapeDansBudget(
    Client client,
    ChantierEtape nouvelleEtape,
    List<ChantierEtape>? autresEtapes,
    List<Technicien> techniciens,
    MainOeuvre mainOeuvre,
  ) {
    final totalAvecNouvelle =
        autresEtapes!.fold(
          0.0,
          (total, e) => total + e.getBudgetTotalPrev(techniciens, mainOeuvre),
        ) +
        nouvelleEtape.getBudgetTotalPrev(techniciens, mainOeuvre);

    return totalAvecNouvelle <= client.budgetPrevu!;
  }
}
