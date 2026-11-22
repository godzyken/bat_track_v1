# Manifeste de Livraison (Delivery Manifest) — BatTrack v1

## 📋 Informations Générales
- **Nom du Projet :** BatTrack (`bat_track_v1`)
- **Version Actuelle :** v1.0.0 (BTP 4.0)
- **Environnement Cible :** Production / Staging
- **Date de Génération :** Février 2025
- **Orchestrateur de Packages :** Melos
- **Plateformes Supportées :** Android (Principal), Web (Dashboard Admin), iOS (Compatibilité)

---

## 📦 Artefacts de Livraison

Les artefacts produits par le pipeline CI/CD ([release.yml](../.github/workflows/release.yml)) sont les suivants :

| Artefact | Chemin / Cible | Description | Format |
|---|---|---|---|
| **Application Android** | `build/app/outputs/flutter-apk/app-release.apk` | Application native Android (Offline-first, ISCA, ADEME) | APK (Signé) |
| **Application Web** | `build/web/` compressé en `web-release.zip` | Dashboard administrateur et suivi de chantier multiplateforme | SPA Web (HTML/JS/WASM) |

---

## ⚙️ Spécifications Techniques & Stack

- **Framework :** Flutter 3.47.1 (Dart 3.13+)
- **State Management :** Flutter Riverpod 3.3.1 (Annotations & Notifiers)
- **Stockage Local :** Hive CE 2.18 / Hive CE Flutter 2.3.4 (Mode Offline-First)
- **Routing :** GoRouter 18.0.0 (RBAC & Redirections dynamiques)
- **Backends Hybrides :**
  - **Firebase** (Auth, Firestore, Storage)
  - **Supabase** (PostgreSQL, RLS)
  - **Cloudflare** (Workers, KV, R2)
- **ERP & Bridge :** Connecteur natif **Dolibarr REST API** (via Dio 5.8)
- **Sécurité & Conformité :** Moteur d'audit ISCA (Hash-chaining SHA-256) & Moteur écologique ADEME

---

## 🚀 Pipeline de Livraison (CI/CD)

### 1. Intégration Continue ([ci.yml](../.github/workflows/ci.yml))
- Checkout du dépôt principal (`bat_track_v1`) et du dépôt de modèles partagés (`shared_models`).
- Configuration Java 17 & Flutter 3.47.1.
- Initialisation Melos (`melos bootstrap`).
- Génération de code (`melos run build_runner`).
- Analyse statique (`melos run analyze`).
- Exécution des tests (`melos run test`).

### 2. Déploiement & Release ([release.yml](../.github/workflows/release.yml))
- Déclenché automatiquement sur push d'un tag Git `v*`.
- Compilation de l'APK Release (`flutter build apk --release`).
- Compilation du Web Release (`flutter build web --release`).
- Archivage ZIP du build Web.
- Création d'une GitHub Release avec génération automatique des notes de version et attachement des binaires.

---

## ✅ Validation & Checklist de Mise en Production

- [x] `flutter analyze` sans erreur bloquante.
- [x] `flutter test` validé (tests unitaires et d'intégration BTP 4.0).
- [x] Vérification de la compatibilité offline Hive CE.
- [x] Vérification de l'intégrité du chaînage cryptographique ISCA (SHA-256).
- [x] Validation des règles de routage GoRouter et RBAC.
