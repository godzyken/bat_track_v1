import 'package:shared_models/shared_models.dart';
import '../../data/local/models/chantiers/chantier.dart';

class CashflowProjection {
  final double currentRevenue;
  final double potentialRevenue;
  final double pendingInvoices;
  final int completedStages;
  final int totalStages;

  CashflowProjection({
    required this.currentRevenue,
    required this.potentialRevenue,
    required this.pendingInvoices,
    required this.completedStages,
    required this.totalStages,
  });

  double get completionRate =>
      totalStages > 0 ? completedStages / totalStages : 0.0;
}

class ProjectionEngine {
  /// Calcule les projections financières basées sur les chantiers et factures.
  static CashflowProjection calculate(
    List<Chantier> chantiers,
    List<Facture> factures,
  ) {
    double currentRevenue = 0.0;
    double pendingInvoices = 0.0;
    int completedStages = 0;
    int totalStages = 0;

    // 1. Calcul via les factures
    for (final f in factures) {
      if (f.toutesPartiesOntValide) {
        currentRevenue += f.montant;
      } else {
        pendingInvoices += f.montant;
      }
    }

    // 2. Calcul du potentiel via les étapes de chantier
    double potentialRevenue = currentRevenue + pendingInvoices;

    for (final c in chantiers) {
      totalStages += c.etapes.length;
      for (final e in c.etapes) {
        if (e.terminee) {
          completedStages++;
        }
      }
    }

    return CashflowProjection(
      currentRevenue: currentRevenue,
      potentialRevenue: potentialRevenue,
      pendingInvoices: pendingInvoices,
      completedStages: completedStages,
      totalStages: totalStages,
    );
  }
}
