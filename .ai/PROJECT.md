# Project: BatTrack

## Name
BatTrack (bat_track_v1)

## Purpose
Plateforme intelligente de suivi de chantier pour le BTP 4.0. Elle permet la gestion des interventions, la synchronisation multi-cloud, le devisage hiérarchique et garantit la conformité fiscale et écologique.

## Target
- Artisans et PME du BTP.
- Chefs de projet et conducteurs de travaux.
- Clients finaux (suivi et validation).

## Platforms
- [x] Android (Cible principale)
- [x] Web (Dashboard & Administration)
- [x] iOS (Compatibilité)

## Flutter
Version utilisée :
```
3.47.x (selon environnement de déploiement)
```

## Dart
Version utilisée :
```
3.13.x
```

## Architecture
Architecture modulaire **Feature-First** (ou Clean Architecture simplifiée). 
Séparation claire entre :
- **Core:** Moteurs transversaux (Financial, Sync, Responsive).
- **Features:** Authentification, Chantier, Client, Dolibarr, Dashboard, etc.
- **Models:** Entités partagées et adaptateurs Hive/Firestore.

## State management
- **Riverpod 3** (AsyncNotifier, StateProvider, Provider).

## Backend
- **Hybride Agnostique :** Firebase (Auth/Firestore/Storage) + Supabase + Cloudflare.
- **Bridge ERP :** Connecteur Dolibarr natif.

## Authentication
- **Firebase Auth** (Email/Password).
- **Passkeys / Biométrie** (Prévu pour sécurisation ISCA).

## Important constraints
- **Conformité ISCA :** Inaltérabilité des données financières via hash-chaining SHA-256.
- **Intelligence ADEME :** TVA écologique automatisée.
- **Offline-First :** Synchronisation bidirectionnelle avec cache Hive prioritaire.
