# 02. Fonctionnalités Métier Détaillées

Ce document décrit en détail l'ensemble des modules fonctionnels de l'application **BatTrack v1**, leurs règles métier, leurs modèles de données et leurs cas d'utilisation sur le terrain.

---

## 1. Gestion des Utilisateurs, Rôles & Sécurité (RBAC)

### 1.1 Matrice des Rôles & Privilèges
L'application implémente un contrôle d'accès basé sur les rôles (RBAC - *Role-Based Access Control*) pour cloisonner les accès selon les responsabilités de chacun sur le chantier :

| Rôle | Page d'atterrissage | Permissions & Périmètre |
|---|---|---|
| **Admin** | `/dashboard` | Accès total : paramétrage de l'application, gestion financière, clôtures fiscales ISCA, configuration des connecteurs Dolibarr/Supabase. |
| **Superutilisateur** | `/dashboard` | Supervision des chantiers et des techniciens, validation des budgets, consultation des journaux système. |
| **Chef de Projet** | `/chantiers` ou `/clients` | Création et planification des chantiers, ordonnancement des étapes, affectation des techniciens, suivi d'avancement. |
| **Technicien** | `/techniciens` | Consultation des interventions assignées, validation des étapes de chantier, upload de photos avant/après, saisie du compte-rendu. |
| **Client** | `/clients` | Consultation de l'avancement du chantier, téléchargement des factures/devis, signature électronique des réceptions de travaux. |

### 1.2 Mécanisme de Garde et Redirection
Le routeur `GoRouter` (`lib/routes/app_routes.dart`) coopère avec le widget de garde `AccessShell` (`lib/features/auth/views/widgets/access_shell.dart`) :
- **État Invité (`UserStatus.guest`) :** Redirection immédiate vers `/login`.
- **État Authentifié (`UserStatus.authenticated` / `loaded`) :** Vérification de l'existence du document utilisateur dans Firestore/Hive. Si l'utilisateur tente d'accéder à une ressource non autorisée, il est renvoyé vers `/unauthorized` (`UnauthorizedScreen`).
- **Contrôle d'accès au niveau entité (`AccessControlMixin`) :** Pour les documents sensibles (ex: devis ou factures), l'accès n'est autorisé que si `entity.canRead(currentUser)` renvoie `true`.

---

## 2. Gestion des Projets et Chantiers

Le module Chantier est le cœur opérationnel de BatTrack.

### 2.1 Hiérarchie des Données
L'organisation structurelle d'un chantier suit un découpage en cascade :

```
PROJET (Client, Adresse, Date de début, Budget global)
  └── CHANTIER (Identifiant, Nom, Statut, Budget dédié)
        ├── ÉTAPES (Jalons chronologiques, statut, photos, validation)
        ├── PIÈCES (Zones physiques : Salon, Toiture, Façade...)
        ├── INTERVENTIONS (Tâches opérationnelles, techniciens assignés)
        └── FACTURES / DEVIS (Lignes de travaux, TVA ADEME, acomptes)
```

### 2.2 Cycle de Vie des Étapes de Chantier (`ChantierEtape`)
Chaque étape traverse trois états :
1. **À faire (`todo`) :** Étape planifiée, ressources non engagées.
2. **En cours (`in_progress`) :** Travaux en cours, saisie des pièces jointes et heures.
3. **Terminée (`done`) :** Travaux achevés, jalon verrouillé pour le calcul de facturation.

#### Fonctionnalités de l'écran Détail d'Étape (`ChantierEtapeDetailScreen`) :
- **Basculement instantané (`_toggleTerminee`) :** Clic direct pour marquer l'étape comme achevée avec mise à jour immédiate de la progression globale du chantier.
- **Ajout de Pièces Jointes (`_addPieceJointe`) :** Sélection de fichiers via `FilePicker` (photos JPG/PNG du terrain, plans ou rapports PDF). Les fichiers sont horodatés et liés à l'étape.
- **Ouverture native des fichiers :** Consultation directe des plans et justificatifs via `open_filex`.

### 2.3 Vue Planning Kanban & Timeline Interactive
Deux vues complémentaires permettent de visualiser et réorganiser les étapes :
1. **Tableau Kanban (`KanbanPlanningScreen` & `KanbanColumn`) :** Les étapes sont regroupées en colonnes (« À faire », « En cours », « Terminé »). L'artisan peut glisser-déposer (*drag-and-drop*) une carte d'une colonne à l'autre ; la modification est persistée immédiatement en local et synchronisée en tâche de fond.
2. **Timeline Interactive Réordonnable (`ChantierEtapeKanbanInteractive`) :** Permet de modifier l'ordre chronologique des étapes d'un chantier par glisser-déposer. L'indice `ordre` de chaque étape est recalculé automatiquement.

---

## 3. Gestion des Pièces et Métrés

Le sous-module Pièces (`ChantierPiecesScreen` & `PieceCard`) permet d'associer les travaux à des espaces physiques :
- Saisie des dimensions (longueur, largeur, hauteur sous plafond) et calcul automatique des surfaces au sol et murales.
- Association des matériaux et équipements prévus pour chaque pièce.
- Suivi du taux d'achèvement pièce par pièce pour faciliter la réception intermédiaire avec le client.

