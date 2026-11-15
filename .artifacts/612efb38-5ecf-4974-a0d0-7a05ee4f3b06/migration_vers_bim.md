# MISSION

Tu es l'architecte logiciel principal du projet `bat_track_v1`.

Le projet est une application Flutter destinée à la construction 4.0.

Repository :
https://github.com/godzyken/bat_track_v1

Ta mission est de faire évoluer progressivement BatTrack V1 vers une plateforme capable d'exploiter des données BIM provenant notamment de :

* SketchUp
* Revit
* Archicad
* autres logiciels compatibles IFC

L'objectif n'est PAS de transformer BatTrack en logiciel de modélisation 3D.

L'objectif est de faire de BatTrack la couche opérationnelle située entre :

CONCEPTION BIM
→ MODÈLE IFC
→ BATTRACK
→ CHANTIER
→ MÉTRÉS
→ TÂCHES
→ MATÉRIAUX
→ COÛTS
→ AVANCEMENT
→ ANOMALIES
→ PRÉ-DEVIS
→ ANALYSE DE PROJET

---

# 1. RÈGLE ABSOLUE

AVANT DE MODIFIER LE CODE :

1. analyser entièrement le repository ;
2. identifier l'architecture actuelle ;
3. identifier les modèles existants ;
4. identifier les repositories ;
5. identifier les services ;
6. identifier les providers Riverpod ;
7. identifier la base de données Drift ;
8. identifier les modèles déjà utilisables pour les projets, chantiers, tâches, matériaux, documents et utilisateurs ;
9. identifier les éventuels systèmes Firebase/Supabase ;
10. identifier les composants 3D déjà présents ;
11. identifier les éventuelles fonctionnalités déjà prévues pour le BIM ;
12. vérifier les tests existants.

NE PAS recréer une architecture parallèle si une abstraction existante peut être étendue proprement.

NE PAS supprimer une fonctionnalité existante pour introduire le BIM.

NE PAS casser les fonctionnalités existantes.

NE PAS remplacer Riverpod, Drift, Firebase ou Supabase sans justification technique explicite.

---

# 2. OBJECTIF ARCHITECTURAL

Créer une nouvelle feature :

lib/features/bim/

avec une architecture compatible avec l'architecture actuelle de BatTrack.

Structure cible indicative :

lib/features/bim/

```
domain/
    entities/
        bim_project.dart
        bim_building.dart
        bim_storey.dart
        bim_space.dart
        bim_element.dart
        bim_type.dart
        bim_property.dart
        bim_quantity.dart
        bim_relationship.dart
        bim_issue.dart

    repositories/
        bim_repository.dart

data/
    datasources/
        ifc_datasource.dart
        bim_local_datasource.dart
        bim_remote_datasource.dart
        bcf_datasource.dart

    models/
        bim_project_model.dart
        bim_element_model.dart
        bim_property_model.dart
        bim_quantity_model.dart
        bim_issue_model.dart

    repositories/
        bim_repository_impl.dart

application/
    services/
        bim_import_service.dart
        bim_analysis_service.dart
        bim_quantity_service.dart
        bim_element_link_service.dart
        bim_issue_service.dart

    providers/
        bim_providers.dart

presentation/
    pages/
        bim_project_page.dart
        bim_import_page.dart
        bim_viewer_page.dart
        bim_elements_page.dart

    widgets/
        bim_model_tree.dart
        bim_element_card.dart
        bim_element_properties.dart
        bim_quantity_panel.dart
        bim_issue_panel.dart
        bim_viewer.dart
```

Cette structure est indicative.

Adapter la structure aux conventions réellement utilisées dans le repository.

---

# 3. CONCEPT CENTRAL

BatTrack doit distinguer trois choses :

A. DONNÉES BIM

Ce qui vient du modèle IFC.

B. DONNÉES MÉTIER BATTRACK

Ce qui appartient au fonctionnement du chantier.

C. RELATION ENTRE LES DEUX

Exemple :

IfcWall
↓
BimElement
↓
BatTrackTask
↓
chantier
↓
ouvrier
↓
matériau
↓
coût
↓
avancement

