# Analyse Technique Détaillée : Widgets et UI (BatTrack v1 - Construction 4.0)

Ce document présente l'analyse technique complète des composants UI, de leurs fonctionnalités, de leurs APIs et de leurs connexions (gestion d'état Riverpod, persistance Hive/Drift, et synchronisation multi-backend) au sein du projet **`bat_track_v1`**.

---

## 1. Architecture UI & Principes Généraux

L'architecture interface utilisateur de BatTrack repose sur :
- **Material 3 (`useMaterial3: true`)** avec un thème unifié (clair/sombre géré dynamiquement).
- **Design Adaptatif / Responsive (`ResponsiveObserver`, `ResponsiveInfo`)** s'adaptant aux écrans `mobile`, `tablet` et `desktop`.
- **Gestion d'État Réactive (Riverpod 3.x / Riverpod Annotation)** pour découpler la logique métier de la présentation.
- **Support Hors-Ligne & Sync Native** (Hive CE & Drift) couplé à une architecture de synchronisation asynchrone (`SyncWorker`).

---

## 2. Composants de Navigation & Structure (`/lib/features/home/` & `/lib/routes/`)

### 2.1. [`HomeScreen`](file:///C:/Users/soufi/StudioProjects/bat_track_v1/lib/features/home/views/screens/home_screen.dart)
- **Fonctionnalité :** Écran d'accueil principal de l'application, adaptatif selon la taille d'écran (Desktop, Tablet, Mobile) et point d'entrée de la synchronisation au démarrage.
- **API / Paramètres :** `ConsumerWidget` sans paramètres obligatoires.
- **Connexions :**
  - Appelle `syncAllProvider` au montage via `Future.microtask`.
  - Appelle `UpdateService` (`updateServiceProvider`) pour vérifier les mises à jour GitHub Release au démarrage.
  - Utilise `context.responsiveInfo(ref)` pour déterminer l'agencement (`SideMenu` + `HomeContent` en desktop, `Drawer` + `HomeContent` en mobile).

### 2.2. [`SideMenu`](file:///C:/Users/soufi/StudioProjects/bat_track_v1/lib/features/home/views/widgets/side_menu.dart) & [`AppDrawer`](file:///C:/Users/soufi/StudioProjects/bat_track_v1/lib/features/home/views/widgets/app_drawer.dart)
- **Fonctionnalité :** Tiroirs de navigation latérale. `SideMenu` est affiché en mode Desktop/Tablet (panneau fixe), tandis que `AppDrawer` est un `Drawer` Material standard pour le mobile.
- **API / Paramètres :** `ConsumerWidget`.
- **Connexions :**
  - Utilise `GoRouter` (`context.go(route)`) pour la navigation fluide entre les modules (`/`, `/clients`, `/techniciens`, `/chantiers`, `/interventions`, `/about`).
  - Gère la déconnexion utilisateur avec boîte de dialogue de confirmation et réinitialisation de session (`authProvider`).

