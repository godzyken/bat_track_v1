# Tâches : Convergence BTP 4.0 \u0026 Équipement AI Template

- `[x]` **Phase 0 : Équipement AI Template**
    - `[x]` Remplir `.ai/PROJECT.md` avec l\u0027identité BatTrack
    - `[x]` Remplir `.ai/ARCHITECTURE.md` (Feature-First)
    - `[x]` Déplacer les briques AI (AGENTS.md, .ai, .mcp, .agents) à la racine
    - `[x]` Fusionner les workflows GitHub (ci.yml, release.yml)

- `[x]` **Phase 1 : Core Financial Engine (ISCA/ADEME)**
    - `[x]` Créer `iscal_audit_service.dart` (Portage Compta4me)
    - `[x]` Créer `ademe_tva_engine.dart` (Logique écologique)
- `[x]` **Phase 2 : Data Integration**
    - `[x]` Intercepter les sauvegardes de factures dans `entity_sync_services.dart`
    - `[x]` Implémenter le verrouillage des périodes clôturées (FiscalClosureNotifier)
- `[x]` **Phase 3 : UI & Conformité**
    - `[x]` Ajouter l\u0027indicateur de scellé dans `factures_screen.dart`
    - `[x]` Mise à jour du `dashboard_screen.dart` avec les projections de trésorerie
- `[x]` **Phase 4 : Validation**
    - `[x]` Créer les tests unitaires d\u0027intégrité de la chaîne
    - `[x]` Créer les tests d\u0027intégration (BTP 4.0 flow)
    - `[x]` Vérification `flutter analyze` globale finale
