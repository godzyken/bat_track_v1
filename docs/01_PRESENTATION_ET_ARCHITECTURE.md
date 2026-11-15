# 01. Présentation & Architecture Technique

## 1. Vision et Objectifs du Projet

### 1.1 Le Constat Métier
Le secteur du bâtiment (BTP) souffre traditionnellement d'une rupture numérique entre le **terrain** (chantiers mobiles, zones blanches sans connexion Internet, aléas de livraison, suivi manuel) et le **bureau / gestion comptable** (ERP, conformité fiscale, suivi de trésorerie). 

Les artisans, conducteurs de travaux et chefs d'entreprise sont confrontés à trois défis majeurs :
1. **L'indisponibilité du réseau :** Impossibilité d'utiliser des applications exclusivement cloud au sous-sol ou en milieu rural.
2. **La conformité légale stricte :** La Loi Anti-Fraude TVA (systèmes d'encaissement certifiés, inaltérabilité des règlements) et la complexité des taux de TVA écologiques de l'ADEME (5.5%, 10%, 20%).
3. **Le cloisonnement des outils :** Les devis sont faits sur un tableur ou un ERP (ex: Dolibarr), les photos sont sur des téléphones personnels, et les factures sont éditées séparément avec des retards de paiement chroniques.

### 1.2 La Réponse BatTrack (BTP 4.0)
BatTrack a été conçu comme le **Standard de Confiance et de Productivité** pour les PME et artisans du BTP. L'application unifie :
- Une expérience mobile agile **Offline-First** (opérations locales instantanées avec synchronisation transparente dès le retour du réseau).
- Une rigueur fiscale et légale native via le protocole **ISCA** (Inaltérabilité, Sécurisation, Conservation, Archivage) basé sur un chaînage cryptographique SHA-256.
- Une intelligence économique et écologique intégrant les règles de TVA de l'ADEME et un moteur de projection de trésorerie en temps réel.
- Une intégration bidirectionnelle native avec l'ERP open-source **Dolibarr** et les services de stockage cloud distribués.

---

## 2. Architecture Logicielle Globale

BatTrack adopte une architecture **Feature-First** (Clean Architecture pragmatique), hautement modulaire et découplée.

### 2.1 Diagramme des Couches Applicatives

```
┌─────────────────────────────────────────────────────────────┐
│                 COUCHE PRÉSENTATION & UI                     │
│  - Écrans (Features / Views / Screens)                      │
│  - Widgets réutilisables & Composants dynamiques (JsonForm) │
│  - Shell adaptatif (AccessShell, AppDrawer, SideMenu)       │
└──────────────────────────────┬──────────────────────────────┘
                               │ Écoute (ref.watch / ref.listen)
                               ▼
┌─────────────────────────────────────────────────────────────┐
│               COUCHE GESTION D'ÉTAT (RIVERPOD 3)            │
│  - Notifiers & AsyncNotifiers métier                        │
│  - Mixins : MutationQueueMixin, UndoRedoMixin               │
│  - Providers de configuration et d'instances                │
└──────────────────────────────┬──────────────────────────────┘
                               │ Appelle
                               ▼
┌─────────────────────────────────────────────────────────────┐
│             COUCHE DOMAINE & SERVICES UNIFIÉS               │
│  - ModelRegistry (Métadonnées, fabriques fromJson, mocks)   │
│  - UnifiedEntityService & UnifiedRepository                 │
│  - Moteurs Métier : IscalAuditService, ProjectionEngine     │
└──────────────────────────────┬──────────────────────────────┘
                               │ Lit / Écrit
                               ▼
┌─────────────────────────────────────────────────────────────┐
│             COUCHE DONNÉES & MULTI-BACKEND                  │
│   [LOCAL - HIVE CE]             [DISTANT - MULTI-CLOUD]     │
│   - Boîtes Hive par entité      - Firebase (Firestore/Auth) │
│   - Cache instantané (Optimistic) - Supabase (PostgreSQL)   │
│   - Adaptateurs TypeAdapter     - Cloudflare Workers / R2   │
│                                 - Dolibarr REST API         │
│                                 - Google Sheets API v4      │
└─────────────────────────────────────────────────────────────┘
```

---

## 3. Structure des Répertoires

Le projet est organisé comme suit :

```
lib/
├── core/                           # Cœur transversal de l'application
│   ├── compliance/                 # Service d'audit fiscal ISCA & scellement
│   ├── financial_engine/           # Moteur de calcul financier & projections
│   ├── responsive/                 # Wrappers responsive, breakpoints et observateurs
│   ├── riverpod/                   # Notifiers de base et mixins (Undo/Redo, Mutations)
│   ├── services/                   # Services système (Connectivité, SyncWorker, GSheets)
│   └── widgets/                    # Widgets transversaux (Bannière offline, Indicateur ISCA)
│
├── data/                           # Gestion des données et accès persistant
│   ├── core/                       # ModelRegistry et UnifiedRepository
│   ├── local/                      # Implémentations Hive CE (modèles, adaptateurs, convertisseurs)
│   └── remote/                     # Connecteurs distants (Firebase, Supabase, Cloudflare, Dolibarr)
│
├── features/                       # Modules fonctionnels (Feature-First)
│   ├── auth/                       # Authentification, gestion des utilisateurs et rôles
│   ├── chantier/                   # Suivi des chantiers, étapes, lots, pièces et timeline
│   ├── client/                     # Fiches clients et synchronisation tiers
│   ├── dashboard/                  # Tableau de bord intelligent, métriques et projections
│   ├── documents/                  # Factures, devis, fiches d'intervention et générateurs PDF
│   ├── dolibarr/                   # Explorateur API et synchronisation ERP Dolibarr
│   ├── equipement/                 # Matériel et équipements chantier
│   ├── home/                       # Accueil, navigation et layouts principaux
│   ├── intervention/               # Interventions terrain, affectations et graphiques
│   ├── planning/                   # Planification Kanban et calendrier
│   ├── projet/                     # Gestion globale des projets BTP
│   └── technicien/                 # Profils et gestion des techniciens
│
├── models/                         # Abstractions et composants transversaux legacy/partagés
│   ├── controllers/                # Contrôleurs d'état
│   ├── data/                       # Adaptateurs, gestion d'erreurs, proxies
│   ├── notifiers/                  # Notifiers génériques de synchronisation
│   ├── providers/                  # Providers asynchrones et synchrones
│   ├── services/                   # Abstractions de services distants et locaux
│   └── views/                      # Écrans et formulaires génériques (JsonForm, EntityForm)
│
├── providers/                      # Providers globaux (Dio, Auth, Box)
├── routes/                         # Configuration GoRouter, shell et gardes d'accès
└── main.dart                       # Point d'entrée de l'application, initialisation & Sentry
```

---

## 4. Gestion d'État avec Riverpod 3

L'application exploite la puissance de **Flutter Riverpod 3** pour garantir un flux de données réactif, unidirectionnel et testable sans effet de bord.

### 4.1 Modèle de Base : `BaseListNotifier<T>`
Situé dans `lib/core/riverpod/base_list_notifier.dart`, ce notifier abstrait encapsule toutes les opérations courantes sur une liste d'entités avec gestion intégrée de l'historique et des mutations asynchrones :
- `build()` : Charge la liste initiale depuis le repository ou le service unifié.
- `create(T item)` : Ajoute un nouvel élément en UI optimiste et planifie l'écriture.
- `update(T item)` : Met à jour un élément existant.
- `delete(String id)` : Supprime un élément.
- **Support Undo / Redo :** Grâce au mixin `UndoRedoMixin<List<T>>`, chaque modification de liste alimente une pile de retours en arrière (`undo()`) et de rétablissements (`redo()`), directement accessible dans les AppBar via des actions graphiques.

### 4.2 Traitement des Mutations par Lot : `MutationQueueMixin`
Pour les formulaires et les interfaces d'édition rapide (comme la modification d'un jalon ou d'un métré) :
- Les mutations sont mises en tampon dans une file d'attente d'images de rendu (`FrameSyncQueue`).
- Le composant `Debounce` (dans `lib/core/config/debounce.dart`) groupe les saisies utilisateur rapprochées afin d'éviter les sollicitations excessives du cache local et du réseau.

---

## 5. Le Moteur de Données Unifié

### 5.1 Centralisation via le `ModelRegistry`
Plutôt que de disperser les constructeurs `fromJson`, les instances de mock et les configurations réseau dans chaque fichier, le `ModelRegistry` (`lib/data/core/model_registry.dart`) sert de catalogue de types pour toutes les entités de l'écosystème :

```dart
ModelRegistry.register<Chantier>(
  fromJson: Chantier.fromJson,
  mock: Chantier.mock,
  repoConfig: const RepositoryConfig(
    collectionPath: 'chantiers',
    dolibarrEndpoint: 'projects',
    fromJson: Chantier.fromJson,
  ),
);
```

Chaque modèle étendant `UnifiedModel` bénéficie ainsi de fabriques standardisées, de mocks pour les tests unitaires et d'un point d'ancrage pour la synchronisation multi-sources.

### 5.2 Le `UnifiedRepository<T>`
Le `UnifiedRepository` orchestre le cycle de vie complet de l'entité :
1. **Lecture locale prioritaire :** Interrogation immédiate de la boîte Hive (`getFromHive()`, `getAllFromHive()`).
2. **Écriture locale réactive :** Persistance instantanée dans Hive (`saveToHive()`).
3. **Diffusion distante :** Propagation vers Firestore (`saveToFirebase()`) et/ou Dolibarr (`syncFromDolibarr()`).
4. **Sécurité d'exécution :** Chaque opération est encadrée par `SafeAsyncMixin` et tracée par `LoggedAction` pour consigner toute anomalie dans les journaux système.

---

## 6. Stratégie Multi-Backend Agnostique

Pour éviter tout verrouillage propriétaire (*vendor lock-in*), BatTrack implémente le patron de conception **Strategy / Adapter** au travers de `RemoteStorageService` (`lib/models/services/remote/remote_storage_service.dart`).

Le composant `MultiBackendRemoteService` (`lib/models/services/multi_backend_remote_service.dart`) permet de distribuer les écritures et lectures sur plusieurs fournisseurs simultanément ou selon un mode préférentiel (`StorageMode`) :
- **Firebase / Firestore :** Base de données documentaire temps réel pour la synchronisation réactive sur mobile, l'authentification Firebase Auth et le stockage binaire Firebase Storage.
- **Supabase :** Base de données relationnelle PostgreSQL hébergée, idéale pour l'application de règles de sécurité au niveau ligne (*Row Level Security - RLS*) et les requêtes SQL analytiques.
- **Cloudflare Workers / KV / R2 :** Solution edge haute performance pour la mise en cache de proximité des documents et l'exécution de fonctions sans serveur à très faible latence.

---

## 7. Moteur Offline-First et Synchronisation Réseau

L'application garantit une utilisation continue sur le chantier, même en l'absence totale de réseau cellulaire ou Wi-Fi.

### 7.1 Fonctionnement du `SyncWorker`
Le worker de synchronisation (`lib/core/services/sync_worker.dart`) est démarré au lancement de l'application dans `main.dart` :
- Il écoute les changements d'état du réseau via `ConnectivityPlus` (`lib/core/services/connectivity_service.dart`).
- Dès qu'une connexion Internet est restaurée, il déclenche le traitement des éléments restés en attente dans la file de synchronisation.
- En cas de perte de réseau, un composant visuel d'information (`ConnectivityBanner`) prévient l'utilisateur que l'application bascule automatiquement en mode hors-ligne sans interrompre la saisie.

### 7.2 Résolution des Conflits : "Last-Update-Wins"
Toutes les entités disposent d'un horodatage `updatedAt`. Lors d'une synchronisation distante :
1. La date de dernière modification de l'entité distante est comparée à la date locale.
2. La version la plus récente prévaut (`remote.updatedAt.isAfter(local.updatedAt)`).
3. L'écriture s'effectue dans Hive, ce qui déclenche automatiquement la notification des streams Riverpod et le rafraîchissement des écrans.

---

## 8. Observabilité, Gestion des Erreurs et Robustesse

### 8.1 Double Couche de Télémétrie : Sentry + Firebase Crashlytics
1. **Sentry Flutter :** Initialisé dans `runZonedGuarded` (`lib/main.dart`), Sentry intercepte toutes les exceptions non gérées au niveau du framework Flutter et du moteur Dart en production.
2. **Firebase Crashlytics :** Encapsulé dans `CrashlyticsWrapper`, il capture les traces d'erreurs natives (Android/iOS) et les logs d'incidents critiques.
3. **Filtres d'erreurs non critiques :** Les erreurs de type `DebugService`, ressources graphiques manquantes en dev ou requêtes HTTP 404 secondaires sont filtrées via `_shouldIgnoreError()` pour préserver la clarté des journaux.

### 8.2 Console de Débogage Intégrée
En mode debug (`kDebugMode`), un widget flottant `DebugFloatingOverlay` permet d'inspecter en direct l'état des boîtes Hive, les requêtes réseau effectuées et le journal d'activité système.