---

## 4. Gestion des Interventions Terrain

L'entité `Intervention` matérialise le travail ponctuel d'un ou plusieurs intervenants :
- **Champs principaux :** Titre, description, date de création, technicien affecté, statut (En cours, Réalisée, Annulée), chantier de rattachement.
- **Visualisations Statistiques (`AnimatedInterventionChart`) :**
  - Graphique circulaire (Camembert FL Chart) montrant la répartition des interventions par statut.
  - Histogramme (Bar Chart) présentant la charge de travail par projet ou par période.
- **Génération de Fiche d'Intervention :** Production automatique d'un PDF récapitulant les travaux réalisés, les signatures et les pièces jointes associées.

---

## 5. Gestion des Techniciens et Affectations

Le module Technicien (`TechniciensScreen`, `TechnicienDetailScreen`, `TechHomeScreen`) offre :
- **Recherche & Filtrage dynamique :** Filtrage textuel par nom, compétences ou disponibilité via `RechercheTechnicienScreen`.
- **Dialogue d'Affectation Rapide (`AssignTechnicienDialog`) :** Permet à un chef de projet d'assigner un technicien à un chantier ou à une intervention spécifique en un clic.
- **Espace Dédié Technicien (`TechHomeScreen`) :** Interface simplifiée sur smartphone pour le technicien, affichant uniquement ses chantiers du jour et ses interventions prioritaires.

---

## 6. Module de Facturation & Devis

### 6.1 Brouillons de Facture (`FactureDraft`)
Pour éviter toute écriture fiscale prématurée, l'application gère les factures sous forme de brouillons éditables :
- Saisie des lignes de prestations, matériaux et main-d'œuvre.
- Calcul en direct du total Hors Taxes (`totalHT`), du montant de la TVA (`totalTVA`) et du montant Toutes Taxes Comprises (`totalTTC`).
- Possibilité d'inclure des acomptes déjà perçus et de calculer le solde restant dû.

### 6.2 Validation Multilatérale
Une facture ne peut être finalisée et scellée que lorsque :
- Le chef de projet a validé le décompte des travaux.
- Le client a apposé sa signature manuscrite vectorielle via le composant tactile `Signature`.

---

## 7. Moteur Écologique ADEME (TVA Réglementaire)

Conformément aux directives de l'Agence de la Transition Écologique (ADEME) et du Code Général des Impôts (CGI), BatTrack intègre un moteur de calcul intelligent de la TVA :

1. **Taux Réduit à 5.5% (Transition Énergétique) :**
   - Travaux d'amélioration de la qualité énergétique (isolation thermique, pompes à chaleur, chaudières biomasse).
   - Travaux induits indissociablement liés aux économies d'énergie.
2. **Taux Intermédiaire à 10% (Amélioration & Rénovation) :**
   - Travaux d'aménagement, de transformation et d'entretien sur des logements achevés depuis plus de 2 ans.
3. **Taux Normal à 20% :**
   - Travaux de construction neuve, extensions importantes ou équipements sanitaires haut de gamme.

Le moteur audite la nature des matériaux et prestations pour ventiler automatiquement les montants sur les bons taux de TVA, prévenant ainsi les redressements fiscaux pour les artisans.

---

## 8. Conformité Fiscale ISCA (Loi Anti-Fraude TVA)

Pour se conformer aux exigences de l'article 88 de la Loi de Finances (systèmes d'encaissement inaltérables), BatTrack intègre le service d'audit `IscalAuditService` (`lib/core/compliance/iscal_audit_service.dart`).

### 8.1 Scellement par Chaînage Cryptographique (SHA-256)
Chaque fois qu'une facture est marquée comme réglée, l'opération `sealFacture()` est déclenchée :
1. **Récupération du dernier scellé :** Le hash de la dernière transaction (`previousHash`) est lu depuis la collection `fiscal_audit_logs`. Si aucun scellé n'existe, le hash initial (`IscaEngine.initialHash`) est utilisé.
2. **Construction du Payload :** Un condensat immuable est formé :
   ```json
   {
     "factureId": "FAC-2026-0042",
     "amountHt": 12500.0,
     "clientId": "CLI-882",
     "timestamp": "2026-11-15T18:30:00.000Z"
   }
   ```
3. **Calcul du Hash Chaîné :**
   $$\text{currentHash} = \text{SHA-256}(\text{action} + \text{payload} + \text{previousHash})$$
4. **Persistance inaltérable :** L'enregistrement scellé est sauvegardé dans le stockage distant. Aucune modification ultérieure de la facture n'est possible sans briser la chaîne.

### 8.2 Vérification d'Intégrité de la Chaîne (`verifyChainIntegrity`)
Le système permet à tout moment de recalculer l'intégralité de la chaîne depuis le premier bloc :
- Si un enregistrement a été falsifié ou supprimé directement dans la base de données, la fonction détecte la rupture et renvoie `false`.
- Le widget visuel `FiscalIntegrityIndicator` situé dans la barre d'outils du Dashboard affiche en vert un bouclier certifié (`Icons.verified_user`) ou en rouge une alerte d'intégrité compromise (`Icons.gpp_maybe`).

