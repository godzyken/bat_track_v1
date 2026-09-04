# Plan d'Implémentation : Lancement de la Release v1.0.0

Ce plan décrit les étapes pour publier la première version officielle de **BatTrack** via GitHub Actions.

## 🛠️ Objectifs
1. **Pérenniser l'équipement AI :** Commiter les fichiers de configuration et de documentation créés.
2. **Déclencher la Release :** Créer un tag `v1.0.0` et le pousser sur GitHub pour lancer le build APK et Web.

---

## 🏗️ Modifications Proposées

### 1. Git : Validation de l'équipement
- `git add AGENTS.md .ai .mcp .agents .github/workflows/*.yml`
- `git commit -m "chore: équipement AI et workflows de release"`

### 2. Git : Marquage de la Release
- `git tag v1.0.0`

### 3. Git : Déploiement
- `git push origin master`
- `git push origin v1.0.0`

---

## 🛡️ Vérification Plan

### Avant push
- Un dernier `flutter analyze` pour garantir la propreté absolue.
- Vérification du `pubspec.yaml` (version 1.0.0+1).

### Après push
- Suivi du workflow "Release" sur GitHub Actions.
- Vérification de la disponibilité de l'APK dans la section "Releases" du dépôt.

---

## ⚠️ Point d'attention
- Assurez-vous d'avoir configuré le secret `GITHUB_TOKEN` (automatique pour les Actions) si des permissions spécifiques sont requises.
- Le push master déclenchera également le workflow `ci.yml`.
