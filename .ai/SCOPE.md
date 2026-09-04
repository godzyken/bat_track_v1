# Cahier des Charges & Cadrage : BatTrack

## 1. Vision du Projet
BatTrack ambitionne de devenir l'outil de référence pour les artisans et PME du BTP souhaitant digitaliser leur suivi de chantier sans sacrifier la rigueur fiscale. La vision repose sur trois piliers :
- **Terrain :** Capture de données ultra-simplifiée et mode offline-first.
- **Rigueur :** Conformité ISCA (fiscale) et ADEME (écologique) native.
- **Ecosystème :** Intégration fluide avec Dolibarr et les futurs services EGOTe.

## 2. Périmètre Fonctionnel (Cadrage)
### Core Business
- [x] Gestion des Projets et Chantiers.
- [x] Structure hiérarchique : Étape > Pièce > Matériaux/Intervenants.
- [x] Synchronisation hybride (Hive/Firebase/Supabase).
- [x] Bridge ERP Dolibarr (Clients/Projets).

### Compliance & Finance
- [x] Journal d'audit scellé (Hash SHA-256).
- [x] Moteur de TVA ADEME (5.5% vs 10% vs 20%).
- [x] Projections de trésorerie en temps réel.
- [x] Signature numérique des factures.

## 3. Utilisateurs Cibles
- **Admin :** Pilotage global, paramétrage financier.
- **Chef de Projet :** Suivi d'avancement, validation des étapes.
- **Technicien :** Saisie des interventions, ajout de photos terrain.
- **Client :** Consultation et validation électronique.

## 4. Contraintes Techniques
- Performance sur terminaux mobiles d'entrée de gamme.
- Sécurisation des données sensibles (RLS Supabase).
- Inaltérabilité des logs fiscaux.
