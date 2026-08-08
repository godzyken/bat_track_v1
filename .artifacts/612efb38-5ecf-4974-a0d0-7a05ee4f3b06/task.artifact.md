# Tasks - Réparation Bat_Track_V1

- [x] Nettoyage de `lib/data/local/models/projets/projet.dart`
- [x] Mise à jour de `pubspec.yaml`
- [x] Exécution de `flutter pub get`
- [x] Génération de code avec `build_runner`
- [x] Correction des implémentations de `UnifiedModel` (AccessControl & Validation)
- [x] Correction de `lib/core/services/google_sheets_product_service.dart`
- [x] Désactivation temporaire de Firebase dans `main.dart`
- [x] Vérification finale avec `flutter analyze`
- [x] Implémentation Offline-First
    - [x] Configuration de la persistance Firestore dans `firebase_providers.dart`
    - [x] Optimisation de `EntitySyncService` pour la sauvegarde locale immédiate
    - [x] Gestion de la file d'attente d'upload des fichiers (Retry logic)
    - [x] Widget indicateur de statut de synchronisation
