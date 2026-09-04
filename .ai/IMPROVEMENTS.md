# Axes d\u0027Am\u00e9lioration (Product Roadmap)

## 1. Intelligence Artificielle (Gemini Integration)
- **Analyse de Devis (Multimodal) :** Utilisation de Gemini 1.5 Pro pour extraire structurer les données depuis des photos de factures ou PDFs fournisseurs.
    - **Workflow :** Capture photo -> Envoi base64 -> Prompt structure -> Injection automatique dans le `BudgetService`.
- **Assistant Prédictif de Stock :** Analyse des consommations passées pour suggérer des commandes de matériaux avant rupture.
- **Support Assistant :** Chatbot interne contextuel (RAG) alimenté par la documentation technique du projet et l'état des chantiers.

## 2. Terrain & Mobile
- **Offline Total :** Améliorer la résolution des conflits complexes sur les gros fichiers.
- **Réalité Augmentée :** Intégration de mesures via ARCore/ARKit pour le calcul automatique des surfaces de pièces.

## 3. Écosystème
- **Compta4me Bridge :** Exportation automatisée des écritures scellées vers le module comptable.
- **Notification Push :** Alertes de retard sur les étapes critiques ou notifications de paiement client.

## 4. Documentation & Certification
- **Certification ISCA :** Audit externe pour valider la chaîne SHA-256 auprès des autorités fiscales.
- **OpenAPI / Swagger :** Documentation complète du Bridge Dolibarr pour permettre des extensions tierces.