### 8.3 Clôtures Périodiques Obligatoires (`generateClosure`)
Le système génère des scellés de clôture périodiques pour figer les comptes :
- **Clôture Journalière (`ClosurePeriod.daily`) :** Fin de journée, totalisation des encaissements du jour.
- **Clôture Mensuelle (`ClosurePeriod.monthly`) :** Clôture mensuelle pour transmission au comptable.
- **Clôture Annuelle (`ClosurePeriod.annual`) :** Bilan d'exercice scellé définitif.
Toute tentative de modifier une facture appartenant à une période clôturée est rejetée avec l'exception `'Période déjà clôturée'`.

---

## 9. Dashboard Intelligent & Projections de Trésorerie

Le tableau de bord (`DashboardScreen`) réunit des indicateurs opérationnels et financiers en temps réel :

### 9.1 Le Moteur de Projection (`ProjectionEngine`)
Le moteur calcule la projection de trésorerie (`CashflowProjection`) en croisant l'avancement physique des chantiers et les données de facturation :
- **Chiffre d'Affaires Réalisé (`currentRevenue`) :** Somme des factures intégralement validées et réglées.
- **Factures en Attente (`pendingInvoices`) :** Montants facturés mais non encore réglés par le client.
- **Chiffre d'Affaires Potentiel (`potentialRevenue`) :**
  $$\text{Potentiel} = \text{Réalisé} + \text{Factures en attente} + \text{Valorisation des étapes en cours}$$
- **Taux d'Achèvement Global (`completionRate`) :**
  $$\text{Taux} = \frac{\text{Étapes terminées}}{\text{Nombre total d'étapes}}$$

### 9.2 Détection d'Anomalies Système
Le `DashboardScreen` surveille en continu le journal des actions système (`LoggerNotifier`) :
- **Alerte suppressions abusives :** Si plus de 5 suppressions sont détectées sur une session, un encart d'avertissement rouge s'affiche en haut de l'écran.
- **Alerte surcharge d'activité :** Détection de pics d'activité inhabituels pouvant indiquer un dysfonctionnement ou une tentative de manipulation.

---

## 10. Génération de Documents PDF & Signature Vectorielle

L'application intègre des générateurs de documents haute fidélité conformes aux normes professionnelles françaises :
- **Facture & Devis (`FacturePdfGenerator`) :**
  - En-tête de l'entreprise artisanale avec coordonnées complètes.
  - Détail du client et identification du chantier rattaché.
  - Tableau des prestations avec prix unitaire HT, quantité, taux de TVA appliqué.
  - Récapitulatif ventilé des bases HT par taux de TVA (5.5%, 10%, 20%) et totaux TTC.
  - Intégration de la signature tactile numérisée du client.
  - Liste des pièces jointes et photos associées au compte-rendu.
- **Impression et Partage :** Intégration native avec le module `Printing` permettant d'imprimer directement via Wi-Fi/Bluetooth ou d'exporter le fichier PDF vers les applications de messagerie (WhatsApp, Mail).

---

## 11. Connecteur ERP Dolibarr

Pour les entreprises utilisant l'ERP/CRM open-source **Dolibarr** :
- **Explorateur d'Endpoints (`DolibarrExplorerScreen`) :** Outil de diagnostic pour tester les requêtes sur les endpoints REST de Dolibarr, visualiser le JSON retourné avec coloration et exporter les réponses sous forme de fichier.
- **Synchronisation Globale (`DolibarrSyncService`) :** Importe en masse les tiers (clients), projets, tâches et utilisateurs vers la base de données locale Hive.
- **Multi-Instances (`InstancePickerScreen` / `InstanceSelectorDialog`) :** Possibilité de configurer plusieurs instances Dolibarr (par exemple pour gérer plusieurs filiales ou sociétés d'un même groupe).

---

## 12. Synchronisation de Catalogue via Google Sheets

Pour les artisans tenant leur catalogue de prix sur un tableur partagé :
- Le service `GoogleSheetsProductService` interroge directement l'API **Google Sheets v4**.
- La plage de cellules `Produits!A2:Z` est scannée à la demande.
- Les colonnes (Référence, Désignation, Prix unitaire, Unité, Taux TVA) sont automatiquement mappées vers des objets Dart `Produit` et injectées dans le catalogue local.

---

## 13. Visualisation de Maquettes 3D / BIM (BTP 4.0)

Grâce au package `model_viewer_plus`, BatTrack propose une visualisation 3D interactive :
- Chargement de modèles au format **glTF** et **OBJ**.
- Rotation, zoom et inspection spatiale des zones d'intervention directement sur le smartphone ou la tablette de l'artisan.
- Prise en charge de la réalité virtuelle mobile / gyroscope pour naviguer à l'échelle 1:1 dans le futur bâtiment.
