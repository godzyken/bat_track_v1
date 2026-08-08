# Plan de réparation des tests

Le passage à Riverpod 3.0 et les changements dans `shared_models` (UnifiedModel) ont cassé la suite de tests. Ce plan vise à migrer les tests vers les outils natifs de Riverpod 3.0 et à mettre à jour les mocks.

## User Review Required

> [!IMPORTANT]
> Je vais supprimer toute dépendance à `riverpod_test` au profit des utilitaires natifs de Riverpod 3.0 (`ProviderContainer.test()`). Cela change légèrement la structure de certains tests mais les rend plus robustes et compatibles.

## Proposed Changes

### [Dependencies]

#### [MODIFY] [pubspec.yaml](file:///C:/Users/soufi/StudioProjects/bat_track_v1/pubspec.yaml)
- S'assurer que `riverpod_test` est bien retiré (déjà fait, mais vérification).

### [Mocks & Helpers]

#### [MODIFY] [mock_services.dart](file:///C:/Users/soufi/StudioProjects/bat_track_v1/test/mocks/mock_services.dart)
- Mettre à jour les mocks pour utiliser `UnifiedEntityServiceImpl` au lieu de l'interface abstraite.

#### [MODIFY] [provider_test_helpers.dart](file:///C:/Users/soufi/StudioProjects/bat_track_v1/test/helpers/provider_test_helpers.dart)
- Retirer l'import de `riverpod_test`.
- Réimplémenter les helpers en utilisant `ProviderContainer`.

### [Test Suites Migration]

#### [MODIFY] [projet_list_provider_test.dart](file:///C:/Users/soufi/StudioProjects/bat_track_v1/test/features/projet/controllers/providers/projet_list_provider_test.dart)
- Remplacer `testProvider` par des blocs `test()` standard avec `ProviderContainer`.

#### [MODIFY] [synced_entity_service_test.dart](file:///C:/Users/soufi/StudioProjects/bat_track_v1/test/unit/services/synced_entity_service_test.dart)
- Corriger l'instanciation de `UnifiedEntityService` (utiliser l'implémentation concrète).
- Mettre à jour les appels de méthodes (ex: `save` au lieu de `create`).

## Verification Plan

### Automated Tests
- Exécution de `flutter analyze` pour vérifier que le dossier `test/` est propre.
- Exécution sélective de certains tests avec `flutter test test/path/to/test.dart`.
