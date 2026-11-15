# Documentation Technique & Fonctionnelle — BatTrack v1

Bienvenue dans la documentation officielle du projet **BatTrack (bat_track_v1)**.

BatTrack est une application Flutter multiplateforme (Android, Web, iOS) conçue pour digitaliser le cycle de vie complet des chantiers du BTP (Bâtiment et Travaux Publics) dans une approche **BTP 4.0** : de la capture terrain hors-ligne à la facturation scellée et conforme aux exigences fiscales et écologiques.

---

## 📚 Sommaire de la documentation

La documentation est structurée en 5 guides thématiques exhaustifs situés dans le répertoire `docs/` :

1. **[01. Présentation & Architecture Technique](01_PRESENTATION_ET_ARCHITECTURE.md)**
   - Vision & Objectifs du projet (BTP 4.0, standards de confiance).
   - Architecture applicative Clean / Feature-First.
   - Gestion d'état réactive avec **Riverpod 3** (Notifiers, AsyncNotifiers, Mixins).
   - Abstraction **Multi-Backend Hybride** (Firebase, Supabase, Cloudflare).
   - Moteur local **Offline-First** avec **Hive CE** et synchronisation en tâche de fond.
   - Observabilité, crash reporting & télémétrie (**Sentry**, **Firebase Crashlytics**).

2. **[02. Fonctionnalités Métier Exhaustives](02_FONCTIONNALITES_DETAILLEES.md)**
   - Gestion des Rôles et Contrôle d'Accès (RBAC : Admin, Superutilisateur, Chef de Projet, Technicien, Client).
   - Gestion des Chantiers & cycle de vie des étapes (Timeline interactive, Kanban drag-and-drop).
   - Gestion des Pièces, Lots et métrés de chantier.
   - Gestion des Interventions terrain & affectation des techniciens.
   - Gestion du Matériel, des Matériaux et des Équipements.
   - Module de Facturation, Devis & Brouillons (`FactureDraft`).
   - Moteur Écologique **ADEME** (ventilation intelligente de la TVA à 5.5%, 10% et 20%).
   - Conformité Fiscale **ISCA** (Loi Anti-Fraude TVA, chaînage cryptographique SHA-256, clôtures périodiques).
   - Dashboard Intelligent & Projections de Trésorerie (`ProjectionEngine`, détection d'anomalies).
   - Moteur de Génération de Documents PDF & Signature manuscrite vectorielle.
   - Bridge ERP **Dolibarr** (exploration et import bidirectionnel).
   - Synchronisation des catalogues via **Google Sheets API v4**.
   - Visualisation 3D / VR de maquettes numériques (`model_viewer_plus`).

3. **[03. Requêtes Réseau, API & Flux de Données](03_REQUETES_ET_API.md)**
   - Connecteur REST **Dolibarr API** (Endpoints `/thirdparties`, `/projects`, `/tasks`, `/invoices`, `/products`, etc., payloads JSON, headers, gestion des erreurs).
   - Requêtes **Cloud Firestore** & **Firebase Storage** (schémas des collections, requêtes composées, streams temps réel, upload médias).
   - Requêtes **Supabase** (PostgreSQL CRUD, filtres, Upsert, RLS).
   - Requêtes **Cloudflare** (Workers / KV / R2).
   - Intégration **Google Sheets API v4** (OAuth2/Service Account, `spreadsheets.values.get`, mapping colonnes vers entités `Produit`).
   - Moteur de Synchronisation Offline-First (`FrameSyncQueue`, Last-Update-Wins avec timestamps unifiés, reprise automatique réseau via `ConnectivityPlus`).

4. **[04. UI / UX & Design System](04_UI_UX_ET_DESIGN_SYSTEM.md)**
   - Principes de Design Material 3 (thématisation Indigo, typographie Noto Sans, dark/light mode).
   - Système Responsive multi-écrans (`ResponsiveObserver`, Mobile <600px, Tablet 600-1024px, Desktop >1024px).
   - Architecture de navigation (`GoRouter`, `ShellRoute`, `AccessShell`, redirections automatiques par rôle).
   - Catalogue détaillé des écrans, formulaires dynamiques (`JsonForm`, `EntityForm`) et widgets interactifs.
   - Composants UX spécialisés (bannière de connectivité, indicateur de scellement fiscal, timeline interactive, pad de signature, Kanban).
   - Parcours utilisateurs types (Workflows pas-à-pas illustrés).

5. **[05. Guide de Déploiement, Tests & CI/CD](05_GUIDE_DEPLOIEMENT_ET_TESTS.md)**
   - Prérequis d'installation et variables d'environnement.
   - Lancement en développement et configuration multi-plateforme.
   - Stratégie de tests (tests unitaires, tests de convergence BTP 4.0 d'intégration).
   - Analyse statique (`flutter analyze`) et formatage (`dart format`).
   - Pipelines GitHub Actions (`ci.yml`, `release.yml`).

---

## 🎯 Rappel des cibles et technologies

| Composant | Technologie |
|---|---|
| **Framework** | Flutter 3.24+ / Dart 3.5+ (Compatibilité Dart 3.13 / Flutter 3.47+) |
| **State Management** | Flutter Riverpod 3.3.1 (avec annotations) |
| **Base locale (Offline)** | Hive CE 2.18 / Hive CE Flutter 2.3.4 |
| **Backends Distants** | Firebase (Auth, Firestore, Storage) + Supabase + Cloudflare |
| **ERP Métier** | Dolibarr REST API (via Dio 5.8) |
| **Routage** | GoRouter 18.0.0 (avec redirections dynamiques & RBAC) |
| **Génération PDF** | PDF 3.11 + Printing 5.14 |
| **Graphiques** | FL Chart 1.1.0 |
| **Visualisation 3D** | Model Viewer Plus 1.9.3 (glTF / OBJ) |
| **Audit & Sécurité** | ISCA SHA-256 Hash Chaining |
