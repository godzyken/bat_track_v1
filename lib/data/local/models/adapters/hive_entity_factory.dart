import 'package:shared_models/shared_models.dart';

import '../../../../models/data/hive_model.dart';
import '../entities/index_entity_extention.dart';
import '../index_model_extention.dart';

/// Factory générique pour créer des entités Hive
/// Réduit la duplication des conversions Model ↔ Entity
abstract class HiveEntityFactory<
  M extends UnifiedModel,
  E extends HiveModel<M>
> {
  /// Convertit un modèle en entité Hive
  E toEntity(M model);

  /// Convertit une entité Hive en modèle
  M fromEntity(E entity);

  /// Convertit une liste de modèles en entités
  List<E> toEntities(List<M> models) {
    return models.map((m) => toEntity(m)).toList();
  }

  /// Convertit une liste d'entités en modèles
  List<M> fromEntities(List<E> entities) {
    return entities.map((e) => fromEntity(e)).toList();
  }

  /// Convertit un JSON en entité Hive
  M fromRemote(Map<String, dynamic> json);
}

/// Exemple : Factory pour Chantier
class ChantierEntityFactory
    extends HiveEntityFactory<Chantier, ChantierEntity> {
  @override
  ChantierEntity toEntity(Chantier model) {
    return ChantierEntity(
      cid: model.id,
      nom: model.nom,
      adresse: model.adresse,
      clientId: model.clientId,
      dateDebut: model.dateDebut,
      dateFin: model.dateFin,
      etat: model.etat,
      technicienIds: model.technicienIds,
      documents: model.documents
          .map((d) => PieceJointeEntity.fromModel(d))
          .toList(),
      etapes: model.etapes
          .map((e) => ChantierEtapesEntity.fromModel(e))
          .toList(),
      commentaire: model.commentaire,
      budgetPrevu: model.budgetPrevu,
      budgetReel: model.budgetReel,
      interventions: model.interventions
          .map((i) => InterventionEntity.fromModel(i))
          .toList(),
      chefDeProjetId: model.chefDeProjetId,
      clientValide: model.clientValide,
      chefDeProjetValide: model.chefDeProjetValide,
      techniciensValides: model.techniciensValides,
      superUtilisateurValide: model.superUtilisateurValide,
      isCloudOnly: model.isCloudOnly,
      chUpdatedAt: model.updatedAt,
      tauxTVA: model.tauxTVAParDefaut,
      remise: model.remiseParDefaut,
    );
  }

  @override
  Chantier fromEntity(ChantierEntity entity) {
    return entity.toModel();
  }

  @override
  Chantier fromRemote(Map<String, dynamic> json) {
    return Chantier.fromJson(json);
  }
}

class ChantierEtapeEntityFactory
    extends HiveEntityFactory<ChantierEtape, ChantierEtapesEntity> {
  @override
  ChantierEtape fromEntity(ChantierEtapesEntity entity) => entity.toModel();

  @override
  ChantierEtapesEntity toEntity(ChantierEtape model) =>
      ChantierEtapesEntity.fromModel(model);

  @override
  ChantierEtape fromRemote(Map<String, dynamic> json) {
    return ChantierEtape.fromJson(json);
  }
}

class ProjetEntityFactory extends HiveEntityFactory<Projet, ProjetEntity> {
  @override
  Projet fromEntity(ProjetEntity entity) {
    return entity.toModel();
  }

  @override
  ProjetEntity toEntity(Projet model) => ProjetEntity.fromModel(model);

  @override
  Projet fromRemote(Map<String, dynamic> json) {
    return Projet.fromJson(json);
  }
}

class ClientEntityFactory extends HiveEntityFactory<Client, ClientEntity> {
  @override
  Client fromEntity(ClientEntity entity) {
    return entity.toModel();
  }

  @override
  ClientEntity toEntity(Client model) {
    return ClientEntity.fromModel(model);
  }

  @override
  Client fromRemote(Map<String, dynamic> json) {
    return Client.fromJson(json);
  }
}

class TechnicienEntityFactory
    extends HiveEntityFactory<Technicien, TechnicienEntity> {
  @override
  Technicien fromEntity(TechnicienEntity entity) {
    return entity.toModel();
  }

  @override
  TechnicienEntity toEntity(Technicien model) =>
      TechnicienEntity.fromModel(model);

  @override
  Technicien fromRemote(Map<String, dynamic> json) {
    return Technicien.fromJson(json);
  }
}

class InterventionEntityFactory
    extends HiveEntityFactory<Intervention, InterventionEntity> {
  @override
  Intervention fromEntity(InterventionEntity entity) => entity.toModel();

  @override
  InterventionEntity toEntity(Intervention model) =>
      InterventionEntity.fromModel(model);

  @override
  Intervention fromRemote(Map<String, dynamic> json) {
    return Intervention.fromJson(json);
  }
}

class FactureEntityFactory extends HiveEntityFactory<Facture, FactureEntity> {
  @override
  Facture fromEntity(FactureEntity entity) => entity.toModel();

  @override
  FactureEntity toEntity(Facture model) => FactureEntity.fromModel(model);

  @override
  Facture fromRemote(Map<String, dynamic> json) {
    return Facture.fromJson(json);
  }
}

class FactureDraftEntityFactory
    extends HiveEntityFactory<FactureDraft, FactureDraftEntity> {
  @override
  FactureDraft fromEntity(FactureDraftEntity entity) => entity.toModel();

  @override
  FactureDraftEntity toEntity(FactureDraft model) =>
      FactureDraftEntity.fromModel(model);

  @override
  FactureDraft fromRemote(Map<String, dynamic> json) {
    return FactureDraft.fromJson(json);
  }
}

