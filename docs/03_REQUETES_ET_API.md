# 03. Requêtes Réseau, API & Flux de Données

Ce document détaille l'ensemble des échanges réseau, requêtes API REST, opérations bases de données et flux de synchronisation exécutés par **BatTrack v1**.

---

## 1. Connecteur REST API Dolibarr ERP

L'intégration avec Dolibarr repose sur le client HTTP **Dio** (`lib/providers/dio_provider.dart` et `lib/data/remote/services/dolibarr_services.dart`).

### 1.1 Configuration du Client HTTP (Dio)
Les requêtes vers Dolibarr sont authentifiées par un jeton d'API (*API Token*) transmis dans les en-têtes HTTP :

```dart
BaseOptions(
  baseUrl: 'https://votre-instance-dolibarr.com/api/index.php',
  headers: {
    'Authorization': 'Bearer $token',
    'DOLAPIKEY': token, // Support rétrocompatible header Dolibarr
    'Accept': 'application/json',
  },
  connectTimeout: const Duration(seconds: 10),
  receiveTimeout: const Duration(seconds: 15),
)
```

### 1.2 Table des Endpoints Dolibarr Exploités

| Ressource Métier | Méthode HTTP | Endpoint Dolibarr | Modèle BatTrack | Description & Filtres |
|---|---|---|---|---|
| **Tiers / Clients** | `GET` | `/thirdparties` | `Client` | Liste des clients. Filtre optionnel : `?mode=1` (clients actifs). |
| **Projets / Chantiers**| `GET` | `/projects` | `Projet` / `Chantier` | Liste des projets BTP ou chantiers créés dans l'ERP. |
| **Tâches / Étapes** | `GET` | `/tasks` | `ChantierEtape` / `MainOeuvre` | Liste des tâches planifiées sur les projets. |
| **Factures** | `GET` | `/invoices` | `Facture` | Factures émises et historiques de règlements. |
| **Produits / Matériaux**| `GET` | `/products` | `Materiau` / `Produit` | Catalogue d'articles et matières premières avec prix HT. |
| **Intervenants / Users**| `GET` | `/users` ou `/intervenants`| `Technicien` | Utilisateurs Dolibarr pour affectation sur chantier. |
| **Documents Joints** | `GET` | `/documents` | `PieceJointe` | Fichiers joints et fiches techniques associées. |

### 1.3 Exemple de Requête & Réponse : `/thirdparties` (Clients)

#### Requête HTTP :
```http
GET /api/index.php/thirdparties?limit=50&sortfield=t.rowid&sortorder=DESC HTTP/1.1
Host: erp.masociete-btp.fr
Authorization: Bearer 9f8a3b7c2d1e...
Accept: application/json
```

#### Exemple de Réponse JSON :
```json
[
  {
    "id": "42",
    "ref": "CLI-2026-0042",
    "name": "SCI Résidence Les Pins",
    "address": "15 avenue de la République",
    "zip": "75011",
    "town": "Paris",
    "email": "gestion@scilespins.fr",
    "phone": "0140203040",
    "tva_intra": "FR12345678901",
    "status": "1",
    "date_creation": "1738749200",
    "date_modification": "1741520000"
  }
]
```

### 1.4 Algorithme de Synchronisation Dolibarr (`DolibarrSyncService`)
Dans `lib/data/remote/services/dolibarr_sync_service.dart`, l'opération `syncAllFromDolibarr()` exécute une séquence d'appels asynchrones en cascade :
1. Téléchargement des tiers (`fetchClients()`) $\rightarrow$ Conversion en objets `Client` $\rightarrow$ Sauvegarde dans la boîte Hive `'clients'`.
2. Téléchargement des projets (`fetchProjects()`) $\rightarrow$ Conversion en `Chantier` $\rightarrow$ Sauvegarde dans `'chantiers'`.
3. Téléchargement des tâches (`fetch()`) $\rightarrow$ Conversion en `Intervention` et `Technicien`.
4. En cas d'échec sur un point de terminaison, l'erreur est interceptée, consignée et notifiée à l'utilisateur via une `SnackBar` sans bloquer le reste de la synchronisation.

---

## 2. Requêtes Cloud Firestore & Firebase

Firebase sert de colonne vertébrale pour la réactivité temps réel, l'authentification et le stockage de fichiers volumineux.

