# 04. UI / UX & Design System

Ce document présente l'identité visuelle, l'expérience utilisateur (UX), le système adaptatif multi-écrans et le catalogue des composants d'interface de l'application **BatTrack v1**.

---

## 1. Principes Directeurs de Design (BTP Terrain)

L'interface de BatTrack a été pensée pour répondre aux conditions réelles d'utilisation sur les chantiers de construction :
- **Lisibilité sous fort ensoleillement :** Contrastes élevés, typographie nette (**Noto Sans**), icônes explicites et larges zones tactiles (minimum 48x48 dp pour manipulation avec des gants de chantier).
- **Feedback visuel immédiat (Optimistic UI) :** Toute action (cocher une étape terminée, déplacer une tâche Kanban) produit une réaction instantanée à l'écran sans attendre la confirmation réseau.
- **Zéro perte de données en mobilité :** Enregistrement automatique en continu, boutons d'annulation/rétablissement (**Undo / Redo**) et indicateur transparent de l'état de connectivité.

---

## 2. Charte Graphique & Thématisation

L'application respecte les spécifications de **Material 3 (Material You)**.

### 2.1 Palette de Couleurs

| Rôle Sémantique | Teinte Flutter | Signification & Usage |
|---|---|---|
| **Primaire** | `Colors.indigo` (`#3F51B5`) | Couleur d'accent principale, en-têtes d'AppBar, boutons d'action majeurs. |
| **Sécurité / Attention** | `Colors.amber` / `Colors.orange` | Alertes de connectivité hors-ligne, étapes en cours de réalisation. |
| **Validation / Succès** | `Colors.green` (`#4CAF50`) | Étapes achevées, intégrité fiscale ISCA vérifiée, factures réglées. |
| **Danger / Anomalie** | `Colors.redAccent` | Anomalies détectées au dashboard, suppressions, rupture de scellement. |
| **Surfaces & Cartes** | Blanc pur / Gris ardoise foncé | Cartes avec élévation subtile pour hiérarchiser les blocs d'information. |

### 2.2 Typographie
- Police principale : `NotoSans`.
- Tailles normalisées :
  - `Display / Header` (24–28 sp, Bold) : Titres des chantiers et en-têtes de factures.
  - `Title` (18–20 sp, Semi-Bold) : Noms des étapes, des sections et des tiers.
  - `Body` (14–16 sp, Regular) : Descriptions des travaux, montants et métrés.
  - `Caption` (11–12 sp) : Horodatages, statuts de synchronisation et hachages fiscaux.

### 2.3 Modes Clair et Sombre
Définis dans `lib/features/parametres/affichage/themes/theme.dart` :
- `lightTheme` : Thème lumineux optimisé pour l'extérieur et la journée.
- `darkTheme` : Thème sombre préservant la batterie en mobilité et le confort visuel en intérieur peu éclairé.
- `ThemeMode.system` : Basculement automatique selon les réglages de l'appareil.

---

## 3. Moteur Responsive Multi-Écrans

Le système responsive (`lib/core/responsive/wrapper/responsive_layout.dart`) adapte dynamiquement la disposition en fonction de la diagonale et de l'orientation de l'écran.

### 3.1 Breakpoints et Grilles

```
         < 600 px                    600 px - 1024 px                     >= 1024 px
    ┌────────────────┐            ┌────────────────────────┐         ┌────────────────────────────────┐
    │     MOBILE     │            │        TABLETTE        │         │        DESKTOP / WEB           │
    │   (1 Colonne)  │            │      (2 Colonnes)      │         │         (3 Colonnes)           │
    │  Padding: 12px │            │      Padding: 20px     │         │        Padding: 48x24px        │
    └────────────────┘            └────────────────────────┘         └────────────────────────────────┘
```

- **Mobile (`ScreenSize.mobile`) :** Navigation via tiroir latéral (`AppDrawer`) ou barre inférieure, cartes empilées verticalement pleine largeur.
- **Tablette (`ScreenSize.tablet`) :** Présentation en 2 colonnes (ex: graphiques de bord côte-à-côte, formulaire et prévisualisation simultanés).
- **Desktop / Web (`ScreenSize.desktop`) :** Menu latéral fixe (`SideMenu`), vue multi-panneaux (liste des chantiers à gauche, détail et timeline au centre, récapitulatif financier à droite).