### 2.3. [`HomeContent`](file:///C:/Users/soufi/StudioProjects/bat_track_v1/lib/features/home/views/widgets/home_content.dart)
- **Fonctionnalité :** Contenu central de la page d'accueil présentant le résumé "Construction 4.0" et une carte d'aperçu dynamique du dashboard.
- **API / Paramètres :** `ConsumerWidget`.
- **Connexions :**
  - Observe `screenSizeProvider` pour adapter la disposition en colonnes ou en lignes (`Row` / `Column`).
  - Intègre [`DashboardPreviewCard`](file:///C:/Users/soufi/StudioProjects/bat_track_v1/lib/features/dashboard/views/widgets/dashboard_preview_card.dart).

---

## 3. Indicateurs d'État Global & Conformité (`/lib/core/widgets/`)

### 3.1. [`ConnectivityBanner`](file:///C:/Users/soufi/StudioProjects/bat_track_v1/lib/core/widgets/connectivity_banner.dart)
- **Fonctionnalité :** Bannière d'alerte non intrusive affichée en haut de l'écran lorsque le terminal est hors-ligne.
- **API / Paramètres :** `ConsumerWidget`.
- **Connexions :**
  - Observe `connectivityStatusProvider`.
  - Masquée automatiquement (`SizedBox.shrink`) en cas de connexion active (`ConnectivityStatus.isConnected`).
  - Affiche une alerte orange explicite en mode hors-ligne garantissant la transparence sur la sauvegarde locale des données.

### 3.2. [`FiscalIntegrityIndicator`](file:///C:/Users/soufi/StudioProjects/bat_track_v1/lib/core/widgets/fiscal_integrity_indicator.dart)
- **Fonctionnalité :** Indicateur de conformité ISCA (Loi Anti-Fraude TVA) garantissant l'inaltérabilité de la chaîne de hachage SHA-256 des factures.
- **API / Paramètres :** `ConsumerWidget`.
- **Connexions :**
  - Observe `iscalAuditServiceProvider`.
  - Exécute `verifyChainIntegrity()` de manière asynchrone pour afficher une icône verte (`verified_user`) si intègre ou rouge (`gpp_maybe`) en cas de rupture de chaîne.

---

## 4. Composants CRUD Génériques & Modulaires (`/lib/models/views/widgets/`)

BatTrack utilise une architecture de modèles unifiés (`UnifiedModel`) permettant de générer dynamiquement des listes, des cartes et des formulaires standardisés pour toutes les entités (Chantiers, Clients, Interventions, Équipements, etc.).

### 4.1. [`EntityCard<T extends UnifiedModel>`](file:///C:/Users/soufi/StudioProjects/bat_track_v1/lib/models/views/widgets/entity_card.dart)
- **Fonctionnalité :** Carte universelle pour afficher n'importe quelle entité métier avec gestion d'image, badge de statut dynamique, tags et boutons d'action contextuels.
- **API / Paramètres :**
  - `required T entity`
  - `VoidCallback? onEdit`
  - `VoidCallback? onDelete`
  - `bool showActions`
  - `bool readOnly`
  - `List<Widget>? trailingActions`
- **Connexions :**
  - Utilise `currentUserProvider` pour évaluer les permissions granulaires.
  - Intègre la règle métier `ProjetPolicy` pour afficher conditionnellement le bouton d'assignation de techniciens (`AssignTechnicienDialog`).
  - Mappe automatiquement les données JSON de l'entité (`entity.toJson()`) pour extraire nom, description, statut et tags.

### 4.2. [`EntityList<T extends UnifiedModel>`](file:///C:/Users/soufi/StudioProjects/bat_track_v1/lib/models/views/widgets/entity_list.dart)
- **Fonctionnalité :** Liste ou grille adaptative (ListView sur mobile, GridView sur tablette/desktop) affichant les collections d'entités avec filtrage par rôle utilisateur (`canMerge(currentUser)`).
- **API / Paramètres :**
  - `required AsyncValue<List<T>> items`
  - `required String boxName`
  - `required AppUser currentUser`
  - `void Function(T)? onEdit`
  - `void Function()? onCreate`
  - `Future<void> Function(String id)? onDelete`
- **Connexions :**
  - Se connecte aux fournisseurs Hive (`HiveService`, `HiveProvider`) pour les opérations de suppression/persistance.
  - Filtre les éléments selon les droits de l'utilisateur connecté.

### 4.3. [`EntityForm<T>`](file:///C:/Users/soufi/StudioProjects/bat_track_v1/lib/models/views/widgets/entity_form.dart) & Formulaires Spécialisés
- **Fonctionnalité :** Formulaire de saisie dynamique généré à partir des propriétés de l'entité, avec support du mode expert et restrictions basées sur les rôles (ex: technicien limité à certains champs de dimensions).
- **Connexions :**
  - Lié aux contrôleurs de formulaires JSON (`JsonFormController`).

---

## 5. Résumé des Connexions & Fournisseurs Riverpod Clés

| Composant UI | Provider / Service associé | Rôle / Source de données |
| :--- | :--- | :--- |
| `HomeScreen` | `syncAllProvider`, `updateServiceProvider` | Synchronisation des chantiers & vérification GitHub Releases |
| `ConnectivityBanner` | `connectivityStatusProvider` | État réseau en temps réel (connecté / hors-ligne) |
| `FiscalIntegrityIndicator`| `iscalAuditServiceProvider` | Vérification de la chaîne d'intégrité ISCA (SHA-256) |
| `DashboardPreviewCard` | `interventionStatsProvider` | Statistiques et graphiques des interventions |
| `EntityList` / `EntityCard`| `hiveProvider`, `currentUserProvider` | Stockage local Hive CE & gestion des rôles de sécurité |
