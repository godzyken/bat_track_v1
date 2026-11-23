# Architectural Decisions (ADR)

## ADR 001: Journal d'Audit Fiscale (ISCA)
- **Date:** 2026-08-30
- **Status:** Accepted
- **Context:** Nécessité de garantir l'inaltérabilité des factures pour la conformité Loi Anti-Fraude TVA.
- **Decision:** Mise en place d'un hash-chaining SHA-256. Chaque nouvelle facture scellée contient le hash de la transaction précédente.
- **Consequence:** Les modifications sur des factures payées sont interdites. Toute rupture de la chaîne est détectable via `verifyChainIntegrity()`.

## ADR 002: Backend Hybride Agnostique
- **Date:** 2026-08-13
- **Status:** Accepted
- **Context:** Éviter le vendor lock-in et permettre des scénarios de déploiement variés.
- **Decision:** Abstraction via `RemoteStorageService`. Implémentations disponibles pour Firebase, Supabase et Cloudflare.
- **Consequence:** Le code métier reste propre et ignore la nature réelle de la base de données distante.

## ADR 003: Moteur Financier Core
- **Date:** 2026-08-13
- **Status:** Accepted
- **Context:** Mutualisation du savoir-faire fiscal entre BatTrack et Compta4me.
- **Decision:** Extraction de l'`AdemeTvaEngine` et du `ProjectionEngine` dans le namespace `core/`.
- **Consequence:** Convergence technologique facilitée entre les piliers de l'écosystème.

## ADR 004: Synchronisation des entités Hive avec shared_models v2
- **Date:** 2026-11-15
- **Status:** Accepted
- **Context:** Le package `shared_models` a évolué (refactoring de `Equipement`, `Intervention`, `MainOeuvre`, `Materiau`, `Materiel`, `Piece`, `Projet`) sans mise à jour correspondante des entités Hive CE dans `bat_track_v1`. Résultat : 30+ erreurs de compilation.
- **Decision:** Alignement manuel des 13 entités Hive (`*_entity.dart`) sur les nouveaux champs des modèles domain. Aucune régression de fonctionnalité — seule la couche de mapping Hive↔Domain est modifiée. Les champs supprimés du modèle domain (ex: `technicienId`, `localisation`, `homologation`) sont remplacés par leurs équivalents (`technicienIds`, nouveaux champs `Equipement`).
- **Consequence:** Les entités Hive restent rétro-compatibles avec les données stockées localement grâce aux valeurs par défaut (`?? ''`, `?? []`, `?? 0.0`). Toute future évolution de `shared_models` devra être accompagnée d'une mise à jour synchrone des entités.

## ADR 005: Signature d'APK Release et Pipeline CI/CD GitHub Actions
- **Date:** 2026-03-02
- **Status:** Accepted
- **Context:** Nécessité d'automatiser la construction et la signature des builds de production (APK release) de manière sécurisée via GitHub Actions, sans exposer les clés de signature dans le dépôt Git.
- **Decision:** Configuration des `signingConfigs` dans Gradle (`android/app/build.gradle.kts`) dynamiquement basées sur des variables d'environnement (`KEYSTORE_PATH`, `KEYSTORE_PASSWORD`, `KEY_ALIAS`, `KEY_PASSWORD`). Création d'un workflow GitHub Actions (`.github/workflows/build_and_release_apk.yml`) décodant un secret Base64 (`KEYSTORE_BASE64`) à la volée et publiant l'APK sous forme d'artifact.
- **Consequence:** Les builds locaux non signés continuent d'utiliser la configuration debug, tandis que les builds CI sur la branche `main` sont signés de manière sécurisée en production et archivés automatiquement.

## ADR 006: Système de mise à jour automatique in-app depuis GitHub Releases
- **Date:** 2026-03-02
- **Status:** Accepted
- **Context:** L'application `bat_track_v1` fonctionnant principalement hors-ligne sur les chantiers, les utilisateurs ont besoin d'un mécanisme de mise à jour fluide, non bloquant et résistant aux coupures réseau lors de la sortie d'une nouvelle version.
- **Decision:** Implémentation d'un service dédié (`UpdateService`) interrogeant l'API GitHub Releases (`/repos/godzyken/bat_track_v1/releases/latest`) avec un timeout strict de 5 secondes et un mode silencieux en cas d'absence de connexion. Comparaison sémantique des versions (`package_info_plus`), affichage d'une boîte de dialogue non bloquante, téléchargement de l'APK en arrière-plan et ouverture de l'installateur natif (`open_filex`) avec la permission `REQUEST_INSTALL_PACKAGES`.
- **Consequence:** Les utilisateurs sont informés des nouveautés et peuvent se mettre à jour directement depuis l'application sans passer par un store public, tout en préservant le fonctionnement hors-ligne (erreurs réseau ignorées sans impacter l'expérience utilisateur).
