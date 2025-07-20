import 'package:bat_track_v1/data/local/models/index_model_extention.dart';

extension FactureDraftBuilder on FactureDraft {
  FactureDraft populateFromChantier(
    Chantier chantier,
    List<Technicien> techniciens,
  ) {
    final lignes = <CustomLigneFacture>[];

    final techList = chantier.getTechniciens(techniciens);

    for (final etape in chantier.etapes) {
      final montant = etape.pieces
          .where((p) => p.mainOeuvre != 0)
          .fold<double>(
            0.0,
            (sum, p) => sum + (p.getBudgetTotalSansMainOeuvre() ?? 0),
          );

      final coutMainOeuvre = etape.pieces
          .where((p) => p.mainOeuvre != 0)
          .fold<double>(
            0.0,
            (sum, p) => sum + (p.getBudgetTotal(techList) ?? 0),
          );

      lignes.add(
        CustomLigneFacture(
          description: 'Étape : ${etape.titre}',
          montant: montant,
          quantite: 1,
          total: coutMainOeuvre + montant,
        ),
      );
    }

    final interventions = chantier.interventions ?? [];

    for (final intervention in interventions) {
      final montant = intervention.facture;
      lignes.add(
        CustomLigneFacture(
          description:
              'Intervention : ${intervention.titre ?? intervention.description}',
          montant: montant?.totalHT ?? 0,
          quantite: 1,
          total: montant?.totalTTC ?? 0,
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
