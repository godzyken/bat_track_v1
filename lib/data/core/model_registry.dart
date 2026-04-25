import 'package:shared_models/shared_models.dart';

import '../../../data/local/models/index_model_extention.dart';
import 'unified_repository.dart';

/// Registry centralisé pour tous les modèles
/// Remplace JsonModelFactory + FallbackFactory + ModelMapper
class ModelRegistry {
  static final Map<Type, _ModelMetadata> _registry = {};

  /// Enregistre un modèle avec ses métadonnées

  /// Version avec contrainte UnifiedModel (recommandée)
  static void register<T extends UnifiedModel>({
    required T Function(Map<String, dynamic>) fromJson,
    required T Function() mock,
    required RepositoryConfig<T> repoConfig,
  }) {
    _registry[T] = _ModelMetadata<T>(
      fromJson: fromJson,
      mock: mock,
      repoConfig: repoConfig,
    );
  }

  /// Récupère le builder fromJson
  static T Function(Map<String, dynamic>)?
  getFromJson<T extends UnifiedModel>() {
    final metadata = _registry[T] as _ModelMetadata<T>?;
    return metadata?.fromJson;
  }

  /// Récupère le mock factory
  static T Function()? getMock<T extends UnifiedModel>() {
    final metadata = _registry[T] as _ModelMetadata<T>?;
    return metadata?.mock;
  }

  /// Récupère la config du repository
  static RepositoryConfig<T>? getRepoConfig<T extends UnifiedModel>() {
    final metadata = _registry[T] as _ModelMetadata<T>?;
    return metadata?.repoConfig;
  }

  /// Crée une instance depuis JSON dynamique
  static T? fromJson<T extends UnifiedModel>(Map<String, dynamic> json) {
    final builder = getFromJson<T>();
    return builder?.call(json);
  }

  /// Crée un mock
  static T? createMock<T extends UnifiedModel>() {
    final factory = getMock<T>();
    return factory?.call();
  }

  /// Vérifie si un type est enregistré
  static bool isRegistered<T extends UnifiedModel>() {
    return _registry.containsKey(T);
  }

  /// Initialise tous les modèles de l'application
  static void initializeAll() {
    // Chantiers
    register<Chantier>(
      fromJson: Chantier.fromJson,
      mock: Chantier.mock,
      repoConfig: RepositoryConfig(
        collectionPath: 'chantiers',
        dolibarrEndpoint: 'projects',
        fromJson: Chantier.fromJson,
      ),
    );

    // Clients
    register<Client>(
      fromJson: Client.fromJson,
      mock: Client.mock,
      repoConfig: RepositoryConfig(
        collectionPath: 'clients',
        dolibarrEndpoint: 'thirdparties',
        fromJson: Client.fromJson,
      ),
    );

    // Techniciens
    register<Technicien>(
      fromJson: Technicien.fromJson,
      mock: Technicien.mock,
      repoConfig: RepositoryConfig(
        collectionPath: 'techniciens',
        dolibarrEndpoint: 'users',
        fromJson: Technicien.fromJson,
      ),
    );

    // Projets
    register<Projet>(
      fromJson: Projet.fromJson,
      mock: () => ProjetMock.mock(),
      repoConfig: RepositoryConfig(
        collectionPath: 'projets',
        dolibarrEndpoint: 'projects',
        fromJson: Projet.fromJson,
        enableDolibarr: true,
      ),
    );

    // Interventions
    register<Intervention>(
      fromJson: Intervention.fromJson,
      mock: Intervention.mock,
      repoConfig: RepositoryConfig(
        collectionPath: 'interventions',
        dolibarrEndpoint: 'tasks',
        fromJson: Intervention.fromJson,
      ),
    );

    // Matériaux
    register<Materiau>(
      fromJson: Materiau.fromJson,
      mock: Materiau.mock,
      repoConfig: RepositoryConfig(
        collectionPath: 'materiaux',
        dolibarrEndpoint: 'products',
        fromJson: Materiau.fromJson,
        enableDolibarr: true,
      ),
    );

    // Matériel
    register<Materiel>(
      fromJson: Materiel.fromJson,
      mock: Materiel.mock,
      repoConfig: RepositoryConfig(
        collectionPath: 'materiels',
        dolibarrEndpoint: 'products',
        fromJson: Materiel.fromJson,
      ),
    );

    // Main d'œuvre
    register<MainOeuvre>(
      fromJson: MainOeuvre.fromJson,
      mock: MainOeuvre.mock,
      repoConfig: RepositoryConfig(
        collectionPath: 'main_oeuvre',
        dolibarrEndpoint: 'tasks',
        fromJson: MainOeuvre.fromJson,
      ),
    );

    // Factures
    register<Facture>(
      fromJson: Facture.fromJson,
      mock: Facture.mock,
      repoConfig: RepositoryConfig(
        collectionPath: 'factures',
        dolibarrEndpoint: 'invoices',
        fromJson: Facture.fromJson,
        enableDolibarr: true,
      ),
    );

    // Pièces jointes
    register<PieceJointe>(
      fromJson: PieceJointe.fromJson,
      mock: PieceJointe.mock,
      repoConfig: RepositoryConfig(
        collectionPath: 'pieces_jointes',
        dolibarrEndpoint: 'documents',
        fromJson: PieceJointe.fromJson,
      ),
    );

    // Chantier étapes
    register<ChantierEtape>(
      fromJson: ChantierEtape.fromJson,
      mock: ChantierEtape.mock,
      repoConfig: RepositoryConfig(
        collectionPath: 'chantier_etapes',
        dolibarrEndpoint: 'etapes',
        fromJson: ChantierEtape.fromJson,
      ),
    );
  }
}

/// Métadonnées internes d'un modèle
class _ModelMetadata<T extends UnifiedModel> {
  final T Function(Map<String, dynamic>) fromJson;
  final T Function() mock;
  final RepositoryConfig<T> repoConfig;

  _ModelMetadata({
    required this.fromJson,
    required this.mock,
    required this.repoConfig,
  });
}

/// Extensions pratiques
extension ModelRegistryExtension on Type {
  bool get isRegistered => ModelRegistry.isRegistered();
}

// ==================== UTILISATION ====================

/*
// Dans main.dart :
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialiser le registry
  ModelRegistry.initializeAll();

  runApp(MyApp());
}

// Dans un provider :
final chantierRepoProvider = Provider<UnifiedRepository<Chantier>>((ref) {
  final config = ModelRegistry.getRepoConfig<Chantier>()!;
  return UnifiedRepository<Chantier>(config, ref);
});

// Utilisation :
final repo = ref.read(chantierRepoProvider);
final chantier = await repo.get('chantier_id');
await repo.save(chantier.copyWith(nom: 'Nouveau nom'));
await repo.syncFromDolibarr(); // Import Dolibarr

// Créer un mock pour les tests :
final mockChantier = ModelRegistry.createMock<Chantier>()!;

// Parser JSON dynamique :
final parsed = ModelRegistry.fromJson<Chantier>(jsonData);
*/
