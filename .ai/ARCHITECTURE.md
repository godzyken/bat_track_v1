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

## Conventions de code

- **Imports :** Préférence pour les imports relatifs pour les briques internes.
- **Modèles :** Utilisation systématique de `Freezed` pour l'immuabilité.
- **Services :** Enregistrement centralisé via des providers pour faciliter les tests (Dependency Injection).

## Points d'attention

- **Synchronisation :** Attention aux conflits d'écriture lors du passage offline -> online (stratégie "Last Update Wins" avec hash).
- **Types :** Éviter les appels `dynamic` sur les retours de Firestore/Supabase.
