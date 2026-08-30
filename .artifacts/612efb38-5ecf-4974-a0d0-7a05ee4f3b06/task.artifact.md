# Tâches : Convergence BTP 4.0

- `[x]` **Phase 1 : Core Financial Engine (ISCA/ADEME)**
    - `[x]` Créer `iscal_audit_service.dart` (Portage Compta4me)
    - `[x]` Créer `ademe_tva_engine.dart` (Logique écologique)
- `[x]` **Phase 2 : Data Integration**
    - `[x]` Intercepter les sauvegardes de factures dans `entity_sync_services.dart`
    - `[x]` Implémenter le verrouillage des périodes clôturées (FiscalClosureNotifier)
- `[x]` **Phase 3 : UI & Conformité**
    - `[x]` Ajouter l\u0027indicateur de scellé dans `factures_screen.dart`
    - `[x]` Mise à jour du `dashboard_screen.dart` avec les projections de trésorerie
- `[/]` **Phase 4 : Validation**
    - `[x]` Créer les tests unitaires d\u0027intégrité de la chaîne
    - `[ ]` Vérification `flutter analyze` globale finale
