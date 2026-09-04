# Architecture: BatTrack

## Vue d'ensemble

```
UI (Screens & Widgets)
 ↓
Presentation (Riverpod Notifiers)
 ↓
Providers (Service Registry)
 ↓
Repositories (Unified Entity Service)
 ↓
Services (Hive / Firestore / Supabase / Dolibarr)
 ↓
Database (Local Hive & Remote Cloud)
```

## Structure des dossiers

```
lib/
├── core/
│   ├── compliance/       ← ISCA Audit Service
│   ├── financial_engine/ ← ADEME TVA & Projections
│   ├── responsive/       ← Layout Wrappers
│   ├── riverpod/         ← Mutation & Undo Mixins
│   └── services/         ← Unified Implementations
├── data/
│   ├── local/            ← Hive Adapters & Providers
│   ├── remote/           ← Supabase & Firestore Services
│   └── core/             ← Registry
├── features/
│   ├── auth/             ← Login, Register, Middleware
│   ├── chantier/         ← List, Detail, Sync
│   ├── dashboard/        ← Stats & Cashflow Projections
│   ├── dolibarr/         ← Explorer & Import Bridge
│   └── ... (intervention, projet, equipement)
├── models/
│   ├── data/             ← Freezed Models & Mixins
│   ├── providers/        ← Sync & Future Providers
│   └── services/         ← Interfaces
└── main.dart
```

## Modules principaux

- **Unified Entity Service :** Gère la transition entre Hive (local) et les backends distants de manière transparente.
- **Core Financial Engine :** Calcule les marges, la TVA ADEME et les projections de trésorerie.
- **Dolibarr Bridge :** Permet l'importation bidirectionnelle des tiers (clients) et projets depuis l'ERP.
- **ISCA Compliance :** Journal d'audit scellé garantissant l'inaltérabilité fiscale.

## Focus Technique: Sync Engine (Offline-First)

L'Engine de Synchronisation est le cœur réactif de BatTrack. Il repose sur une architecture hybride permettant une fluidité totale sans connexion.

### 1. Stratégie d'Écriture (Optimistic UI)
Lorsqu'un utilisateur modifie une donnée (ex: validation d'une étape de chantier) :
1. **Écriture Locale Immédiate :** Le `UnifiedEntityService` persiste l'objet dans **Hive**. L'UI se met à jour instantanément via les streams de Riverpod.
2. **File d'Attente de Mutation :** La modification est placée dans une `FrameSyncQueue`.
3. **Synchronisation Asynchrone :** Si le réseau est disponible, le service tente une écriture sur le backend configuré (Firestore/Supabase). En cas d'échec (offline), l'opération est marquée comme `pending` et sera re-tentée automatiquement dès le retour du signal.

### 2. Résolution de Conflits
Le système utilise une stratégie **"Last Update Wins"** renforcée par des horodatages synchronisés sur un serveur de temps (NTP) pour éviter les dérives locales :
- Chaque entité possède un champ `updatedAt`.
- Le `RemoteEntityServiceAdapter` compare le timestamp distant avec le local avant d'écraser, garantissant que la version la plus récente gagne, même si elle arrive avec du retard depuis une file d'attente offline.

## Vision IA: BTP 4.0 & Gemini

BatTrack intègre l'IA non pas comme un gadget, mais comme un accélérateur de productivité pour l'artisan.

### 1. Analyse Multimodale de Devis (Gemini 1.5 Pro)
Le workflow "Capture-to-Budget" permet d'extraire des données structurées depuis le terrain :
- **Entrée :** Photo d'un devis papier ou PDF d'un fournisseur de matériaux.
- **Traitement :** Gemini analyse l'image, identifie les noms des produits, les quantités, les prix unitaires et la TVA.
- **Sortie :** Mapping automatique vers le modèle `Produit` et injection dans les lignes de frais du chantier.

### 2. Assistant Prédictif (RAG & Analyse)
L'IA a accès au contexte complet du projet (via les documents scannés et les logs fiscaux) :
- **Prévision de Stock :** Alerte l'artisan si la consommation réelle de matériaux sur les étapes terminées suggère une rupture pour les étapes à venir.
- **Support Réglementaire :** Interrogation en langage naturel sur les normes ADEME ou les règles de TVA applicables à un matériau spécifique.

---

## Conventions de code

- **Imports :** Préférence pour les imports relatifs pour les briques internes.
- **Modèles :** Utilisation systématique de `Freezed` pour l'immuabilité.
- **Services :** Enregistrement centralisé via des providers pour faciliter les tests (Dependency Injection).

## Points d'attention

- **Synchronisation :** Attention aux conflits d'écriture lors du passage offline -> online (stratégie "Last Update Wins" avec hash).
- **Types :** Éviter les appels `dynamic` sur les retours de Firestore/Supabase.