### 2.1 Authentification Firebase (`FirebaseAuth`)
Située dans `lib/features/auth/data/repository/auth_repository.dart` :
- **Connexion :** `auth.signInWithEmailAndPassword(email, password)`
- **Inscription :** `auth.createUserWithEmailAndPassword(email, password)` suivi de la création du document profil dans la collection Firestore `/users/{uid}`.
- **Déconnexion :** `auth.signOut()`.

### 2.2 Schémas des Collections Firestore

#### 1. Collection `users`
- **Chemin :** `/users/{uid}`
- **Champs :**
  ```json
  {
    "uid": "AB12cdEF34gh",
    "name": "Jean Dupont",
    "company": "Bâtiment Éco Travaux",
    "role": "admin", // admin | superutilisateur | chefdeprojet | technicien | client
    "createdAt": "2026-08-15T10:00:00.000Z"
  }
  ```

#### 2. Collection `chantiers`
- **Chemin :** `/chantiers/{chantierId}`
- **Champs :**
  ```json
  {
    "id": "cht_8831",
    "nom": "Rénovation Toiture - Villa Martin",
    "clientId": "CLI-2026-0042",
    "projetId": "prj_5501",
    "dateDebut": "2026-09-01T08:00:00.000Z",
    "dateFin": "2026-10-15T18:00:00.000Z",
    "budget": 24500.0,
    "statut": "en_cours",
    "updatedAt": "2026-11-15T14:22:10.000Z"
  }
  ```

#### 3. Collection `chantier_etapes`
- **Chemin :** `/chantier_etapes/{etapeId}`
- **Champs :**
  ```json
  {
    "id": "etp_101",
    "chantierId": "cht_8831",
    "nom": "Pose de l'isolant biosourcé",
    "statut": "À faire", // "À faire" | "En cours" | "Terminé"
    "terminee": false,
    "ordre": 2,
    "updatedAt": "2026-11-15T15:00:00.000Z"
  }
  ```

#### 4. Collection `fiscal_audit_logs` (Journal d'audit scellé ISCA)
- **Chemin :** `/fiscal_audit_logs/{factureId}_{timestamp}`
- **Champs :**
  ```json
  {
    "action": "PAYMENT_SEAL",
    "payload": "{\"factureId\":\"FAC-2026-0012\",\"amountHt\":8900.0,\"clientId\":\"CLI-42\",\"timestamp\":\"2026-11-15T17:30:00.000Z\"}",
    "previousHash": "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855",
    "currentHash": "7f83b1657ff1fc53b92dc18148a1d65dfc2d4b1fa3d677284addd200126d9069",
    "createdAt": "2026-11-15T17:30:01.000Z"
  }
  ```

#### 5. Collection `fiscal_closures` (Clôtures Périodiques ISCA)
- **Chemin :** `/fiscal_closures/{closureId}`
- **Champs :**
  ```json
  {
    "id": "c1f7b0a8-3f82-4467-bc12-89bdfa0199e4",
    "companyId": "comp_001",
    "periodType": "DAILY", // DAILY | MONTHLY | ANNUAL
    "periodDate": "2026-11-15",
    "createdAt": "2026-11-15T23:59:59.000Z",
    "status": "CLOSED"
  }
  ```

### 2.3 Opérations Firestore Typiques dans le Code (`FirestoreService`)
- **Lecture ponctuelle :**
  ```dart
  final doc = await _firestore.collection(collectionPath).doc(id).get();
  ```
- **Écriture avec fusion (*merge*) :**
  ```dart
  await _firestore.collection(collectionPath).doc(id).set(
    {...data, 'id': id, 'updatedAt': DateTime.now().toIso8601String()},
    SetOptions(merge: true),
  );
  ```
- **Écoute temps réel avec filtrage :**
  ```dart
  Stream<List<Map<String, dynamic>>> watchCollection(String collectionPath) {
    return _firestore.collection(collectionPath).snapshots().map(
      (snapshot) => snapshot.docs.map((doc) => doc.data()).toList(),
    );
  }
  ```

### 2.4 Stockage Binaire Firebase Storage (`FirebaseStorageService`)
Situé dans `lib/data/remote/services/firebase_storage_service.dart` :
- **Chemin des médias :** `/chantiers/{chantierId}/etapes/{etapeId}/{nomFichier}`
- **Processus d'upload :**
  1. Sélection du fichier local (`File`).
  2. Envoi du flux d'octets avec métadonnées MIME (`image/jpeg`, `application/pdf`).
  3. Récupération de l'URL publique de téléchargement signée (`downloadUrl`).
  4. Création de l'entité `PieceJointe` dans la base locale et distante.

