import '../../data/local/models/index_model_extention.dart';

/// Moteur de calcul financier intégrant les spécificités ADEME (TVA Réduite / Écologie).
class AdemeTvaEngine {
  /// Taux de TVA standard en France
  static const double standardRate = 0.20;

  /// Taux de TVA réduit pour les travaux de rénovation énergétique (ADEME)
  static const double ecoRenovationRate = 0.055;

  /// Taux de TVA intermédiaire pour les travaux de rénovation simple
  static const double intermediateRate = 0.10;

  /// Détermine le taux de TVA applicable selon la catégorie de produit et le contexte ADEME.
  static double getApplicableRate(
    Produit produit, {
    bool isEcoRenovation = false,
  }) {
    // Si le produit a un impact carbone faible ou des certifications vertes, on peut forcer le taux réduit
    if (isEcoRenovation || _isEcoFriendly(produit)) {
      return ecoRenovationRate;
    }

    return produit.tauxTVA != null ? produit.tauxTVA! / 100 : standardRate;
  }

  /// Logique simplifiée pour détecter un produit éligible aux aides ADEME
  static bool _isEcoFriendly(Produit produit) {
    final List<String> certs = produit.certifications ?? [];

    final bool hasEcoLabel = certs.any(
      (String c) =>
          c.toUpperCase().contains('HQE') || c.toUpperCase().contains('RT2020'),
    );
    final bool hasLowCarbon =
        (produit.impactCarbone ?? 100) < 50; // Seuil arbitraire pour l'exemple

    return hasEcoLabel || hasLowCarbon;
  }

  /// Calcule le montant TTC incluant l'avantage écologique.
  static double calculateTtc(double amountHt, double tvaRate) {
    return amountHt * (1 + tvaRate);
  }
}