Ne jamais mélanger directement les données IFC avec les modèles métier existants.

Un élément BIM doit pouvoir exister sans tâche BatTrack.

Une tâche BatTrack doit pouvoir exister sans élément BIM.

La relation doit être explicite.

---

# 4. MODÈLE BIM MINIMAL

Créer un modèle générique `BimElement`.

Il doit pouvoir contenir au minimum :

* id interne BatTrack
* globalId IFC
* ifcType
* name
* description
* objectType
* projectId
* buildingId
* storeyId
* spaceId
* parentId
* typeId
* properties
* quantities
* sourceFileId
* geometryReference
* createdAt
* updatedAt

Exemple :

BimElement(
id: "...",
globalId: "3KJH82...",
ifcType: "IfcWall",
name: "Mur extérieur",
objectType: "Mur",
storeyId: "...",
properties: {...},
quantities: {...}
)

---

# 5. PROPRIÉTÉS BIM

Ne pas coder en dur toutes les propriétés IFC.

Utiliser une structure générique.

Exemple :

BimProperty :

* name
* value
* valueType
* unit
* propertySet
* source

Exemple :

Pset_WallCommon
IsExternal = true
ThermalTransmittance = 0.25
LoadBearing = true

L'objectif est de pouvoir accepter de nouvelles propriétés sans modifier le modèle Dart.

---

# 6. QUANTITÉS BIM

Créer un système générique pour les quantités.

Exemple :

BimQuantity :

* name
* value
* unit
* source

Pouvoir gérer :

* longueur
* largeur
* hauteur
* surface
* volume
* poids
* quantité

Exemples :

GrossArea = 24.5 m2

NetArea = 21.2 m2

Volume = 4.8 m3

Length = 12.5 m

Ces données devront pouvoir alimenter ultérieurement les métrés et le pré-devis.

---

# 7. HIÉRARCHIE DU BÂTIMENT

Le modèle doit conserver la hiérarchie IFC.

Projet

→ Site

→ Building

→ Storey

→ Space

→ Element

Exemple :

Projet Maison Martin

```
Building
    Maison principale

        Storey
            RDC

                Space
                    Cuisine

                        Element
                            Mur
                            Porte
                            Fenêtre
                            Évier
```

Cette hiérarchie doit être exploitable dans l'interface.

---

# 8. IMPORT IFC

Créer un service d'import indépendant de l'interface.

Exemple :

BimImportService.importIfc(File file)

Le service doit :

1. vérifier le fichier ;
2. identifier la version IFC ;
3. créer un `BimProject` ;
4. extraire les entités ;
5. extraire les propriétés ;
6. extraire les quantités disponibles ;
7. reconstruire la hiérarchie ;
8. créer les relations ;
9. stocker les données ;
10. retourner un résultat d'import détaillé.

Le service doit être conçu pour permettre ultérieurement plusieurs moteurs IFC.

NE PAS coupler toute l'application à une seule librairie IFC.

---

# 9. STRATÉGIE IFC

Utiliser IFC comme format d'échange BIM principal.

Cibler en priorité :

IFC 4.3

mais prévoir une compatibilité progressive avec :

IFC 4
IFC 2x3

Ne jamais supposer qu'un modèle IFC contient toutes les données nécessaires.

Le système doit gérer :

* données absentes ;
* propriétés inconnues ;
* quantités absentes ;
* géométrie absente ;
* éléments non reconnus ;
* versions IFC différentes.

---

# 10. 3D

NE PAS essayer de faire afficher directement l'IFC dans `model_viewer_plus`.

Le viewer actuel fonctionne avec glTF/GLB.

Architecture :

IFC
↓
BIM processing
↓
GLB / glTF
↓
ModelViewer
↓
Flutter

Le viewer doit être considéré comme une couche de visualisation.

Il ne doit pas être responsable de la logique métier BIM.

---

# 11. IDENTIFICATION D'UN OBJET 3D

Le futur système doit permettre :

Utilisateur clique sur un objet 3D

↓

BatTrack récupère son identifiant

↓

BatTrack retrouve :

BimElement

↓

affiche :

* nom
* type IFC
* propriétés
* quantités
* étage
* pièce
* lot
* tâches
* matériaux
* coûts
* avancement
* photos
* anomalies

