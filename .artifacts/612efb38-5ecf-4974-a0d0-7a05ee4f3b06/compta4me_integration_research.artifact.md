# Recherche : Intégration de Compta4me dans l'Écosystème BTP 4.0

L'application **Compta4me** est le pilier financier de l'écosystème. Son intégration dans le Monorepo Melos permettra une convergence technique totale avec BatTrack.

## 📊 État des Lieux (Audit Rapide)

- **SDK Flutter :** Utilisé en version `^3.11.0` (plus ancienne que BatTrack `3.47.1`).
- **Gestion des Modèles :** Ne dépend pas encore de `shared_models`. Utilise ses propres définitions locales.
- **Stockage Local :** Utilise `hive` et `sqflite`.
- **Architecture :** Semble suivre une structure Clean Architecture (`domain`, `data`, `presentation`).

## 🎯 Opportunités de Convergence

1.  **Migration vers `shared_models`** :
    *   Extraire les modèles `Client`, `User`, et `Facture` de Compta4me vers `shared_models`.
    *   Assurer que BatTrack et Compta4me partagent les mêmes définitions d'entités financières (nécessaire pour la conformité ISCA).
2.  **Alignement Technologique** :
    *   Mettre à jour le SDK vers `3.13+` (comme BatTrack).
    *   Passer de `hive` à `hive_ce` pour l'unification des générateurs.
3.  **Partage du "Core Financial Engine"** :
    *   Le moteur de TVA ADEME et le service d'audit ISCA créés dans BatTrack peuvent être déplacés vers un package `core_btp` ou `shared_models` pour être utilisés par Compta4me.

## 🏗️ État de la Migration Melos

1.  **Lien Local Établi** : `compta4me` a été ajouté au workspace Melos et dépend maintenant de `shared_models` via un chemin local.
2.  **Synchronisation Réussie** : La commande `melos bootstrap` a lié avec succès les 4 piliers de l'écosystème.
3.  **Correctifs Appliqués** :
    *   Mise à jour de `flutter_stripe` vers `^14.0.0` dans Compta4me pour assurer la compatibilité avec les versions récentes de Freezed.
    *   Alignement des versions de `json_annotation` dans `shared_models`.

## 🚀 Prochaines étapes de Convergence

1.  **Portage ISCA** : Utiliser le `IscalAuditService` de BatTrack dans Compta4me pour sceller les écritures comptables.
2.  **Unified Models** : Remplacer les définitions locales de `Client` dans Compta4me par l'entité `Client` de `shared_models`.
3.  **Moteur de TVA** : Intégrer l'`AdemeTvaEngine` pour automatiser les calculs de TVA écologique dans les factures comptables.

## 🛡️ Risques
- Différences de schémas JSON entre les deux applications.
- Conflits de versions de packages tiers (Riverpod, Dio).

---

**Souhaitez-vous que je commence par ajouter `shared_models` à Compta4me et que je tente une première synchronisation via Melos ?**