---

## 3. Requêtes Supabase (PostgreSQL & Row Level Security)

Le service `SupabaseService` (`lib/data/remote/services/supabase_service.dart`) fournit une passerelle relationnelle PostgreSQL :

### 3.1 Opérations CRUD Supabase
- **Sélection unitaire :**
  ```dart
  final res = await _supabase
      .from(tableName)
      .select()
      .eq('id', id)
      .maybeSingle();
  ```
- **Upsert (Insertion ou Mise à jour automatique) :**
  ```dart
  await _supabase.from(tableName).upsert({'id': id, ...data});
  ```
- **Requête delta (mise à jour incrémentale depuis une date) :**
  ```dart
  var query = _supabase.from(tableName).select();
  if (updatedAfter != null) {
    query = query.gte('updatedAt', updatedAfter.toIso8601String());
  }
  final results = await query;
  ```
- **Écoute en flux continu (*Realtime Streams*) :**
  ```dart
  Stream<List<Map<String, dynamic>>> stream = _supabase
      .from(tableName)
      .stream(primaryKey: ['id']);
  ```

---

## 4. Requêtes Google Sheets API v4

Le service `GoogleSheetsProductService` (`lib/core/services/google_sheets_product_service.dart`) permet l'import de données depuis un classeur partagé :

### 4.1 Authentification OAuth2 / Service Account
Le service utilise `googleapis_auth` pour créer un client HTTP authentifié à partir d'un compte de service Google Cloud :

```dart
final client = await clientViaServiceAccount(
  credentials,
  [sheets.SheetsApi.spreadsheetsReadonlyScope],
);
final sheetsApi = sheets.SheetsApi(client);
```

### 4.2 Requête d'Extraction de Valeurs
```dart
final response = await sheetsApi.spreadsheets.values.get(
  spreadsheetId,
  'Produits!A2:Z', // Ignore la ligne d'en-tête (ligne 1)
);
```

### 4.3 Mapping des Colonnes vers le Modèle Dart `Produit`
| Colonne Google Sheets | Champ Métier `Produit` | Type de Donnée |
|---|---|---|
| **A** | `reference` | `String` |
| **B** | `nom` | `String` |
| **C** | `categorie` | `String` |
| **D** | `prixUnitaireHT` | `double` (converti depuis texte décimal) |
| **E** | `unite` | `String` (m², mètre linéaire, kg, unité) |
| **F** | `tauxTVA` | `double` (5.5, 10.0, 20.0) |

---

## 5. Moteur de Synchronisation Offline-First & Résolution de Conflits

### 5.1 Architecture de la File d'Attente (`FrameSyncQueue`)
Toute modification effectuée hors-ligne (ex: signature d'un bon de réception, validation d'étape) est soumise à la file de synchronisation :

```
[ACTION UTILISATEUR]
         │
         ▼
[ÉCRITURE LOCALE HIVE] ──> UI mise à jour instantanément (Optimistic UI)
         │
         ▼
[FrameSyncQueue] (Mise en mémoire tampon / Debounce)
         │
         ├───> [Réseau Actif ?] ──OUI──> [Écriture Distante Immédiate]
         │                                       │
         └───> NON                               ▼
                │                          [Succès : Marqué synchronisé]
                ▼
       [Marqué 'PENDING' dans Hive]
                │
                ▼ (Attente signal réseau)
       [Détection ConnectivityPlus]
                │
                ▼
       [Rejeu séquentiel par SyncWorker]
```

### 5.2 Algorithme de Résolution des Conflits : "Last-Update-Wins"
Lorsque plusieurs postes modifient la même ressource (ex: le conducteur de travaux sur le web et le technicien sur mobile) :
1. Chaque modèle possède un attribut immuable `updatedAt` renseigné en UTC.
2. Lorsque le flux de données distant (`watchRemote()`) émet une liste d'entités, chaque élément distant est confronté à sa version locale en cache :
   ```dart
   final shouldUpdate = local == null ||
       (remote.updatedAt != null &&
        local.updatedAt != null &&
        remote.updatedAt!.isAfter(local.updatedAt!));

   if (shouldUpdate) {
     await _localBox.put(remote.id, factory.toEntity(remote));
   }
   ```
3. Cela garantit qu'aucune donnée locale plus récente n'est écrasée par une mise à jour réseau différée.