Prévoir dès maintenant une architecture permettant cette correspondance.

---

# 12. LIEN BIM ↔ CHANTIER

Créer un mécanisme de relation :

BimElement ↔ BatTrackTask

Exemple :

IfcDoor_001

↓

Task :

"Pose porte chambre 01"

↓

Status :

IN_PROGRESS

↓

Progress :

60%

↓

Worker :

Jean

↓

Material :

Bloc porte 83cm

↓

Cost :

450 €

Cette relation est une fonctionnalité centrale.

---

# 13. LIEN BIM ↔ MATÉRIAUX

Prévoir :

BimElement

↔

MaterialRequirement

↔

Material

Exemple :

IfcBoiler_026

→ chauffe-eau thermodynamique

→ référence fournisseur

→ quantité 1

→ coût achat

→ coût pose

→ statut livraison

→ statut installation

---

# 14. LIEN BIM ↔ COÛTS

Prévoir une architecture permettant :

Element BIM
→ quantité
→ prix unitaire
→ coût estimé
→ coût réel

Exemple :

26 chauffe-eau

quantité = 26

prix unitaire = 1250 €

coût estimé = 32500 €

Puis comparer avec :

coût réel

marge

écart

---

# 15. BIM ↔ PRÉ-DEVIS

Créer dès maintenant les interfaces nécessaires pour permettre ultérieurement :

IFC

↓

analyse

↓

quantités

↓

lots

↓

travaux

↓

questions manquantes

↓

pré-devis

NE PAS implémenter immédiatement un moteur commercial complexe.

Créer les abstractions nécessaires.

---

# 16. LOTS MÉTIERS

Prévoir une classification métier indépendante de IFC.

Exemple :

IfcSanitaryTerminal

→ plomberie

IfcBoiler

→ chauffage

IfcWindow

→ menuiserie

IfcWall

→ gros œuvre / isolation / peinture selon contexte

La correspondance doit être configurable.

Ne pas coder :

if (ifcType == "IfcWall") lot = "gros_oeuvre"

sans système de mapping extensible.

Créer plutôt :

BimTradeMapping

avec :

ifcType
objectType
classification
trade
confidence
rules

---

# 17. MOTEUR DE CLASSIFICATION

Prévoir :

BimElement

↓

classification

↓

lot métier

↓

type de prestation

Exemple :

IfcBoiler

↓

Chauffage

↓

Installation chauffe-eau

Le moteur doit pouvoir être enrichi ultérieurement par des règles IA.

---

# 18. BCF / ANOMALIES

Prévoir une entité `BimIssue`.

Elle doit pouvoir contenir :

* id
* titre
* description
* statut
* priorité
* auteur
* responsable
* élément BIM concerné
* position
* photo
* commentaire
* createdAt
* updatedAt

Prévoir une évolution future vers le standard BCF.

Ne pas implémenter toute la spécification BCF maintenant.

Créer uniquement une architecture compatible.

---

# 19. BASE DE DONNÉES

Étudier la base Drift existante avant toute modification.

Créer les tables BIM uniquement si nécessaire.

Prévoir au minimum :

bim_projects

bim_buildings

bim_storeys

bim_spaces

bim_elements

bim_properties

bim_quantities

bim_relationships

bim_issues

bim_files

Ne pas stocker inutilement la géométrie lourde dans Drift.

Stocker plutôt :

* métadonnées ;
* références ;
* IDs ;
* propriétés ;
* relations ;
* chemins ;
* URLs ;
* hashes.

La géométrie doit rester dans un stockage adapté.

---

# 20. STOCKAGE DES FICHIERS

Les modèles BIM peuvent être lourds.

Prévoir :

Local cache
+
Cloud Storage

Architecture :

BimFile

* id
* projectId
* filename
* format
* version
* size
* checksum
* localPath
* remoteUrl
* createdAt

Formats prévus :

.ifc
.glb
.gltf
.bcf
.pdf
.dwg si support futur
.dxf si support futur
.skp si intégration future

NE PAS prétendre parser directement SKP si aucune librairie fiable n'est disponible.

