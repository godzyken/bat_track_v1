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
