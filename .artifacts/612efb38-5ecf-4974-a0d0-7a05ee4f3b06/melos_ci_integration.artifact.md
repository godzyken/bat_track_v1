# Intégration de Melos dans la CI/CD

Ce plan vise à utiliser Melos sur GitHub Actions pour gérer proprement les dépendances locales privées.

## 🛠️ Modifications des Workflows

### 1. Mise à jour de `ci.yml` et `release.yml`

Nous allons modifier les workflows pour qu'ils récupèrent automatiquement les deux dépôts et utilisent Melos pour le lien.

```yaml
    steps:
      - name: Checkout BatTrack
        uses: actions/checkout@v4
        with:
          path: bat_track_v1

      - name: Checkout SharedModels
        uses: actions/checkout@v4
        with:
          repository: godzyken/shared_models
          token: ${{ secrets.GH_PAT }}
          path: shared_models

      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          channel: stable
          flutter-version: "3.47.1"

      - name: Install Melos
        run: dart pub global activate melos

      - name: Melos Bootstrap
        run: melos bootstrap
        working-directory: bat_track_v1 # ou la racine du workspace si on déplace tout
```

## 📋 Étapes d'exécution

1.  **Uniformisation des pubspec** : Passer `shared_models` en `path: ../shared_models` dans tous les projets.
2.  **Configuration Melos** : Créer le fichier `melos.yaml` à la racine (déjà fait).
3.  **Ajustement Git** : Puisque Melos va chercher des dossiers frères, la CI doit cloner les projets dans des sous-dossiers spécifiques.

---

## 🚀 Avantage Final
Plus de bidouille avec `git config --global url...`. La CI reflète exactement votre environnement de développement local.

**Souhaitez-vous que je procède à cette reconfiguration des workflows pour passer à l'ère Melos ?**