### 3.2 L'Observateur Réactif : `ResponsiveObserver`
Enveloppant toute l'arborescence dans `main.dart`, `ResponsiveObserver` intercepte les changements de métriques d'affichage (`didChangeMetrics()`) et alimente deux providers Riverpod :
- `screenSizeProvider` : Renvoie `mobile`, `tablet` ou `desktop`.
- `screenOrientationProvider` : Renvoie `portrait` ou `landscape`.

---

## 4. Architecture de Navigation & Structure des Écrans

La navigation est pilotée par `GoRouter` (`lib/routes/app_routes.dart`).

```
                              [/login] ◄─── (Non connecté)
                                 │
                                 ▼
                              [/loading]
                                 │
                                 ▼ (Contrôle de rôle dans AccessShell)
           ┌─────────────────────┼─────────────────────┐
           ▼                     ▼                     ▼
     [/dashboard]           [/chantiers]          [/techniciens]
   (Admin / Super)        (Chef de Projet)         (Technicien)
```

### 4.1 Plan de Routage Complet

| Chemin d'accès | Écran (Widget) | Description Fonctionnelle |
|---|---|---|
| `/loading` | `LoadingApp` | Écran de démarrage et d'initialisation de Hive. |
| `/login` | `LoginScreen` | Formulaire d'authentification avec sélection du rôle. |
| `/register` | `RegisterScreen` | Création d'un nouveau compte utilisateur / artisan. |
| `/unauthorized` | `UnauthorizedScreen` | Écran de blocage en cas de droits insuffisants. |
| `/` | `HomeScreen` | Tableau d'accueil général de l'application. |
| `/profile` | `UserProfileScreen` | Profil de l'utilisateur connecté et coordonnées société. |
| `/dashboard` | `DashboardScreen` | Métriques BTP 4.0, projections de trésorerie et alertes. |
| `/chantiers` | `ChantiersScreen` | Liste paginée des chantiers avec statuts. |
| `/chantiers/:chantierId` | `ChantierDetailScreen` | Fiche détaillée d'un chantier avec ses jalons. |
| `.../etapes` | `ChantierEtapesScreen` | Liste chronologique des étapes du chantier. |
| `.../etapes/:etapeId` | `ChantierEtapeDetailScreen`| Détail d'une étape, validation et ajout de médias. |
| `.../etapes/:etapeId/pieces`| `ChantierPiecesScreen` | Pièces physiques et métrés rattachés à l'étape. |
| `.../interventions/:statut` | `InterventionsScreen` | Interventions filtrées par statut d'exécution. |
| `/techniciens` | `TechniciensScreen` | Répertoire des techniciens et disponibilités. |
| `/techniciens/:technicienId`| `TechnicienDetailScreen` | Fiche de compétences et chantiers affectés. |
| `/clients` | `ClientsScreen` | Annuaire des tiers et historique des travaux. |
| `/clients/:clientId` | `ClientHomeScreen` | Espace client dédié avec devis et factures. |
| `/documents` | `FacturesScreen` | Registre des factures émises et brouillons en cours. |
| `/documents/:documentId` | `FactureDetailScreen` | Visualisation et signature d'une facture. |
| `/equipements` | `EquipementListScreen` | Inventaire des engins, matériels et outillages. |
| `/projets` | `ProjectListScreen` | Vue globale portefeuille projets d'entreprise. |
| `/projets/:projetId` | `ProjectDetailScreen` | Synthèse technique et budgétaire d'un projet. |

---

## 5. Composants Métier Spécialisés

### 5.1 La Bannière de Connectivité : `ConnectivityBanner`
- Située en permanence au sommet de l'interface (`lib/core/widgets/connectivity_banner.dart`).
- Lorsque le réseau est actif : le bandeau est invisible.
- Dès que le signal est perdu : une bannière ambrée animée s'affiche avec la mention *« Mode Hors-Ligne — Vos données sont sauvegardées localement et seront synchronisées dès le retour du réseau »*.

