# Tasks: BatTrack

## Completed Sprints
- [x] **Convergence BTP 4.0 Core**
    - [x] IscalAuditService (SHA-256)
    - [x] AdemeTvaEngine
    - [x] Cashflow Projection Engine
- [x] **Équipement AI**
    - [x] AGENTS.md Protocol
    - [x] ARCHITECTURE.md Documentation
    - [x] CI/CD Alignment (GitHub Actions)
- [x] **Release v1.0.4**
    - [x] Git tagging and push
    - [x] Firebase dummy options generation in CI
- [x] fix(ci): Disable local dependency_overrides for shared_models.
- [x] **Release v1.1.0** — Synchronisation modèles shared_models
    - [x] Correction model_registry.dart (ProjetMock.mock)
    - [x] Correction projet_adapter.dart (clientId requis)
    - [x] Correction chantier_entity.dart (import shared_models)
    - [x] Correction chantier_etapes_entity.dart (DateTime?, budget)
    - [x] Correction equipement_entity.dart (nouveau modèle Equipement)
    - [x] Correction intervention_entity.dart (technicienIds)
    - [x] Correction main_oeuvre_entity.dart (heuresEstimees/Reelles)
    - [x] Correction materiau_entity.dart (quantiteFixe bool↔double)
    - [x] Correction materiel_entity.dart (quantiteFixe bool↔double)
    - [x] Correction piece_entity.dart (techniciensValides)
    - [x] Correction pieces_jointes_entity.dart (taille nullable)
    - [x] Correction client_entity.dart (@override invalide)
    - [x] Documentation complète dans docs/ (5 fichiers)
    - [x] CHANGELOG.md créé
    - [x] Version montée à 1.1.0+2

## Pending
- [ ] Ecosystem Synchronization
    - [ ] Port `Core Financial Engine` to Compta4me and EGOTe.
- [ ] **Maintenance**
    - [ ] Monitor GitHub Actions results.
- [ ] flutter analyze — vérification complète post-sync
- [ ] flutter test — validation tests unitaires post-sync
