# Plan d'Implémentation : Convergence BTP 4.0

Ce plan décrit les étapes pour injecter le "Core Financial Engine" (issu de Compta4me) dans BatTrack, tout en garantissant la conformité ISCA et l'intelligence écologique ADEME.

## 🛠️ Objectifs
1. **Convergence ISCA :** Intégrer le journal d'audit chaîné pour toutes les transactions financières (factures payées).
2. **Intelligence ADEME :** Automatiser le calcul de la TVA et de l'impact carbone sur les produits/matériaux.
3. **Moteur de Projection :** Activer les prévisions de trésorerie basées sur l'avancement des chantiers.

---

## 🏗️ Modifications Proposées

### 1. Core / Compliance (Injection du Moteur Financier)
- **[NEW]** `lib/core/compliance/iscal_audit_service.dart` : Porté depuis Compta4me. Gère le hash-chaining SHA-256 des factures.
- **[NEW]** `lib/core/financial_engine/ademe_tva_engine.dart` : Logique de calcul fiscal écologique.

### 2. Data / Services (Automatisation de la Conformité)
#### [MODIFY] [entity_sync_services.dart](file:///C:/Users/soufi/StudioProjects/bat_track_v1/lib/models/services/entity_sync_services.dart)
- Intercepter `save()` pour les entités `Facture`.
- Déclencher `logTransaction()` dans le `FiscalAuditService` dès qu'une facture est marquée comme `payée`.
- Empêcher toute modification locale si la période est clôturée.

### 3. Features / Documents (Signatures et Scellés)
#### [MODIFY] [factures_screen.dart](file:///C:/Users/soufi/StudioProjects/bat_track_v1/lib/features/documents/views/screens/factures_screen.dart)
- Ajouter un indicateur visuel de "Scellé Numérique" (Chaîne d'intégrité verte).
- Intégrer le bouton de paiement Stripe avec signature immédiate à la volée.

### 4. Features / Dashboard (Projections)
#### [MODIFY] [dashboard_screen.dart](file:///C:/Users/soufi/StudioProjects/bat_track_v1/lib/features/dashboard/views/screens/dashboard_screen.dart)
- Injecter le `ProjectionEngine` pour afficher le "Reste à Recouvrer" et le "Potentiel de CA" basé sur les étapes de chantier validées.

---

## 🛡️ Vérification Plan

### Tests Automatisés
- `test/unit/compliance/isca_integrity_test.dart` : Vérifier que briser un hash invalide la chaîne.
- `test/unit/financial/ademe_tva_test.dart` : Valider les calculs de TVA selon les catégories ADEME.

### Manuel
- Générer une facture -> La payer -> Vérifier que le bouton "Editer" disparaît (Inaltérabilité).
- Vérifier la présence du hash SHA-256 dans les logs techniques de l'application.

---

## ⚠️ Point d'attention : ZÉRO ERREUR
- Toutes les nouvelles classes utiliseront des **imports relatifs**.
- Un `flutter analyze` sera lancé après chaque injection de brique.
