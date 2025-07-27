import 'package:bat_track_v1/data/local/models/index_model_extention.dart';
import 'package:uuid/uuid.dart';

extension FactureDraftBuilder on FactureDraft {
  FactureDraft populateFromChantier(
    Chantier chantier,
    List<Technicien> techniciens,
  ) {
    final lignes = <CustomLigneFacture>[];

    final techList = chantier.getTechniciens(techniciens);

    for (final etape in chantier.etapes) {
      final montant = etape.pieces
          .where((p) => p.mainOeuvre != [])
          .fold<double>(
            0.0,
            (sum, p) => sum + (p.getBudgetTotalSansMainOeuvre() ?? 0),
          );

      final coutMainOeuvre = etape.pieces
          .where((p) => p.mainOeuvre != [])
          .fold<double>(
            0.0,
            (sum, p) => sum + (p.getBudgetTotal(techList) ?? 0),
          );

      lignes.add(
        CustomLigneFacture(
          ctlId: const Uuid().v4(),
          description: 'Étape : ${etape.titre}',
          montant: montant,
          quantite: 1,
          total: coutMainOeuvre + montant,
          ctlUpdatedAt: DateTime.now(),
        ),
      );
    }

    final interventions = chantier.interventions ?? [];

    for (final intervention in interventions) {
      final montant = intervention.facture;
      lignes.add(
        CustomLigneFacture(
          ctlId: const Uuid().v4(),
          description:
              'Intervention : ${intervention.titre ?? intervention.description}',
          montant: montant?.totalHT ?? 0,
          quantite: 1,
          total: montant?.totalTTC ?? 0,
          ctlUpdatedAt: DateTime.now(),
        ),
      );
    }

    return copyWith(
      chantierId: chantierId,
      factureId: factureId,
      lignesManuelles: lignes,
      dateDerniereModification: DateTime.now(),
    );
  }
}

extension ChantierTechniciensExt on Chantier {
  List<Technicien> getTechniciens(List<Technicien> allTechs) {
    return allTechs.where((t) => technicienIds.contains(t.id)).toList();
  }
}

extension ChantierBudgetExt on Chantier {
  List<MainOeuvre> getManoeuvres(
    List<MainOeuvre> allManoeuvres,
    List<Technicien> techniciens,
  ) {
    final techs = getTechniciens(techniciens);
    for (final t in techs) {
      return allManoeuvres.where((m) => t.id == m.idTechnicien).toList();
    }
    return [];
  }

  double getTotalBudgetWithTech(List<Piece> pieces, List<Technicien> allTechs) {
    final techList = getTechniciens(allTechs);

    return pieces.fold<double>(
      0.0,
      (sum, p) => sum + p.getBudgetTotal(techList),
    );
  }

  List<double> getTotalBudgetPieces(List<Piece> piece) {
    final pieces = piece.where((p) => p.surface != 0).toList();
    final totalBudgetList = <double>[];
    for (final p in pieces) {
      totalBudgetList.add(p.getBudgetTotalSansMainOeuvre());
    }

    return totalBudgetList;
  }

  List<double> getTotalBudgetManoeuvres(
    List<MainOeuvre> manoeuvres,
    List<Technicien> allTechs,
  ) {
    final scoreList = getManoeuvres(manoeuvres, allTechs);
    final totalBudgetList = <double>[];
    for (final s in scoreList) {
      totalBudgetList.add(s.heuresEstimees);
    }

    return totalBudgetList;
  }
}