Pour SketchUp, privilégier dans un premier temps :

SketchUp
→ export IFC
→ BatTrack

---

# 21. OFFLINE FIRST

BatTrack étant destiné au chantier, le BIM doit supporter autant que possible le fonctionnement hors ligne.

Le chantier peut avoir :

* mauvaise connexion ;
* absence de réseau ;
* tablette ;
* téléphone ;
* PC.

Les métadonnées BIM utiles au chantier doivent être disponibles localement après synchronisation.

Prévoir :

Local BIM cache

↓

travail offline

↓

queue de synchronisation

↓

cloud

---

# 22. PERFORMANCE

NE PAS charger un modèle BIM entier en mémoire dans tous les écrans.

Prévoir :

* chargement différé ;
* pagination ;
* niveaux ;
* pièces ;
* catégories ;
* lots ;
* filtrage ;
* cache.

Exemple :

Projet

→ Building

→ Storey

→ Space

→ Elements

Ne charger les éléments détaillés que lorsque nécessaire.

---

# 23. INTERFACE

Créer progressivement une interface BIM.

Écran :

BIM PROJECT

---

[ Importer modèle ]

[ Modèle 3D ]

[ Arborescence ]

[ Quantités ]

[ Lots ]

[ Tâches ]

[ Anomalies ]

---

Modèle :

Building
├── RDC
│    ├── Cuisine
│    ├── Salon
│    └── Salle de bain
│
└── Étage
├── Chambre 1
├── Chambre 2
└── Salle de bain

---

Sélection :

IfcSanitaryTerminal

WC

Appartement 02

Lot plomberie

Avancement 50%

---

---

# 24. VIEWER 3D

Créer un composant :

BimViewer

Responsabilités :

* afficher le modèle ;
* rotation ;
* zoom ;
* caméra ;
* sélection future ;
* affichage/masquage catégories ;
* navigation.

NE PAS mettre les règles métier dedans.

Prévoir une abstraction :

abstract class BimViewerAdapter

Ainsi un autre viewer pourra être ajouté ultérieurement.

---

# 25. ROADMAP D'IMPLÉMENTATION

NE PAS tenter de tout développer en une seule fois.

Implémenter les phases suivantes.

PHASE 0

Audit du repository.

Produire :

* architecture actuelle ;
* dépendances ;
* modèles existants ;
* DB ;
* risques ;
* conflits potentiels.

Aucune modification fonctionnelle.

---

PHASE 1

BIM domain model.

Créer :

BimProject
BimBuilding
BimStorey
BimSpace
BimElement
BimProperty
BimQuantity
BimRelationship

Créer les tests unitaires.

---

PHASE 2

BIM persistence.

Ajouter les tables Drift nécessaires.

Créer :

* DAO
* repository
* mappers
* tests

---

PHASE 3

Import IFC.

Créer l'abstraction :

IfcParser

avec une implémentation initiale.

L'implémentation doit rester isolée.

---

PHASE 4

BIM explorer.

Afficher :

Projet
→ bâtiments
→ niveaux
→ pièces
→ éléments

---

PHASE 5

3D.

Connecter la représentation GLB/glTF au projet BIM.

Conserver `model_viewer_plus` comme couche de visualisation si elle reste adaptée.

---

PHASE 6

BIM → tâche chantier.

Permettre de créer une tâche à partir d'un élément BIM.

---

PHASE 7

BIM → quantité.

Permettre d'utiliser les quantités BIM dans les métrés.

---

PHASE 8

BIM → pré-devis.

Créer les premières abstractions de calcul.

---

PHASE 9

BCF / anomalies.

---

PHASE 10

IA.

Uniquement après stabilisation des données BIM.

---

# 26. IA FUTURE

L'IA ne doit PAS être utilisée pour remplacer les données structurées IFC.

Architecture future :

IFC
+
Photos
+
Plans
+
Historique chantier
+
Questionnaire

↓

BIM Data Layer

↓

Rules Engine

↓

AI Assistant

L'IA pourra ensuite :

* identifier les éléments pertinents ;
* détecter des données manquantes ;
* proposer des questions ;
* classer les travaux ;
* proposer des lots ;
* détecter des incohérences ;
* assister le pré-devis ;
* résumer le projet.

