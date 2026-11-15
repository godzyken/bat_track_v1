# 05. Guide de Déploiement, Tests & CI/CD

Ce document décrit les procédures de configuration de l'environnement, d'exécution des tests, de compilation et d'automatisation CI/CD pour **BatTrack v1**.

---

## 1. Prérequis Techniques

Pour cloner, compiler et déployer le projet, vous devez disposer des outils suivants :

- **Flutter SDK :** Version $\ge 3.24.0$ (compatible avec les environnements Flutter 3.47.x).
- **Dart SDK :** Version $\ge 3.5.0 < 4.0.0$ (compatible avec la suite 3.13.x).
- **Environnement d'exécution :** Android Studio ou Visual Studio Code avec les extensions Flutter/Dart officielles.
- **Java Development Kit (JDK) :** JDK 17 ou 21 (requis pour Gradle 8+ et Android SDK 34/35).
- **Dépendance partagée `shared_models` :** Située à la racine sœur `../shared_models` (contient les interfaces unifiées, les modèles immuables Freezed et le moteur cryptographique ISCA).

---

## 2. Configuration des Services Tiers

### 2.1 Configuration Firebase
1. Le projet utilise le fichier de configuration généré automatiquement : `lib/firebase_options.dart`.
2. Pour reconfigurer un nouveau projet Firebase :
   ```bash
   firebase login
   flutterfire configure
   ```
3. Vérifiez que les services suivants sont activés dans la console Firebase :
   - **Authentication :** Fournisseur « Email / Mot de passe ».
   - **Cloud Firestore :** Mode production avec index composites configurés.
   - **Firebase Storage :** Règles d'accès pour les dossiers `/chantiers/`.
   - **Firebase Crashlytics :** Suivi des plantages natifs.

### 2.2 Configuration Dolibarr ERP
L'application peut être reliée à une ou plusieurs instances Dolibarr :
- **URL de l'API :** `https://votre-domaine.com/api/index.php`
- **Clé API utilisateur :** Générée depuis la fiche utilisateur dans Dolibarr > Onglet « Utilisateur » > « Clé API ».
- La configuration se fait dynamiquement dans l'application via le sélecteur d'instances (`InstanceSelectorDialog`) ou par injection dans le provider `dolibarrConfigProvider`.

### 2.3 Configuration Google Sheets
Pour importer des catalogues de produits depuis Google Sheets :
1. Activez l'API **Google Sheets API v4** sur la console Google Cloud.
2. Créez un compte de service (*Service Account*) et téléchargez la clé JSON.
3. Partagez votre feuille de calcul Google Sheets avec l'adresse email du compte de service en lecture seule.
4. Renseignez l'identifiant du classeur (`spreadsheetId`) dans `GoogleSheetsProductService`.

### 2.4 Configuration Sentry (Télémétrie & Logs)
Pour le reporting d'erreurs en production, configurez la variable d'environnement ou le DSN dans `lib/main.dart` :
```dart
await SentryFlutter.init(
  (options) {
    options.dsn = 'https://votre-dsn@sentry.io/projet';
    options.tracesSampleRate = 1.0;
  },
  appRunner: () => runApp(...),
);
```

---

## 3. Cycle de Développement & Commandes Clés

### 3.1 Installation des Dépendances
```bash
flutter pub get
```

### 3.2 Génération du Code (Build Runner)
Le projet utilise `Freezed`, `json_serializable` et les adaptateurs `Hive CE` :
```bash
# Génération ponctuelle en supprimant les conflits
dart run build_runner build --delete-conflicting-outputs

# Mode écoute continue pendant le développement
dart run build_runner watch --delete-conflicting-outputs
```

### 3.3 Formatage et Analyse Statique du Code
Conformément aux règles de développement (`AGENTS.md`) :
```bash
# Formater tous les fichiers Dart
dart format .

# Analyser le projet pour détecter les anomalies et warnings
flutter analyze
```

---

## 4. Stratégie de Tests & Validation

La validation de l'application repose sur une double approche : tests unitaires métier et tests d'intégration complets.

### 4.1 Tests Unitaires & Composants
Situés dans le dossier `test/` :
- Tests des calculs de marge, TVA 5.5% / 10% / 20% (`AdemeTvaEngine`).
- Tests du chaînage cryptographique SHA-256 (`IscalAuditService.verifyChainIntegrity()`).
- Tests des adaptateurs de modèles et du registre `ModelRegistry`.

Exécution des tests unitaires :
```bash
flutter test
```

### 4.2 Test d'Intégration : Convergence BTP 4.0
Le test d'intégration situé dans `integration_test/btp_4_0_convergence_test.dart` valide le parcours critique de bout en bout :
1. Démarrage complet de l'application Flutter avec injection de l'arbre Riverpod.
2. Navigation vers le Dashboard intelligent.
3. Vérification de l'affichage des **Projections de Trésorerie** (Chiffre d'affaires potentiel et réalisé).
4. Validation de la présence et de l'état certifié de l'**Indicateur d'Intégrité Fiscale ISCA** (`Icons.verified_user`).

Exécution du test d'intégration sur émulateur ou device physique :
```bash
flutter test integration_test/btp_4_0_convergence_test.dart
```

---

## 5. Compilation & Déploiement

### 5.1 Android
```bash
# Compilation d'un APK de débogage pour test terrain immédiat
flutter build apk --debug

# Compilation d'un APK optimisé de production
flutter build apk --release

# Compilation d'un Android App Bundle (AAB) pour publication Google Play Store
flutter build appbundle --release
```

### 5.2 Application Web (Dashboard & Administration)
```bash
# Compilation Web optimisée
flutter build web --release --pwa-strategy=offline-first
```
Les fichiers générés dans `build/web/` peuvent être déployés directement sur Cloudflare Pages, Firebase Hosting ou un serveur Nginx.

### 5.3 iOS (macOS requis)
```bash
flutter build ipa --release
```

---

## 6. Intégration Continue (CI / CD)

Le projet dispose de workflows automatisés sous GitHub Actions :

### 6.1 Workflow d'Intégration Continue (`.github/workflows/ci.yml`)
Déclenché à chaque *Pull Request* et *Push* sur les branches `main` et `dev` :
1. Configuration de l'environnement Java 17 et Flutter.
2. Résolution des dépendances avec le dépôt frère `shared_models`.
3. Vérification du formatage du code (`dart format --output=none --set-exit-if-changed .`).
4. Analyse statique stricte (`flutter analyze`).
5. Exécution complète des tests (`flutter test`).

### 6.2 Workflow de Déploiement & Release (`.github/workflows/release.yml`)
Déclenché lors de la création d'un tag Git (ex: `v1.0.0`) :
1. Compilation des binaires signés (Android APK & AAB, Web Bundle).
2. Création d'une Release GitHub automatique avec attachement des fichiers binaires prêts pour le déploiement sur les terminaux des artisans.