### 5.2 L'Indicateur d'Intégrité Fiscale : `FiscalIntegrityIndicator`
- Situé dans la barre d'action de l'AppBar du Dashboard (`lib/core/widgets/fiscal_integrity_indicator.dart`).
- Affiche une icône de bouclier vert `Icons.verified_user` lorsque le calcul de la chaîne SHA-256 (`verifyChainIntegrity()`) est valide à 100%.
- Affiche un bouclier d'alerte `Icons.gpp_maybe` en cas d'incohérence détectée.

### 5.3 La Timeline Interactive : `ChantierEtapeKanbanInteractive`
- Visualisation verticale ou horizontale de l'ordre d'exécution des travaux.
- Permet au chef de chantier de déplacer une étape vers le haut ou vers le bas par appui long et glissement.
- Calcule immédiatement le pourcentage d'avancement du chantier.

### 5.4 Le Tableau Kanban : `KanbanPlanningScreen` & `KanbanColumn`
- Organise les étapes sous forme de cartes d'intervention réparties en 3 colonnes : « À faire », « En cours », « Terminé ».
- Chaque carte résume le titre de l'étape, la date cible et le nombre de photos associées.
- Le déplacement d'une carte d'une colonne à une autre met à jour l'entité en local instantanément via `DragTarget` et `Draggable`.

### 5.5 Formulaires Dynamiques Génériques : `JsonForm` & `EntityForm`
- `JsonForm` (`lib/models/views/widgets/json_form.dart`) inspecte l'adaptateur `JsonAdapter` d'un modèle pour construire dynamiquement les champs de saisie appropriés (texte, numérique, sélecteur de date, cases à cocher, listes déroulantes).
- Intègre une validation automatique des champs obligatoires et un contrôle d'erreurs en ligne.
- `EntityScreen` fournit par défaut les boutons `Undo` et `Redo` dans l'AppBar pour annuler ou répéter les modifications en cours.

---

## 6. Workflows et Parcours Utilisateurs Clés (UX Flows)

### Workflow 1 : Validation d'une Étape Terrain avec Photo
```
1. L'artisan ouvre l'application sur son smartphone (en ligne ou hors-ligne).
2. Navigation : Chantiers > Choix du chantier > Étapes > Choix de l'étape.
3. Clic sur "Ajouter une pièce jointe" -> La caméra ou la galerie s'ouvre.
4. L'artisan prend la photo des travaux d'isolation terminés.
5. La photo est enregistrée localement dans Hive et liée à l'étape.
6. Clic sur la case "Marquer comme terminée".
7. L'icône de l'étape passe au vert, et la barre de progression du chantier s'incrémente.
8. (Dès que l'artisan retrouve du réseau, l'image est téléversée sur Firebase Storage et l'étape est synchronisée sur Firestore).
```

### Workflow 2 : Signature & Scellement Fiscal d'une Facture
```
1. Le client et l'artisan vérifient le décompte sur `FactureDetailScreen`.
2. Le client appose sa signature manuscrite sur le canvas tactile.
3. Clic sur "Finaliser & Sceller la Facture".
4. Le système :
   a) Intègre la signature vectorielle dans la facture.
   b) Sollicite `IscalAuditService.sealFacture()`.
   c) Calcule le hash SHA-256 chaîné au précédent scellé.
   d) Enregistre la transaction scellée dans le journal d'audit.
   e) Génère le document PDF scellé définitif avec mention de conformité fiscale.
```

### Workflow 3 : Importation Express depuis Dolibarr ERP
```
1. L'administrateur accède au menu Dolibarr > "Synchronisation".
2. Clic sur "Synchroniser tout depuis Dolibarr".
3. L'application interroge les endpoints `/thirdparties`, `/projects`, `/tasks`.
4. Une barre de progression informe de l'avancée de la récupération.
5. Une fois terminée, les clients et chantiers apparaissent instantanément dans les listes locales de BatTrack sans aucune double saisie.
```
