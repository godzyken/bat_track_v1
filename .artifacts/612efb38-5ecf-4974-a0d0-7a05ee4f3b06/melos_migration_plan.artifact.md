# Plan d'Action : Migration vers Melos Monorepo

Ce plan détaille la transition de projets isolés vers un Monorepo unifié pour l'écosystème BTP 4.0, résolvant définitivement les problèmes de dépendances croisées.

## 🛠️ Objectifs
1.  **Unification :** Regrouper `bat_track_v1`, `compta4me`, `egote_services_v2` et `shared_models` sous une racine unique.
2.  **Productivité :** Automatiser les tâches (analyze, test, build) sur l'ensemble des packages via Melos.
3.  **CI/CD Robuste :** Simplifier GitHub Actions en utilisant `melos bootstrap` pour gérer les dépendances Git privées en local.

---

## 🏗️ Structure de la cible

La racine du monorepo sera située dans `C:/Users/soufi/StudioProjects/btp_4_0_ecosystem`.

```
btp_4_0_ecosystem/
├── melos.yaml                  ← Configuration Melos
├── pubspec.yaml                ← Workspace Flutter
├── .ai/                        ← Documentation globale de l'écosystème
├── AGENTS.md                   ← Protocole IA pour l'écosystème
└── packages/
    ├── bat_track_v1/           ← Projet actuel
    ├── compta4me/              ← Moteur financier
    ├── egote_services_v2/      ← Services écologiques
    └── shared_models/          ← Modèles communs
```

---

## 📋 Étapes d'implémentation

### 1. Initialisation de la Racine
- **[NEW]** `/melos.yaml` : Définition des packages et des scripts globaux.
- **[NEW]** `/pubspec.yaml` : Déclarer le workspace avec `melos`.

### 2. Migration des Projets (Action Utilisateur requise)
> [!IMPORTANT]
> Comme les projets sont des dépôts Git distincts, vous devrez déplacer manuellement les dossiers dans le répertoire `packages/` du monorepo ou utiliser des submodules (non recommandé pour Melos).

- Déplacer `bat_track_v1` vers `packages/bat_track_v1`.
- Déplacer `shared_models` vers `packages/shared_models`.

### 3. Configuration des Dépendances
#### [MODIFY] [bat_track_v1/pubspec.yaml](file:///C:/Users/soufi/StudioProjects/bat_track_v1/pubspec.yaml)
- Repasser la dépendance `shared_models` en chemin relatif local :
  ```yaml
  shared_models:
    path: ../shared_models
  ```

### 4. Automatisation des Workflows
#### [NEW] [melos.yaml](file:///C:/Users/soufi/StudioProjects/btp_4_0_ecosystem/melos.yaml)
```yaml
name: btp_4_0_ecosystem
packages:
  - packages/**

scripts:
  bootstrap:
    run: melos bootstrap
    description: Lie tous les packages entre eux.

  analyze:
    run: melos exec -- "flutter analyze"
    description: Analyse statique globale.

  build_runner:
    run: melos exec -- "flutter pub run build_runner build --delete-conflicting-outputs"
    select-package:
      depends-on: "build_runner"
```

---

## 🛡️ Vérification Plan

### Validation Locale
- Installer melos : `dart pub global activate melos`.
- Lancer `melos bootstrap`.
- Lancer `melos run analyze`.

### Validation CI
- Mettre à jour `ci.yml` pour utiliser `melos bootstrap` au lieu de configurer manuellement le Git HTTPS pour chaque dépendance.

---

## ⚠️ Risques identifiés
- **Historique Git :** Le déplacement des fichiers peut complexifier la lecture de l'historique si on ne fait pas un `git mv`.
- **Chemins relatifs :** Vérifier les imports de fichiers hors-code (assets, config).

**Souhaitez-vous que je génère les fichiers de configuration Melos (`melos.yaml` et racine `pubspec.yaml`) dès maintenant à la racine de votre projet actuel pour préparer le terrain ?**