Mais elle ne doit jamais inventer une quantité BIM absente sans la signaler comme estimation.

---

# 27. TRAÇABILITÉ

Toute donnée calculée doit pouvoir être distinguée de la donnée source.

Utiliser des statuts du type :

SOURCE

DERIVED

ESTIMATED

USER_CONFIRMED

AI_SUGGESTED

Exemple :

Surface mur :

24.5 m²

source = IFC

Alors que :

Prix pose :

950 €

source = estimation BatTrack

Cela est essentiel pour éviter de présenter une estimation comme une donnée réelle.

---

# 28. TEST PROJECT

Créer un projet BIM de démonstration.

Exemple :

Maison test

RDC

Cuisine

Salon

Salle de bain

2 chambres

Le projet doit permettre de tester :

* import ;
* arborescence ;
* éléments ;
* propriétés ;
* quantités ;
* viewer ;
* sélection ;
* tâche ;
* coût ;
* avancement.

---

# 29. TESTS

Chaque nouvelle couche doit avoir des tests.

Minimum :

Domain tests

Repository tests

Database tests

Import tests

Mapping tests

Quantity tests

Provider tests

Widget tests

Integration tests

Créer notamment un test :

IFC file
→ import
→ BimProject
→ BimElement
→ quantity
→ database

---

# 30. COMPATIBILITÉ AVEC L'EXISTANT

Avant chaque migration :

flutter analyze

flutter test

Puis après chaque phase :

flutter analyze

flutter test

Ne jamais continuer si une régression importante apparaît.

---

# 31. RÈGLE DE DÉVELOPPEMENT

Ne pas créer de "fake implementation" présentée comme fonctionnelle.

Si un parser IFC réel n'est pas disponible :

créer l'abstraction

* mock

* test

* TODO explicite

mais ne jamais prétendre que l'import IFC fonctionne.

Même principe pour :

* BCF
* SKP
* DWG
* IA
* conversion IFC → GLB

---

# 32. DOCUMENTATION

Créer :

docs/bim/

```
architecture.md
data-model.md
ifc.md
viewer.md
mapping.md
roadmap.md
```

Documenter :

* architecture ;
* choix techniques ;
* limites ;
* formats supportés ;
* conversions ;
* stockage ;
* sécurité ;
* performances.

---

# 33. LIVRABLE FINAL DE CHAQUE PHASE

Après chaque phase, fournir :

1. fichiers créés ;
2. fichiers modifiés ;
3. architecture ;
4. dépendances ajoutées ;
5. migrations DB ;
6. tests ;
7. commandes de génération ;
8. limitations ;
9. risques ;
10. prochaine étape.

NE PAS passer silencieusement à la phase suivante.

---

# 34. PRIORITÉ TECHNIQUE

Ordre absolu :

1. stabilité de BatTrack existant ;
2. architecture BIM ;
3. données IFC ;
4. persistance ;
5. relations BIM/métier ;
6. quantités ;
7. visualisation 3D ;
8. chantier ;
9. pré-devis ;
10. IA.

La 3D est une interface.

Les données BIM sont le cœur.

Le chantier est la finalité.

Le pré-devis est une exploitation avancée.

L'IA est une couche d'assistance.

---

# 35. PREMIÈRE ACTION

NE MODIFIE PAS LE CODE immédiatement.

Commence par réaliser l'audit du repository `bat_track_v1`.

Retourne un rapport structuré :

## A. Architecture actuelle

## B. Fonctionnalités existantes

## C. Modèles métier existants

## D. Base de données

## E. Services

## F. Riverpod

## G. Gestion des fichiers

## H. 3D existante

## I. Ce qui peut être réutilisé

## J. Ce qui doit être modifié

## K. Ce qui manque

## L. Risques techniques

## M. Architecture BIM proposée

## N. Plan de migration par commits

## O. Phase 1 recommandée

NE MODIFIE AUCUN FICHIER AVANT LA FIN DE CET AUDIT.

Une fois l'audit terminé, proposer la Phase 1 sous forme de plan d'implémentation précis.
