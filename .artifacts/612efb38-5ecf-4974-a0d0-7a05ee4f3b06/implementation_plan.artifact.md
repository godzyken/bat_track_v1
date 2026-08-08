# Plan : Stratégie "Offline-First" avec Firebase

Pour répondre à l'exigence "aucun manque de réseau ne doit affecter l'artisan", nous allons mettre en place une architecture **Local-First**. L'application doit fonctionner parfaitement en mode avion, et se synchroniser de manière transparente dès que le réseau revient.

## Stratégie Technique

### 1. Firestore avec Persistance Permanente
Nous allons configurer Firestore pour utiliser un cache local persistant sur le disque.
- **Mobile (Android/iOS)** : Activé par défaut, mais nous allons augmenter la taille du cache.
- **Web** : Activation explicite de l'indexDB pour le cache.

### 2. Architecture "Source de Vérité Locale" (Hive)
Même avec le cache Firestore, l'utilisation de **Hive** (déjà présent dans le projet) est recommandée comme "Source de Vérité" immédiate pour l'interface utilisateur.
- **Écriture** : L'UI écrit dans Hive immédiatement (retour instantané). Le service de sync tente d'écrire dans Firebase en arrière-plan.
- **Lecture** : L'UI lit depuis Hive. Hive est mis à jour dès que Firebase reçoit de nouvelles données (Realtime).

### 3. Gestion des Médias (Photos de chantier)
C'est le point critique pour un artisan.
- **Capture** : Les photos sont enregistrées localement dans le dossier `application_documents_directory`.
- **Référence** : Un objet `PieceJointe` est créé localement avec le chemin du fichier local.
- **Upload Différé** : Un worker (ou une boucle de sync) uploade les fichiers vers Firebase Storage uniquement quand le réseau est stable.

---

## Proposed Changes

### [Core Configuration]

#### [MODIFY] [firebase_providers.dart](file:///C:/Users/soufi/StudioProjects/bat_track_v1/lib/data/remote/providers/firebase_providers.dart)
- Augmenter la taille du cache Firestore (`cacheSizeBytes`).
- Configurer la persistance pour le Web.

### [Sync Logic]

#### [MODIFY] [entity_sync_services.dart](file:///C:/Users/soufi/StudioProjects/bat_track_v1/lib/models/services/entity_sync_services.dart)
- Modifier `save` pour qu'il ne bloque pas l'utilisateur si le remote échoue.
- Implémenter une file d'attente d'upload pour les images.

### [UI Components]

#### [NEW] Indicator Widget
- Créer un petit widget visuel indiquant si l'app est en mode "Sync en attente" ou "Connecté".

---

## Verification Plan

### Manual Verification
1.  **Test Mode Avion** :
    - Ouvrir l'application, passer en mode avion.
    - Créer un nouveau Chantier.
    - Ajouter une photo (simulation).
    - Vérifier que tout s'affiche instantanément dans les listes.
2.  **Test Reconnexion** :
    - Désactiver le mode avion.
    - Vérifier dans la Console Firebase que les données et la photo sont bien arrivées.

---
> [!IMPORTANT]
> Cette approche garantit que l'artisan n'a jamais de "chargement" ou de "roue qui tourne" pendant qu'il saisit ses données sur le terrain, même dans une zone blanche.
