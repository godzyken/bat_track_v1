# Changelog

Toutes les modifications notables de ce projet sont documentées dans ce fichier.

Format : [Keep a Changelog](https://keepachangelog.com/fr/1.0.0/)
Versioning : [Semantic Versioning](https://semver.org/lang/fr/)

---

## [1.1.0+2] — 2026-11-15

### Fixed — Synchronisation des modèles (`shared_models`)

- **`model_registry.dart`** : Correction de `Projet.mock` → `ProjetMock.mock` (extension correcte).
- **`projet_adapter.dart`** : Ajout du paramètre requis `clientId` dans `toJson`, `fromJson` et `fields`.
- **`projet_entity.dart`** : Ajout de `clientId: ''` dans `toModel()`.
- **`chantier_entity.dart`** : Remplacement de l'import cassé `../chantiers/chantier.dart` par `package:shared_models/shared_models.dart`.
- **`chantier_etapes_entity.dart`** : Alignement de `dateDebut`/`dateFin` en `DateTime?` ; `budget: budget ?? 0.0`.
- **`equipement_entity.dart`** : Alignement complet sur le nouveau modèle `Equipement` (`marque`, `modele`, `numeroSerie`, `dateInstallation`, `dateDerniereMaintenance`) — suppression des champs obsolètes (`type`, `createdBy`, `technicienIds`, `localisation`, `homologation`, `enService`, `commentaire`).
- **`intervention_entity.dart`** : Migration de `technicienId` → `technicienIds (List<String>)` ; suppression de `company`, `statut`, `document`.
- **`main_oeuvre_entity.dart`** : Remplacement de l'import cassé ; alignement sur `heuresEstimees`/`heuresReelles` — suppression de `dateDebut`, `passedTime`, `isActive`.
- **`materiau_entity.dart`** : Conversion `quantiteFixe` (`bool` ↔ `double` Hive) ; gestion de la nullabilité de `unite` et `coefficientSurface`.
- **`materiel_entity.dart`** : Conversion `quantiteFixe` (`bool` ↔ `double` Hive) ; valeurs par défaut pour `prixLocation`/`joursLocation`.
- **`piece_entity.dart`** : Remplacement de `validatedByTech` par `techniciensValides` ; gestion de `addedBy` nullable.
- **`pieces_jointes_entity.dart`** : Gestion de `taille` nullable (`taille ?? 0.0`) et `type`.
- **`client_entity.dart`** : Suppression du `@override` invalide sur la factory `fromModel`.

### Added

- **`docs/`** : Suite de documentation complète (5 fichiers) couvrant l'architecture, les fonctionnalités, les requêtes API, le design system et le guide de déploiement.

---

## [1.0.0+1] — Initial Release

- Première version publique du projet BatTrack v1.
- Architecture Clean / Feature-First avec Riverpod 3.
- Moteur fiscal ISCA (hash-chaining SHA-256).
- AdemeTvaEngine (TVA 5.5 %, 10 %, 20 %).
- Moteur de projection de trésorerie (`ProjectionEngine`).
- Backend hybride Firebase / Supabase / Cloudflare.
- Synchronisation offline-first Hive CE.
- Bridge Dolibarr ERP (REST).
- Synchronisation catalogue Google Sheets API v4.
