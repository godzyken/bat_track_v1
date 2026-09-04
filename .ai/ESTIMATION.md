# Chiffrage et Valorisation : BatTrack

## 1. Coût de Développement (Estimation Asset)
Basé sur le volume de code (~29k LOC) et la complexité des moteurs synchrones.

| Module | Effort (Jours/Homme) | Complexité |
| :--- | :--- | :--- |
| Core Sync Engine | 25 | Haute |
| Financial Core (ADEME/ISCA) | 15 | Haute |
| UI/UX Responsive Framework | 20 | Moyenne |
| Bridge Dolibarr/ERP | 12 | Haute |
| Features Métier (Chantier/Docs) | 30 | Moyenne |
| **Total Estimation** | **102 Jours** | -- |

## 2. Coût d'Exploitation (OPEX)
Optimisé pour un modèle "Zero-Cost" au démarrage.
- **Backend :** Firebase/Supabase (Free Tiers).
- **Hosting :** Cloudflare Pages / Netlify (Free).
- **Maintenance :** Automatisée via GitHub Actions.

## 3. Valorisation SaaS (ARR Potentiel)
- **Modèle :** 29€ / mois / utilisateur.
- **Cible initiale :** 50 PME (moyenne 3 utilisateurs).
- **Projection ARR :** ~52 000 € / an.

> [!TIP]
> La valeur de l'actif réside principalement dans sa capacité à être certifié NF525 (grâce à l'ISCA), ouvrant les portes des marchés publics et des grandes entreprises.