class FactureModelEntityFactory
    extends HiveEntityFactory<FactureModel, FactureModelEntity> {
  @override
  FactureModel fromEntity(FactureModelEntity entity) => entity.toModel();
  @override
  FactureModelEntity toEntity(FactureModel model) =>
      FactureModelEntity.fromModel(model);

  @override
  FactureModel fromRemote(Map<String, dynamic> json) {
    return FactureModel.fromJson(json);
  }
}

class PieceEntityFactory extends HiveEntityFactory<Piece, PieceEntity> {
  @override
  Piece fromEntity(PieceEntity entity) => entity.toModel();
  @override
  PieceEntity toEntity(Piece model) => PieceEntity.fromModel(model);

  @override
  Piece fromRemote(Map<String, dynamic> json) {
    return Piece.fromJson(json);
  }
}

class MateriauEntityFactory
    extends HiveEntityFactory<Materiau, MateriauEntity> {
  @override
  Materiau fromEntity(MateriauEntity entity) => entity.toModel();
  @override
  MateriauEntity toEntity(Materiau model) => MateriauEntity.fromModel(model);
  @override
  Materiau fromRemote(Map<String, dynamic> json) {
    return Materiau.fromJson(json);
  }
}

class MaterielEntityFactory
    extends HiveEntityFactory<Materiel, MaterielEntity> {
  @override
  Materiel fromEntity(MaterielEntity entity) => entity.toModel();
  @override
  MaterielEntity toEntity(Materiel model) => MaterielEntity.fromModel(model);
  @override
  Materiel fromRemote(Map<String, dynamic> json) {
    return Materiel.fromJson(json);
  }
}

class MainOeuvreEntityFactory
    extends HiveEntityFactory<MainOeuvre, MainOeuvreEntity> {
  @override
  MainOeuvre fromEntity(MainOeuvreEntity entity) => entity.toModel();
  @override
  MainOeuvreEntity toEntity(MainOeuvre model) =>
      MainOeuvreEntity.fromModel(model);
  @override
  MainOeuvre fromRemote(Map<String, dynamic> json) {
    return MainOeuvre.fromJson(json);
  }
}

class PieceJointeEntityFactory
    extends HiveEntityFactory<PieceJointe, PieceJointeEntity> {
  @override
  PieceJointe fromEntity(PieceJointeEntity entity) => entity.toModel();
  @override
  PieceJointeEntity toEntity(PieceJointe model) =>
      PieceJointeEntity.fromModel(model);
  @override
  PieceJointe fromRemote(Map<String, dynamic> json) {
    return PieceJointe.fromJson(json);
  }
}

class EquipementEntityFactory
    extends HiveEntityFactory<Equipement, EquipementEntity> {
  @override
  Equipement fromEntity(EquipementEntity entity) => entity.toModel();
  @override
  EquipementEntity toEntity(Equipement model) =>
      EquipementEntity.fromModel(model);

  @override
  Equipement fromRemote(Map<String, dynamic> json) {
    return Equipement.fromJson(json);
  }
}

class UserEntityFactory extends HiveEntityFactory<UserModel, UserEntity> {
  @override
  UserModel fromEntity(UserEntity entity) => entity.toModel();

  @override
  UserEntity toEntity(UserModel model) => UserEntity.fromModel(model);

  @override
  UserModel fromRemote(Map<String, dynamic> json) {
    return UserModel.fromJson(json);
  }
}

class AppUserEntityFactory extends HiveEntityFactory<AppUser, AppUserEntity> {
  @override
  AppUser fromEntity(AppUserEntity entity) => entity.toModel();
  @override
  AppUserEntity toEntity(AppUser model) => AppUserEntity.fromModel(model);
  @override
  AppUser fromRemote(Map<String, dynamic> json) {
    return AppUser.fromJson(json);
  }
}

/// Registre centralisé des factories
class EntityFactoryRegistry {
  static final Map<Type, HiveEntityFactory> _factories = {};

  static void register<M extends UnifiedModel, E extends HiveModel<M>>(
    HiveEntityFactory<M, E> factory,
  ) {
    _factories[M] = factory;
  }

  static HiveEntityFactory<M, E>?
  get<M extends UnifiedModel, E extends HiveModel<M>>() {
    return _factories[M] as HiveEntityFactory<M, E>?;
  }

  /// Initialisation au démarrage de l'app
  static void init() {
    register(ChantierEntityFactory());
    register(ChantierEtapeEntityFactory());
    register(TechnicienEntityFactory());
    register(ClientEntityFactory());
    register(ProjetEntityFactory());
    register(InterventionEntityFactory());
    register(FactureEntityFactory());
    register(FactureDraftEntityFactory());
    register(FactureModelEntityFactory());
    register(PieceEntityFactory());
    register(MateriauEntityFactory());
    register(MaterielEntityFactory());
    register(MainOeuvreEntityFactory());
    register(PieceJointeEntityFactory());
    register(PieceEntityFactory());
    register(EquipementEntityFactory());
    register(UserEntityFactory());
    register(AppUserEntityFactory());
  }
}

// Utilisation dans le code :
//
// final factory = EntityFactoryRegistry.get<Chantier, ChantierEntity>()!;
// final entity = factory.toEntity(chantier);
// final model = factory.fromEntity(entity);
